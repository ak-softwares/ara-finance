import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../../data/repositories/image_kit/image_kit_repo.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../models/account_voucher_model.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/image_model.dart';
import '../../../models/product_model.dart';
import '../../../models/transaction_model.dart';
import '../../product/product_controller.dart';
import '../transaction_controller.dart';

class AddSaleController extends GetxController {
  static AddSaleController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.sale;
  RxInt transactionId = 0.obs;
  OrderStatus selectedStatus = OrderStatus.inTransit;

  Rx<AccountVoucherModel> selectedCustomer = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> selectedSaleVoucher = AccountVoucherModel().obs;
  RxList<CartModel> selectedProducts = <CartModel>[].obs;

  TextEditingController discountController = TextEditingController();
  TextEditingController shippingController = TextEditingController();

  RxDouble saleTotal = 0.0.obs;
  RxInt productCount = 0.obs;

  final date = TextEditingController();
  GlobalKey<FormState> saleFormKey = GlobalKey<FormState>();

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final transactionController = Get.put(TransactionController());
  final productController = Get.put(ProductController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Listen to both controllers
    discountController.addListener(updateSaleTotal);
    shippingController.addListener(updateSaleTotal);

    date.text = DateTime.now().toIso8601String();
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
  }

  @override
  void onClose() {
    clearSaleTransaction();
    super.onClose();
  }

  void selectCustomer(AccountVoucherModel getSelectedCustomer) {
    selectedCustomer.value = getSelectedCustomer;
  }

  void selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      date.text = pickedDate.toIso8601String();
      update();
    }
  }

  void addProducts(List<ProductModel> getSelectedProducts) {
    bool isUpdated = false;

    for (var product in getSelectedProducts) {
      bool alreadyExists = selectedProducts.any((item) => item.productId == product.productId);

      if (!alreadyExists) {
        final cartItem = productController.convertProductToCart(
          product: product,
          quantity: 1,
          variationId: 0,
        );

        selectedProducts.add(cartItem);
        isUpdated = true;
      }
    }

    if (isUpdated) {
      updateSaleTotal();
    }
  }

  void removeProducts(CartModel item) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (index >= 0) {
      selectedProducts.removeAt(index);
    }
    updateSaleTotal();
  }

  void updateSaleTotal() {
    double calculateTotalPrice = 0.0;
    int calculatedNoOfItems = 0;
    final discount = double.tryParse(discountController.text) ?? 0.0;
    final shipping = double.tryParse(shippingController.text) ?? 0.0;
    for (var item in selectedProducts) {
      calculateTotalPrice += (item.price ?? 0) * item.quantity;
      calculatedNoOfItems += item.quantity;
    }
    saleTotal.value = calculateTotalPrice - discount + shipping;
    productCount.value = calculatedNoOfItems;
    selectedProducts.refresh();
  }

  void updateQuantity({required CartModel item, required int quantity}) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (index >= 0) {
      selectedProducts[index].quantity = quantity;
      selectedProducts[index].total = (selectedProducts[index].quantity * selectedProducts[index].price!).toStringAsFixed(0);
    }
    updateSaleTotal();
  }

  void updatePrice({required CartModel item, required double price}) {
    int index = selectedProducts.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (index >= 0) {
      selectedProducts[index].price = price.toInt();
      selectedProducts[index].total = (selectedProducts[index].quantity * price).toStringAsFixed(0);
    }
    updateSaleTotal();
  }

  void saveSaleTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      discount: double.tryParse(discountController.text) ?? 0.0,
      shipping: double.tryParse(shippingController.text) ?? 0.0,
      amount: saleTotal.value,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      fromAccountVoucher: selectedSaleVoucher.value,
      toAccountVoucher: selectedCustomer.value,
      products: selectedProducts,
      transactionType: AccountVoucherType.sale,
      status: selectedStatus,
    );

    addSaleTransaction(transaction: transaction);
  }

  Future<void> addSaleTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Saving your sale transaction...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet not connected';
      }

      if (!saleFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processTransactions(transactions: [transaction]);
      await clearSaleTransaction();

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Sale transaction added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> clearSaleTransaction() async {
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
    selectedSaleVoucher.value = AccountVoucherModel();
    selectedCustomer.value = AccountVoucherModel();
    selectedProducts.value = [];
    discountController.text = '';
    shippingController.text = '';
    date.text = DateTime.now().toIso8601String();
  }

  void resetValue(TransactionModel transaction) {
    transactionId.value = transaction.transactionId ?? 0;
    discountController.text = transaction.discount?.toString() ?? '';
    shippingController.text = transaction.shipping?.toString() ?? '';
    saleTotal.value = 0.0;
    date.text = transaction.date?.toIso8601String() ?? '';
    selectedSaleVoucher.value = transaction.fromAccountVoucher ?? AccountVoucherModel();
    selectedCustomer.value = transaction.toAccountVoucher ?? AccountVoucherModel();
    selectedProducts.value = transaction.products ?? [];
    selectedStatus = transaction.status ?? OrderStatus.inTransit;
    updateSaleTotal();
  }

  void saveUpdatedSaleTransaction({required TransactionModel oldSaleTransaction}) {
    TransactionModel newSaleTransaction = TransactionModel(
      id: oldSaleTransaction.id,
      transactionId: oldSaleTransaction.transactionId,
      discount: double.tryParse(discountController.text) ?? oldSaleTransaction.discount,
      shipping: double.tryParse(shippingController.text) ?? oldSaleTransaction.shipping,
      amount: saleTotal.value,
      date: DateTime.tryParse(date.text) ?? oldSaleTransaction.date,
      fromAccountVoucher: selectedSaleVoucher.value,
      toAccountVoucher: selectedCustomer.value,
      transactionType: oldSaleTransaction.transactionType,
      products: selectedProducts,
      status: selectedStatus,
    );

    updateTransaction(transaction: newSaleTransaction);
  }

  Future<void> updateTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating sale transaction...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet not connected';
      }

      if (!saleFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processUpdateTransaction(transaction: transaction);

      FullScreenLoader.stopLoading();
      await transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Sale transaction updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
