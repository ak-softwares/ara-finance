import 'dart:io';

import 'package:ara_finance/features/accounts/models/transaction_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:csv/csv.dart';

import '../../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/db_constants.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../models/account_voucher_model.dart';
import '../transaction_controller.dart';

class AddBulkReceiptController extends GetxController {
  static AddBulkReceiptController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.receipt;
  RxBool isLoading = false.obs;
  final addOrderTextEditingController = TextEditingController();

  RxList<TransactionModel> receiptSales = <TransactionModel>[].obs;
  RxList<int> ordersNotFount = <int>[].obs;


  // Store both order number and amount
  Rx<AccountVoucherModel> selectedBankAccount = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> selectedCustomer = AccountVoucherModel().obs;

  final transactionController = Get.put(TransactionController());
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;

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

        final bool exists = receiptSales.any((order) => order.orderIds?.contains(orderNumber) ?? false);
        if (!exists) {
          orderNumbers.add(orderNumber); // Only add if it doesn't exist
        }
      }

      if (orderNumbers.isEmpty) {
        AppMassages.errorSnackBar(title: 'Error', message: 'No valid order numbers found in CSV.');
        return;
      }

      // Fetch existing orders from database
      final List<TransactionModel> fetchSales = await transactionController.getTransactionByOrderIds(orderIds: orderNumbers, voucherType: voucherType);
      receiptSales.assignAll(fetchSales);

      // Extract fetched order numbers
      final fetchedOrderNumbers = fetchSales.map((sale) => sale.orderIds?.first).toSet();
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
      await processAddReceipt(orderNumber: manualOrderNumber);
      AppMassages.showToastMessage(message: 'Sale added successfully');
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error:', message: e.toString());
    } finally{
      FullScreenLoader.stopLoading();
    }
  }

  Future<void> processAddReceipt({required int orderNumber}) async {
    try{
      // 1. Check if order already exists in local list
      final bool exists = receiptSales.any((order) => order.orderIds?.first == orderNumber);
      if (exists) throw 'This order number already exists.';

      HapticFeedback.mediumImpact();

      final TransactionModel checkIsSaleExist = await transactionController.getTransactionByOrderId(
          orderId: orderNumber, voucherType: AccountVoucherType.sale);
      if(checkIsSaleExist.id == null) {
        throw 'Sale does not exist';
      } else if(checkIsSaleExist.status == OrderStatus.completed) {
        throw 'Payment already done';
      }
      receiptSales.insert(0, checkIsSaleExist);
    }catch(e){
      rethrow;
    }
  }

  Future<void> pushBulkReceipt({required List<TransactionModel> newReceiptSales}) async {
    try {
      isLoading(true);
      FullScreenLoader.onlyCircularProgressDialog('Adding Receipts...');
      // Filter out orders that are already completed
      final List<TransactionModel> pendingSales = newReceiptSales
          .where((sale) => sale.status != OrderStatus.completed)
          .toList();

      // If no pending sales remain, exit early
      if (pendingSales.isEmpty) {
        throw('All orders are already completed. No transaction created.');
      }

      if (selectedBankAccount.value.id == null) {
        throw 'Plz select bank account';
      }
      if (selectedCustomer.value.id == null) {
        throw 'Plz select customer voucher';
      }

      // Calculate total amount from pending sales
      final totalAmount = pendingSales.fold(0.0, (sum, sale) => sum + (sale.amount ?? 0.0));

      // Collect orderIds for the transaction
      final List<int> salesIds = pendingSales.expand((sale) => (sale.orderIds ?? []).map((e) => e)).toList();

      final transactionId = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);

      TransactionModel transaction = TransactionModel(
        userId: userId,
        transactionId: transactionId,
        amount: totalAmount,
        date: DateTime.now(),
        orderIds: salesIds,
        fromAccountVoucher: selectedCustomer.value,
        toAccountVoucher: selectedBankAccount.value,
        transactionType: voucherType,
      );
      await transactionController.processTransactions(transactions: [transaction]);

      final List<String> ids = pendingSales.map((e) => e.id).whereType<String>().toList();

      final Map<String, dynamic> updatedData = {
        TransactionFieldName.status: OrderStatus.completed.name,
        TransactionFieldName.datePaid: DateTime.now(),
      };
      await transactionController.updateTransactions(ids: ids, updatedData: updatedData);
      receiptSales.clear();
      Get.back();
      AppMassages.showToastMessage(message: 'Payment updated successfully');
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: 'Update failed: ${e.toString()}');
    } finally{
      FullScreenLoader.stopLoading();
      isLoading(false);
    }
  }
}