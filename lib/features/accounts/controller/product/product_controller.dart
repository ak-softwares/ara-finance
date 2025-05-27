import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/products/product_repositories.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/cart_item_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';

class ProductController extends GetxController{
  static ProductController get instance => Get.find();

  // Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxInt totalProducts = 0.obs;
  RxInt totalActiveProducts = 0.obs;
  RxInt totalStockValue = 0.obs;

  RxList<ProductModel> products = <ProductModel>[].obs;

  final mongoProductRepo = Get.put(MongoProductRepo());
  final auth = Get.put(AuthenticationController());

  // Get All products
  Future<void> getAllProducts() async {
    try {
      final String uid = await auth.getUserId();
      final fetchedProducts = await mongoProductRepo.fetchProducts(userId: uid, page: currentPage.value);
      products.addAll(fetchedProducts);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
    }
  }

  Future<void> refreshProducts() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      totalProducts.value = 0;
      totalStockValue.value = 0;
      products.clear(); // Clear existing orders
      await getAllProducts();
      await getTotalProductsCount();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> getTotalProductsCount() async {
    try {
      final String uid = await auth.getUserId();
      totalProducts.value = await mongoProductRepo.fetchProductsCount(userId: uid);
      totalActiveProducts.value = await mongoProductRepo.fetchProductsActiveCount(userId: uid);
      totalStockValue.value = (await mongoProductRepo.fetchTotalStockValue(userId: uid)).toInt();
      update(); // Notify listeners that counts changed
    } catch (e) {
      AppMassages.warningSnackBar(title: 'Errors', message: 'Failed to fetch product counts: ${e.toString()}');
    }
  }

  // Get Product by ID
  Future<ProductModel> getProductByID({required String id}) async {
    try {
      final fetchedProduct = await mongoProductRepo.fetchProductById(id: id);
      return fetchedProduct;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in getting product', message: e.toString());
      return ProductModel.empty(); // Return an empty product model in case of failure
    }
  }

  Future<double> getTotalStockValue() async {
    try {
      final String uid = await auth.getUserId();
      final double totalStockValue = await mongoProductRepo.fetchTotalStockValue(userId: uid);
      return totalStockValue;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCogsDetailsByProductIds({required List<int> productIds}) async {
    try {
      final List<Map<String, dynamic>> totalStockValue = await mongoProductRepo.fetchCogsDetailsByProductIds(productIds: productIds);
      return totalStockValue;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductQuantity({
    required List<CartModel> cartItems,
    List<CartModel>? previousCartItems,
    bool? isUpdate,
    bool isAddition = false,
    bool isPurchase = false
  }) async {
    try {
      if((isUpdate ?? false) && (previousCartItems != null)) {
        if (cartItems.isEmpty && previousCartItems.isEmpty) {
          throw Exception("Product list is empty. Cannot update quantity.");
        }
        final List<CartModel> updatedProducts = (cartItems).map((currentProduct) {
          final previousProduct = previousCartItems.firstWhere(
                (item) => item.productId == currentProduct.productId,
            orElse: () => CartModel(productId: currentProduct.productId, quantity: 0),
          );

          int previousQty = int.tryParse(previousProduct.quantity.toString()) ?? 0;
          int currentQty = int.tryParse(currentProduct.quantity.toString()) ?? 0;

          return currentProduct.copyWith(quantity: currentQty - previousQty);
        }).toList();
        await mongoProductRepo.updateQuantities(cartItems: updatedProducts, isAddition: isAddition, isPurchase: isPurchase);

      } else{
        if (cartItems.isEmpty) {
          throw Exception("Product list is empty. Cannot update quantity.");
        }
        // Convert CartModel list to PurchaseHistory list
        await mongoProductRepo.updateQuantities(cartItems: cartItems, isAddition: isAddition, isPurchase: isPurchase);
      }
    } catch (e) {
      rethrow; // Preserve original exception
    }
  }

  Future<void> updateProductQuantityById({required List<CartModel> cartItems, bool isAddition = false, bool isPurchase = false}) async {
    try {
        if (cartItems.isEmpty) {
          throw Exception("Product list is empty. Cannot update quantity.");
        }
        await mongoProductRepo.updateQuantitiesById(cartItems: cartItems, isAddition: isAddition, isPurchase: isPurchase);
    } catch (e) {
      rethrow; // Preserve original exception
    }
  }

  // Delete Product
  Future<void> deleteProduct({required String id, required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
        context: context,
        title: 'Delete Product',
        message: 'Are you sure you want to delete this product?',
        onSubmit: () async {
          await mongoProductRepo.deleteProduct(id: id);
          await refreshProducts();
          Get.back();
        },
        toastMessage: 'Product deleted successfully!',
      );
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // This function converts a productModel to a cartItemModel
  CartModel convertProductToCart({
    required ProductModel product, required int quantity, int variationId = 0, double? purchasePrice}) {
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
      purchasePrice: purchasePrice ?? product.purchasePrice,
      image: product.mainImage,
      parentName: '0',
      isCODBlocked: product.isCODBlocked,
    );
  }

}
