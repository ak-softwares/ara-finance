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
  Future<void> getTransactionByEntity({required EntityType entityType, required String entityId}) async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.fetchTransactionByEntity(
          entityType: entityType,
          entityId: entityId,
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

  Future<void> refreshTransactionByEntityId({required EntityType entityType, required String entityId}) async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      transactionsByEntity.clear(); // Clear existing orders
      await getTransactionByEntity(entityType: entityType, entityId: entityId);
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

  Future<String?> processTransaction({
    required TransactionModel transaction,
    bool isDelete = false,
    bool isUpdated = false,
  }) async {
    try{
      List<Future<void>> futures = [];
      if (transaction.fromEntityType != null) {
        // Create update requests
        Future<void> updateFromEntity = mongoTransactionRepo.updateBalanceById(
          collectionName: transaction.fromEntityType?.dbName ?? '',
          entityId: transaction.fromEntityId ?? '',
          amount: transaction.amount ?? 0,
          isAddition: isDelete ? true : false, // Set to true for addition, false for subtraction
        );
        futures.add(updateFromEntity);
      }

      if (transaction.toEntityType != null) {
        // Create update requests
        Future<void> updateToEntity = mongoTransactionRepo.updateBalanceById(
          collectionName: transaction.toEntityType?.dbName ?? '',
          entityId: transaction.toEntityId ?? '',
          amount: transaction.amount ?? 0,
          isAddition: isDelete ? false : true, // Set to true for addition, false for subtraction
        );
        futures.add(updateToEntity);
      }
      if(isDelete) {
        futures.add(mongoTransactionRepo.deleteTransaction(id: transaction.id ?? ''));
      }else if(isUpdated){
        futures.add(mongoTransactionRepo.pushTransaction(transaction: transaction));
      } else{
        // Fetch next transaction ID and check for conflicts
        final fetchedTransactionId = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId);
        transaction.transactionId ??= fetchedTransactionId;
        final String transactionId  = await mongoTransactionRepo.pushTransaction(transaction: transaction);
        return transactionId;
      }

      await Future.wait(futures);

    } catch(e) {
      rethrow;
    }
    return null;
  }

  Future<void> processUpdateTransaction({required TransactionModel newTransaction, required TransactionModel oldTransaction}) async {
    try{
      List<Future<void>> futures = [];

      futures.add(processTransaction(transaction: oldTransaction, isDelete: true));
      futures.add(processTransaction(transaction: newTransaction, isUpdated: true));

      await Future.wait(futures);

    } catch(e) {
      rethrow;
    }
  }

  List<TransactionType> getNonDeletableTransactionTypes() {
    return [TransactionType.purchase, TransactionType.sale];
  }

  Future<void> deleteTransactionByDialog({
    required TransactionModel transaction,
    required BuildContext context,
  }) async {
    try {
      final nonDeletableTypes = getNonDeletableTransactionTypes();

      if (nonDeletableTypes.contains(transaction.transactionType)) {
        DialogHelper.showDialog(
          context: context,
          title: 'Error in Delete ${transaction.transactionType?.name} Transaction',
          message: 'You cannot delete ${transaction.transactionType?.name} transactions. '
              'Instead, delete the related entry and this transaction will be removed automatically.',
          onSubmit: () async {},
          actionButtonText: 'Done',
        );
        return;
      } else {
        // Default delete confirmation for other transaction types
        DialogHelper.showDialog(
          context: context,
          title: 'Delete Transaction',
          message: 'Are you sure you want to delete this transaction?',
          onSubmit: () async {
            await processTransaction(transaction: transaction, isDelete: true);
            refreshTransactions();
            Navigator.pop(context);
          },
          toastMessage: 'Transaction deleted successfully!',
        );
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
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
