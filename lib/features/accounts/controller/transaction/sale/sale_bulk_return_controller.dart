import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/db_constants.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../models/account_voucher_model.dart';
import '../../../models/transaction_model.dart';
import '../../product/product_controller.dart';
import '../transaction_controller.dart';

class AddBulkReturnController extends GetxController {
  static AddBulkReturnController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.creditNote;
  RxBool isLoading = false.obs;
  RxBool isScanning = false.obs;

  RxList<TransactionModel> returns = <TransactionModel>[].obs;
  Rx<AccountVoucherModel> selectedSaleVoucher = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> selectedCustomer = AccountVoucherModel().obs;

  final returnOrderTextEditingController = TextEditingController();

  final productController = Get.put(ProductController());
  final transactionController = Get.put(TransactionController());
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  final MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
    formats: [BarcodeFormat.all],
  );

  Future<void> handleDetection(BarcodeCapture capture) async {
    if (isScanning.value) return;
    try {
      FullScreenLoader.onlyCircularProgressDialog('Fetching Order...');
      isScanning.value = true;

      for (final barcode in capture.barcodes) {
        final orderNumber = int.tryParse(barcode.rawValue ?? '') ?? 0;
        await processAddReturn(orderNumber: orderNumber);
      }
      Future.delayed(const Duration(seconds: 2), () {
        isScanning.value = false;
      });
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Order Fetching', message: e.toString());
    } finally {
      FullScreenLoader.stopLoading();
    }
  }


  Future<void> addManualReturn() async {
    try {
      isScanning(true);
      FullScreenLoader.onlyCircularProgressDialog('Fetching Order...');
      final int manualOrderNumber = int.tryParse(returnOrderTextEditingController.text) ?? 0;
      await processAddReturn(orderNumber: manualOrderNumber);
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: 'Add manual order failed: ${e.toString()}');
    } finally{
      FullScreenLoader.stopLoading();
      isScanning(false);
    }
  }


  Future<void> processAddReturn({required int orderNumber}) async {
    try{
      // 1. Check if order already exists in local list
      final bool exists = returns.any((order) => order.orderIds?.first == orderNumber);
      if (exists) throw 'This order number already exists.';

      HapticFeedback.mediumImpact();

      final TransactionModel checkIsSaleExist = await transactionController.getTransactionByOrderId(
          orderId: orderNumber, voucherType: AccountVoucherType.sale);
      if(checkIsSaleExist.id == null) {
        throw 'Sale does not exist';
      } else if(checkIsSaleExist.status == OrderStatus.returned) {
        throw 'Sale already return';
      }
      returns.insert(0, checkIsSaleExist);
    }catch(e){
      rethrow;
    }
  }

  Future<void> pushBulkReturn({required List<TransactionModel> newReturnSales}) async {
    try {
      isLoading(true);
      FullScreenLoader.onlyCircularProgressDialog('Adding Returns...');

      if (selectedSaleVoucher.value.id == null) {
        throw 'Plz select bank account';
      }
      if (selectedCustomer.value.id == null) {
        throw 'Plz select customer voucher';
      }

      // Collect orderIds for the transaction
      final List<int> salesIds = newReturnSales.expand((sale) => (sale.orderIds ?? []).map((e) => e)).toList();

      // Calculate total amount from pending sales
      final totalAmount = newReturnSales.fold(0.0, (sum, sale) => sum + (sale.amount ?? 0.0));

      final transactionId = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);

      TransactionModel transaction = TransactionModel(
        userId: userId,
        transactionId: transactionId,
        amount: totalAmount,
        date: DateTime.now(),
        orderIds: salesIds,
        fromAccountVoucher: selectedCustomer.value,
        toAccountVoucher: selectedSaleVoucher.value,
        transactionType: voucherType,
      );
      await transactionController.processTransactions(transactions: [transaction]);

      final List<String> ids = newReturnSales.map((e) => e.id).whereType<String>().toList();

      final Map<String, dynamic> updatedData = {
        TransactionFieldName.status: OrderStatus.returned.name,
        TransactionFieldName.dateReturned: DateTime.now(),
      };

      await transactionController.updateTransactions(ids: ids, updatedData: updatedData);
      newReturnSales.clear();
      Get.back();
      AppMassages.showToastMessage(message: 'Returned updated successfully');
    } catch(e){
      AppMassages.errorSnackBar(title: 'Error', message: 'Update failed: ${e.toString()}');
    } finally{
      FullScreenLoader.stopLoading();
      isLoading(false);
    }
  }

}