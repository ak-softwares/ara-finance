import 'dart:io';

import 'package:ara_finance/features/accounts/models/transaction_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/orders/orders_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/order_model.dart';
import '../transaction/add_transaction_controller.dart';
import 'sales_controller.dart';

class UpdatePaymentController extends GetxController {
  static UpdatePaymentController get instance => Get.find();

  RxBool isLoading = false.obs;
  RxBool isAdding = false.obs;
  // Store both order number and amount
  RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;
  RxList<OrderModel> existingOrders = <OrderModel>[].obs;
  final addOrderTextEditingController = TextEditingController();

  final mongoOrderRepo = Get.put(MongoOrderRepo());
  final saleController = Get.put(SaleController());
  final addTransactionController = Get.put(AddTransactionController());

  UserModel get admin => AuthenticationController.instance.admin.value;

  Future<void> parseCsvFromString(String csvString) async {
    try {
      isLoading(true);

      final csvTable = const CsvToListConverter().convert(csvString);

      // Assuming first row is header, skip it
      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length > 9) {
          final int orderNumber = row[9];
          final int amount = row[4];
          // Check if order already exists
          final existingIndex = orders.indexWhere((order) => order['orderNumber'] == orderNumber);

          if (existingIndex != -1) {
            // Update existing order
            orders[existingIndex]['amount'] = amount;
          } else {
            orders.add({
              'orderNumber': orderNumber,
              'amount': amount,
            });
          }
        }
      }
      final orderNumbers = orders.map((order) => order['orderNumber'] as int).toList();

      // Fetch existing orders from the database
      final List<OrderModel> fetchOrders = await mongoOrderRepo.fetchOrdersByIds(orderNumbers);
      existingOrders.assignAll(fetchOrders);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: 'Failed to parse CSV: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> parseCsvFromFile(String filePath) async {
    try {
      isLoading(true);
      final csvFile = File(filePath);
      final csvString = await csvFile.readAsString();
      await parseCsvFromString(csvString);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: 'Failed to read file: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> addManualOrder() async {
    try {
      isAdding(true);
      final int manualOrderNumber = int.tryParse(addOrderTextEditingController.text) ?? 0;
      final orderNumbers = orders.map((order) => order['orderNumber'] as int).toList();
      if (orderNumbers.contains(manualOrderNumber)) {
        // Order already exists
        AppMassages.errorSnackBar(title: 'Duplicate', message: 'This order number already exists.');
      } else {
        HapticFeedback.mediumImpact();
        final OrderModel checkIsSaleExist = await saleController.getSaleByOrderId(orderId: manualOrderNumber);
        if(checkIsSaleExist.id == null) {
          throw 'Sale does not exist';
        }
        existingOrders.add(checkIsSaleExist);
        final manualOrder = {
          'orderNumber': checkIsSaleExist.orderId,
          'amount': checkIsSaleExist.total?.toInt(),
        };
        orders.add(manualOrder);
      }
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: 'Add manual order failed: ${e.toString()}');
    } finally{
      isAdding(false);
    }
  }


  Future<void> updatePaymentStatus() async {
    try {
      isLoading(true);
      // Extract order numbers from the orders list
      final orderNumbers = orders.map((order) => order['orderNumber'] as int).toList();

      // Filter existingOrders that match the orderNumbers
      final filteredOrders = existingOrders.where((order) => orderNumbers.contains(order.orderId)).toList();
      await processPaymentStatus(sales: filteredOrders);
      await mongoOrderRepo.updateOrdersStatus(orders: filteredOrders, newStatus: OrderStatus.completed,);
    }catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: 'Update failed: ${e.toString()}');
    } finally{
      isLoading(false);
    }
  }

  Future<void> processPaymentStatus({required List<OrderModel> sales}) async {
    try {
      // Filter existingOrders that match the orderNumbers
      final totalAmount = sales.fold(0.0, (sum, sale) => sum + (sale.total ?? 0.0));
      final transaction = TransactionModel(
          amount: totalAmount,
          date: DateTime.now(),
          userId: admin.id,
          toEntityId: admin.selectedAccount?.id,
          toEntityName: admin.selectedAccount?.accountName,
          toEntityType: EntityType.customer,
          transactionType: TransactionType.sale
      );
      final transactionId = await addTransactionController.processTransaction(transaction: transaction);
      await mongoOrderRepo.updateOrdersStatus(orders: sales, newStatus: OrderStatus.completed);
    }catch(e){
      rethrow;
    }
  }
}