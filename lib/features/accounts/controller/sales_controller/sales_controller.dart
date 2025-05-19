import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/orders/orders_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/order_model.dart';
import '../product/product_controller.dart';

class SaleController extends GetxController {
  static SaleController get instance => Get.find();

  // Variable
  final OrderType orderType = OrderType.sale;
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<OrderModel> sales = <OrderModel>[].obs;
  final mongoOrderRepo = Get.put(MongoOrderRepo());
  final productController = Get.put(ProductController());
  final auth = Get.put(AuthenticationController());


  // Get All Sale
  Future<void> getSales() async {
    try {
      final String uid = await auth.getUserId();
      final fetchedOrders = await mongoOrderRepo.fetchOrders(
          orderType: orderType, userId: uid, page: currentPage.value);
      sales.addAll(fetchedOrders);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Orders Fetching', message: e.toString());
    }
  }

  Future<void> refreshSales() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      sales.clear(); // Clear existing orders
      await getSales();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get user order by id
  Future<OrderModel> getSaleById({required String saleId}) async {
    try {
      final newSale = await mongoOrderRepo.fetchOrderById(saleId: saleId);
      return newSale;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrderModel>> getSalesByDate({required DateTime startDate, required DateTime endDate}) async {
    try {
      final String uid = await auth.getUserId();
      final fetchedOrders = await mongoOrderRepo
          .fetchOrdersByDate(orderType: orderType, userId: uid, startDate: startDate, endDate: endDate);
      return fetchedOrders;
    } catch (e) {
      rethrow;
    }
  }

  // Get user order by id
  Future<OrderModel> getSaleByOrderId({required int orderId}) async {
    try {
      final newSale = await mongoOrderRepo.fetchOrderByOrderId(orderId: orderId, orderType: orderType);
      return newSale;
    } catch (e) {
      return OrderModel();
    }
  }

  // Get user order by id
  Future<List<OrderModel>> getSaleByOrderIds({required List<int> orderIds}) async {
    try {
      final List<OrderModel> newSales = await mongoOrderRepo.fetchOrdersByIds(orderIds);
      return newSales;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSale({required OrderModel sale, required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
          context: context,
          title: 'Delete Sale',
          message: 'Are you sure to delete this Sale?',
          actionButtonText: 'Delete',
          toastMessage: 'Sale deleted successfully!',
          onSubmit: () async {
            if(sale.status != OrderStatus.returned){
              // Reverse product quantities before deleting the sale
              await productController.updateProductQuantity(cartItems: sale.lineItems ?? [], isAddition: true);
            }
            // Delete sale record
            await mongoOrderRepo.deleteOrderById(id: sale.id ?? '');
            // Refresh sale list
            await refreshSales();
            // Close the current screen after successful deletion
            Get.back();
          },
      );
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> updatePaymentStatus({required OrderModel sale}) async {
    try{
      final OrderModel newSale = OrderModel(
        id: sale.id,
        setPaid: true,
        status: OrderStatus.completed,
        datePaid: DateTime.now(),
      );
      await mongoOrderRepo.updateOrder(order: newSale);
      // Update in RxList
      final index = sales.indexWhere((c) => c.id == newSale.id);
      if (index != -1) {
        sales[index].status = OrderStatus.completed;
      }
      await refreshSales();

    }catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> revertPaymentStatus({required OrderModel sale}) async {
    try {
      final OrderModel revertedSale = OrderModel(
        id: sale.id,
        setPaid: false,
        status: OrderStatus.inTransit, // or use original status if needed
      );

      await mongoOrderRepo.updateOrder(order: revertedSale);

      // Update in RxList
      final index = sales.indexWhere((c) => c.id == sale.id);
      if (index != -1) {
        sales[index].status = OrderStatus.inTransit;
      }
      await refreshSales();
      AppMassages.showSnackBar(massage: 'Undo successful');
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

}