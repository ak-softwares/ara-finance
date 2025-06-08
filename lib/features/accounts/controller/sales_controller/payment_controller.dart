import 'dart:io';

import 'package:ara_finance/features/accounts/models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/orders/orders_repositories.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/order_model.dart';
import '../transaction/add_payment_controller.dart';
import '../transaction/transaction_controller.dart';
import 'sales_controller.dart';

class UpdatePaymentController extends GetxController {
  static UpdatePaymentController get instance => Get.find();

  RxBool isLoading = false.obs;
  // Store both order number and amount
  RxList<OrderModel> orders = <OrderModel>[].obs;
  Rx<UserModel> selectedCustomer = UserModel().obs;

  RxList<int> ordersNotFount = <int>[].obs;
  final addOrderTextEditingController = TextEditingController();

  final mongoOrderRepo = Get.put(MongoOrderRepo());
  final saleController = Get.put(SaleController());
  final transactionController = Get.put(TransactionController());

  UserModel get admin => AuthenticationController.instance.admin.value;

  void addCustomer(UserModel getSelectedCustomer) {
    selectedCustomer.value = getSelectedCustomer;
  }

  Future<void> pickCsvFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          await parseCsvFromFile(file.path!);
          AppMassages.showToastMessage(message: 'File imported successfully');
        } else {
          AppMassages.errorSnackBar(title: 'Error', message: 'Invalid file path');
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: 'Failed to pick file: ${e.toString()}');
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

  Future<void> parseCsvFromString(String csvString) async {
    try {
      isLoading(true);

      final csvTable = const CsvToListConverter(eol: '\n').convert(csvString);
      if (csvTable.isEmpty) return;

      // Extract header
      final headers = csvTable.first.cast<String>();

      final int orderNumberIndex = headers.indexOf('Order Number');

      if (orderNumberIndex == -1) {
        AppMassages.errorSnackBar(title: 'Error', message: 'Required "Order Number" columns not found in CSV.');
        return;
      }

      // Collect order numbers from CSV
      List<int> orderNumbers = [];

      // Process each data row
      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];

        if (row.length <= orderNumberIndex) continue;

        final orderNumber = int.tryParse(row[orderNumberIndex].toString().split('.')[0]); // remove scientific notation if any

        if (orderNumber == null) continue;

        final bool exists = orders.any((order) => order.orderId == orderNumber);
        if (!exists) {
          orderNumbers.add(orderNumber); // Only add if it doesn't exist
        }
      }

      if (orderNumbers.isEmpty) {
        AppMassages.errorSnackBar(title: 'Error', message: 'No valid order numbers found in CSV.');
        return;
      }

      // Fetch existing orders from database
      final List<OrderModel> fetchOrders = await mongoOrderRepo.fetchOrdersByIds(orderNumbers);
      orders.assignAll(fetchOrders);

      // Extract fetched order numbers
      final fetchedOrderNumbers = fetchOrders.map((order) => order.orderId).toSet();
      final notFoundOrderNumbers = orderNumbers.where((id) => !fetchedOrderNumbers.contains(id)).toList();
      ordersNotFount.assignAll(notFoundOrderNumbers);

    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: 'Failed to parse CSV: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }


  Future<void> addManualOrder() async {
    try {
      FullScreenLoader.onlyCircularProgressDialog('Adding Order...');
      final int manualOrderNumber = int.tryParse(addOrderTextEditingController.text) ?? 0;
      // Check if the order number exists in the list
      bool orderExists = orders.any((order) => order.orderId == manualOrderNumber);

      if (orderExists) {
        // Order already exists
        AppMassages.errorSnackBar(title: 'Duplicate', message: 'This order number already exists.');
      } else {
        HapticFeedback.mediumImpact();
        final OrderModel checkIsSaleExist = await saleController.getSaleByOrderId(orderId: manualOrderNumber);
        if(checkIsSaleExist.id == null) {
          throw 'Sale does not exist';
        }
        orders.insert(0, checkIsSaleExist);
      }
      AppMassages.showToastMessage(message: 'Sale added successfully');

    } catch(e){
      AppMassages.errorSnackBar(title: 'Error:', message: e.toString());
    } finally{
      FullScreenLoader.stopLoading();
    }
  }


  Future<void> updatePaymentStatus() async {
    try {
      isLoading(true);
      FullScreenLoader.onlyCircularProgressDialog('Fetching Order...');

      // Filter existingOrders that match the orderNumbers
      await processPaymentStatus(sales: orders);
      orders.clear();
      Get.back();
      AppMassages.showToastMessage(message: 'Payment updated successfully');
    }catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: 'Update failed: ${e.toString()}');
    } finally{
      FullScreenLoader.stopLoading();
      isLoading(false);
    }
  }

  Future<void> processPaymentStatus({required List<OrderModel> sales}) async {
    try {
      // Filter out orders that are already completed
      final pendingSales = sales
          .where((sale) => sale.status != OrderStatus.completed)
          .toList();

      // If no pending sales remain, exit early
      if (pendingSales.isEmpty) {
        throw('All orders are already completed. No transaction created.');
      }

      if (selectedCustomer.value.id == null) {
        throw('Please select customer');
      }

      // Calculate total amount from pending sales
      final totalAmount = pendingSales.fold(0.0, (sum, sale) => sum + (sale.total ?? 0.0));

      // Collect orderIds for the transaction
      final salesIds = pendingSales.map((sale) => sale.orderId).whereType<int>().toList();

      // Create the transaction model
      final transaction = TransactionModel(
        amount: totalAmount,
        date: DateTime.now(),
        userId: admin.id,

      );

      // Process the transaction
      final transactionId = await transactionController.processTransaction(transaction: transaction);
      for (var sale in pendingSales) {
        sale.transaction = transaction;
      }      // Update the status of only pending orders
      final Map<String, dynamic> data = {
        OrderFieldName.status: OrderStatus.completed.name,
        OrderFieldName.datePaid: DateTime.now(),
        OrderFieldName.transaction: transaction.toMap(),
      };

      await mongoOrderRepo.updateOrders(orders: pendingSales, updatedData: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reversePaymentStatus({required OrderModel sale}) async {
    try {
      final Map<String, dynamic> data = {
        OrderFieldName.transaction: TransactionModel(),
        OrderFieldName.status: OrderStatus.inTransit.name,
      };

      // Delete the transaction
      await transactionController.processTransaction(transaction: sale.transaction!);
      await mongoOrderRepo.updateOrders(orders: [sale], updatedData: data);

    } catch (e) {
      rethrow;
    }
  }
}