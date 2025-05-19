import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';

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
      AppMassages.errorSnackBar(title: 'Error in vendors transactions', message: e.toString());
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

  // Get transaction by ID
  Future<TransactionModel> getTransactionByID({required String id}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionById(id: id);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error fetching transaction', message: e.toString());
      return TransactionModel();
    }
  }

  Future<void> deleteTransactionByDialog({required TransactionModel transaction, required BuildContext context}) async {
    try {
      transaction.transactionType == TransactionType.purchase
      ? DialogHelper.showDialog(
        context: context,
        title: 'Error in Delete Transaction',
        message: 'You can not delete purchase transactions instead you can delete that purchase '
            'this transaction will delete automatically',
        onSubmit: () async { },
        actionButtonText: 'Done',
      )
      : DialogHelper.showDialog(
        context: context,
        title: 'Delete Transaction',
        message: 'Are you sure you want to delete this transaction?',
        onSubmit: () async {
          // Reverse balance updates
          // await processTransaction(transaction: transaction, isDelete: true);
          Navigator.pop(context);
        },
        toastMessage: 'Deleted successfully!',
      );
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
