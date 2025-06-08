import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/transaction_model.dart';
import 'add_payment_controller.dart';

class TransactionController extends GetxController {

  // Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  RxList<TransactionModel> transactionsByEntity = <TransactionModel>[].obs;

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;

  // Fetch all transactions
  Future<void> getAllTransactions() async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.fetchAllTransactions(userId: userId, page: currentPage.value);
      transactions.addAll(fetchedTransactions);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshTransactions() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      transactions.clear(); // Clear existing transactions
      await getAllTransactions();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error: ', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get All products
  Future<void> getTransactionByEntity({required String voucherId}) async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.fetchTransactionByEntity(
          voucherId: voucherId,
          page: currentPage.value
      );
      transactionsByEntity.addAll(fetchedTransactions);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get All products
  Future<TransactionModel> getTransactionByPurchaseId({required int purchaseId}) async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.findTransactionByPurchaseId(purchaseId: purchaseId);
      return fetchedTransactions;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in purchase transactions', message: e.toString());
      return TransactionModel();
    }
  }

  Future<void> refreshTransactionByEntityId({required String voucherId}) async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      transactionsByEntity.clear(); // Clear existing orders
      await getTransactionByEntity(voucherId: voucherId);
    } catch (e) {
      AppMassages.warningSnackBar(title: 'Errors', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<TransactionModel> refreshTransactionBySale({required int orderNumber}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionBySale(orderNumber: orderNumber);
    } catch (e) {
      rethrow;
    }
  }

  // Get transaction by ID
  Future<TransactionModel> getTransactionByID({required String id}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionById(id: id);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error fetching transaction', message: e.toString());
      return TransactionModel();
    }
  }

  Future<void> processTransaction({required TransactionModel transaction}) async {
    try {
      // Fetch next transaction ID and check for conflicts
      final fetchedTransactionId = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: transaction.transactionType!);
      transaction.transactionId ??= fetchedTransactionId;
      await mongoTransactionRepo.pushTransaction(transaction: transaction);
    } catch(e) {
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction({required String id}) async {
    try {
      await mongoTransactionRepo.deleteTransaction(id: id);
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }

  Future<void> processUpdateTransaction({required TransactionModel transaction}) async {
    try{
      await mongoTransactionRepo.updateTransactionById(id: transaction.id!, transaction: transaction);
    } catch(e) {
      rethrow;
    }
  }

  Future<void> deleteTransactionByDialog({required String id, required BuildContext context}) async {
    try {
        DialogHelper.showDialog(
          context: context,
          title: 'Delete Transaction',
          message: 'Are you sure you want to delete this transaction?',
          onSubmit: () async {
            await deleteTransaction(id: id);
            await refreshTransactions();
            Navigator.pop(context);
          },
          toastMessage: 'Transaction deleted successfully!',
        );

    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> deleteTransactionByPurchaseId({required int purchaseId}) async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.findTransactionByPurchaseId(purchaseId: purchaseId);
      // await processTransaction(transaction: fetchedTransactions, isDelete: true);
    } catch (e) {
      rethrow;
    }
  }

}
