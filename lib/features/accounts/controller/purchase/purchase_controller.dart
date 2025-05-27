import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/image_kit/image_kit_repo.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../models/image_model.dart';
import '../product/product_controller.dart';

import '../../../../data/repositories/mongodb/orders/orders_repositories.dart';
import '../../../../data/repositories/woocommerce/orders/woo_orders_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../models/order_model.dart';
import '../transaction/add_transaction_controller.dart';

class PurchaseController extends GetxController {
  static PurchaseController get instance => Get.find();

  // Variables
  final OrderType orderType = OrderType.purchase;
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<OrderModel> purchases = <OrderModel>[].obs;
  final ImageKitService imageKitService = ImageKitService();

  final auth = Get.put(AuthenticationController());
  final mongoOrderRepo = Get.put(MongoOrderRepo());
  final wooOrdersRepository = Get.put(WooOrdersRepository());
  final productController = Get.put(ProductController());
  final userController = Get.put(UserController());
  final addTransactionController = Get.put(AddTransactionController());

  Future<void> getPurchases() async {
    try {
      final String uid = await auth.getUserId();
      final fetchedOrders = await mongoOrderRepo
          .fetchOrders(orderType: orderType, userId: uid, page: currentPage.value);
      purchases.addAll(fetchedOrders);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Orders Fetching', message: e.toString());
    }
  }

  Future<void> refreshPurchases() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      purchases.clear();
      await getPurchases();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<OrderModel> getPurchaseById({required String purchaseId}) async {
    try {
      return await mongoOrderRepo.fetchOrderById(saleId: purchaseId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmDeletePurchaseDialog({
    required OrderModel purchase,
    required BuildContext context,
  }) async {
    DialogHelper.showDialog(
      context: context,
      title: 'Delete Purchase',
      message: 'Are you sure to delete this purchase?',
      actionButtonText: 'Delete',
      toastMessage: 'Purchase deleted successfully!',
      onSubmit: () async {
        await performDeletePurchase(purchase: purchase);
        Get.back(); // Close dialog
      },
    );
  }

  Future<void> performDeletePurchase({required OrderModel purchase}) async {
    try {
      await Future.wait([
        deleteImages(purchase.purchaseInvoiceImages ?? []),
        productController.updateProductQuantityById(cartItems: purchase.lineItems ?? []),
        addTransactionController.processTransaction(transaction: purchase.transaction!, isDelete: true),
        mongoOrderRepo.deleteOrderById(id: purchase.id ?? ''),
        refreshPurchases(),
      ]);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> deleteImages(List<ImageModel> images) async {
    try {

      // Collect all valid imageIds
      List<String> imageIds = images
          .where((image) => image.imageId != null && image.imageId!.isNotEmpty)
          .map((image) => image.imageId!)
          .toList();

      if (imageIds.isNotEmpty) {
        // Bulk delete using the new deleteImages function
        await imageKitService.deleteImages(imageIds);

        AppMassages.showToastMessage(message: 'Images deleted successfully');
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error Deleting Images', message: e.toString());
    }
  }

  Future<List<OrderModel>> getPurchasesByDate({required DateTime startDate, required DateTime endDate}) async {
    try {
      final String uid = await auth.getUserId();
      final fetchedOrders = await mongoOrderRepo
          .fetchOrdersByDate(orderType: orderType, userId: uid, startDate: startDate, endDate: endDate);
      return fetchedOrders;
    } catch (e) {
      rethrow;
    }
  }

}
