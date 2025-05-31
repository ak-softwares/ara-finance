import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/orders/orders_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../product/product_controller.dart';
import 'add_barcode_sale.dart';
import 'sales_controller.dart';

class AddSaleController extends GetxController {
  static AddSaleController get instance => Get.find();

  final OrderType orderType = OrderType.sale;
  RxDouble saleTotal = 0.0.obs;
  RxInt productCount = 0.obs;
  RxInt invoiceId = 0.obs;

  TextEditingController dateController = TextEditingController();

  final saleController = Get.put(SaleController());
  final mongoOrderRepo = Get.put(MongoOrderRepo());
  final productController = Get.put(ProductController());
  final userController = Get.put(UserController());
  final addBarcodeSaleController = Get.put(AddBarcodeSaleController());

  RxList<CartModel> selectedProducts = <CartModel>[].obs;
  Rx<UserModel> selectedCustomer = UserModel().obs;

  String get userId => AuthenticationController.instance.admin.value.id ?? '';

  @override
  Future<void> onInit() async {
    super.onInit();
    invoiceId.value = await mongoOrderRepo.fetchOrderGetNextId(orderType: orderType, userId: userId);
    updateSaleTotal();
  }

  void addCustomer(UserModel getSelectedCustomer) {
    selectedCustomer.value = getSelectedCustomer;
  }

  void addProducts(List<ProductModel> getSelectedProducts) {
    bool isUpdated = false;

    for (var product in getSelectedProducts) {
      // Check if the product already exists in the selected products list
      bool alreadyExists = selectedProducts.any((item) => item.productId == product.productId);

      if (!alreadyExists) {
        // Convert each product to a cart item with default quantity, variationId, and pageSource
        final cartItem = convertProductToCart(
          product: product,
          quantity: 1,
          variationId: 0,
        );

        selectedProducts.add(cartItem);
        isUpdated = true; // Flag to update total only if a new item was added
      }
    }

    if (isUpdated) {
      updateSaleTotal();
    }
  }

  void removeProducts(CartModel item) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if(index >= 0) {
      selectedProducts.removeAt(index);
    }
    updateSaleTotal();
  }

  void selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      dateController.text = pickedDate.toString();

      // Trigger UI update
      (context as Element).markNeedsBuild();
    }
  }

  // This function converts a productModel to a cartItemModel
  CartModel convertProductToCart({required ProductModel product, required int quantity, int variationId = 0}) {
    return CartModel(
      id: 1,
      name: product.title,
      product_id: product.id,
      productId: product.productId ?? 0,
      variationId: variationId,
      quantity: quantity,
      category: product.categories?[0].name,
      subtotal: (quantity * product.getPrice()).toStringAsFixed(0),
      total: (quantity * product.getPrice()).toStringAsFixed(0),
      subtotalTax: '0',
      totalTax: '0',
      sku: product.sku,
      price: product.getPrice().toInt(),
      purchasePrice: product.purchasePrice,
      image: product.mainImage,
      parentName: '0',
      isCODBlocked: product.isCODBlocked,
    );
  }

  Future<void> clearSale() async {
    invoiceId.value = await mongoOrderRepo.fetchOrderGetNextId(orderType: orderType, userId: userId);
    dateController.text = DateTime.now().toString();
    selectedCustomer.value = UserModel();
    selectedProducts.value = [];
    updateSaleTotal();
  }

  bool validateSaleFields() {
    try {
      if (selectedProducts.isEmpty) {
        throw Exception('Please select at least one product.');
      }
      if (selectedCustomer.value.name == null || selectedCustomer.value.name!.isEmpty) {
        throw Exception('Please select a customer.');
      }
      if (dateController.text.isEmpty) {
        throw Exception('Please enter a date.');
      }
      return true;
    } catch (e) {
      // Show validation error in a snack bar
      AppMassages.errorSnackBar(title: 'Validation Error', message: e.toString());
      return false;
    }
  }

  Future<void> saveSale() async {
    // Validate purchase fields
    if (!validateSaleFields()) {
      return; // Error messages are already shown inside validatePurchaseFields()
    }

    OrderModel sale = OrderModel(
      invoiceNumber: invoiceId.value,
      dateCreated: DateTime.tryParse(dateController.text),
      dateShipped: DateTime.now(),
      userId: AuthenticationController.instance.admin.value.id,
      user: selectedCustomer.value,
      lineItems: selectedProducts,
      total: saleTotal.value,
      status: OrderStatus.inTransit,
      orderType: orderType
    );

    await pushSale(sale: sale);
  }

  Future<void> pushSale({required OrderModel sale}) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are adding sale...', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      await addBarcodeSaleController.processAddSales(sales: [sale]);

      await clearSale();
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Purchase uploaded successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Add single item to cart
  void updateQuantity({required CartModel item, required int quantity}) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if(index >= 0){
      //This quantity is already added or updated/remove from the design
      selectedProducts[index].quantity = quantity;
      selectedProducts[index].total = (selectedProducts[index].quantity * selectedProducts[index].price!).toStringAsFixed(0);
    }
    updateSaleTotal();
  }

  // Add single item to cart
  void updatePrice({required CartModel item, required double purchasePrice}) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if(index >= 0){
      //This quantity is already added or updated/remove from the design
      selectedProducts[index].price = purchasePrice.toInt();
      selectedProducts[index].total = (selectedProducts[index].quantity * selectedProducts[index].price!).toStringAsFixed(0);
    }
    updateSaleTotal();
  }

  void updateSaleTotal(){
    double calculateTotalPrice = 0.0;
    int calculatedNoOfItems = 0;

    for(var item in selectedProducts){
      calculateTotalPrice += (item.price!) * item.quantity;
      calculatedNoOfItems += item.quantity;
    }
    saleTotal.value = calculateTotalPrice;
    productCount.value = calculatedNoOfItems;
    selectedProducts.refresh();
  }

  void resetValue({required OrderModel sale}) {
    dateController.value = TextEditingValue(
      text: sale.dateCreated.toString(),
      selection: TextSelection.fromPosition(
        TextPosition(offset: sale.dateCreated.toString().length),
      ),
    );
    invoiceId.value = sale.orderId ?? 0;
    selectedCustomer.value = sale.user ?? UserModel();
    selectedProducts.value = sale.lineItems ?? [];
    updateSaleTotal();
  }

  Future<void> saveUpdatedSale({required OrderModel previousSale}) async {
    // Validate purchase fields
    if (!validateSaleFields()) {
      return; // Error messages are already shown inside validatePurchaseFields()
    }
    OrderModel sale = OrderModel(
        id: previousSale.id,
        invoiceNumber: previousSale.invoiceNumber,
        dateCreated: DateTime.tryParse(dateController.text),
        user: selectedCustomer.value,
        lineItems: selectedProducts,
        total: saleTotal.value,
        orderType: orderType
    );

    await updateSale(newSale: sale, previousSale: previousSale);
  }

  Future<void> updateSale({required OrderModel newSale, required OrderModel previousSale}) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating sale...', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      // Create a new list with updated product quantities
      final List<CartModel> updatedProducts = (newSale.lineItems ?? []).map((currentProduct) {
        final previousProduct = (previousSale.lineItems ?? []).firstWhere(
              (item) => item.productId == currentProduct.productId,
          orElse: () => CartModel(productId: currentProduct.productId, quantity: 0), // fallback with 0 quantity
        );

        int previousQty = int.tryParse(previousProduct.quantity.toString()) ?? 0;
        int currentQty = int.tryParse(currentProduct.quantity.toString()) ?? 0;

        // Return a copy with adjusted quantity
        return currentProduct.copyWith(quantity: currentQty - previousQty);
      }).toList();

      final updateProductQuantities = productController.updateProductQuantity(cartItems: updatedProducts);

      final updateSale = mongoOrderRepo.updateOrder(order: newSale);

      await Future.wait([updateProductQuantities, updateSale]);

      // Update in RxList
      final index = saleController.sales.indexWhere((c) => c.id == newSale.id);
      if (index != -1) {
        saleController.sales[index] = newSale;
      }
      await saleController.refreshSales();

      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Purchase uploaded successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
