import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/cart_item_model.dart';
import '../../models/transaction_model.dart';
import '../product/product_controller.dart';
import 'payment/add_payment_controller.dart';

class TransactionController extends GetxController {

  // Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final productController = Get.put(ProductController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  Future<List<TransactionModel>> getTransactionsByDate({
    required DateTime startDate,
    required DateTime endDate,
    AccountVoucherType? voucherType,
  }) async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.fetchTransactionsByDate(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
        voucherType: voucherType,
        page: currentPage.value
      );
      return fetchedTransactions;
    }catch(e) {
      rethrow;
    }
  }

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

  // Get transaction by ID
  Future<TransactionModel> getTransactionByID({required String id}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionById(id: id);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error fetching transaction', message: e.toString());
      return TransactionModel();
    }
  }

  // Get transaction Id
  Future<TransactionModel> getTransactionByTransactionId({required int transactionId, required AccountVoucherType voucherType}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionWithFilter(filter: {
        TransactionFieldName.userId: userId,
        TransactionFieldName.transactionId: transactionId,
        TransactionFieldName.transactionType: voucherType.name
      });
    } catch (e) {
      return TransactionModel();
    }
  }

  // Get transaction Id
  Future<TransactionModel> getTransactionByOrderId({required int orderId, required AccountVoucherType voucherType}) async {
    try {
      return await mongoTransactionRepo.fetchTransactionWithFilter(
          filter: {
            TransactionFieldName.userId: userId,
            TransactionFieldName.orderIds: orderId,
            TransactionFieldName.transactionType: voucherType.name
          }
      );
    } catch (e) {
      return TransactionModel();
    }
  }

  Future<List<TransactionModel>> getTransactionByOrderIds({
    required List<int> orderIds,
    required AccountVoucherType voucherType,
  }) async {
    try {
      final List<TransactionModel> transactions =
      await mongoTransactionRepo.fetchTransactionsWithFilter(
        filter: {
          TransactionFieldName.userId: userId,
          TransactionFieldName.transactionType: voucherType.name,
          TransactionFieldName.orderIds: {r'$in': orderIds},
        },
      );
      return transactions;
    } catch (e) {
      return [];
    }
  }

  Future<List<TransactionModel>> getTransactionByStatus({required OrderStatus status}) async {
    try {
      final List<TransactionModel> transactions = await mongoTransactionRepo.fetchTransactionsWithFilter(
        filter: {
          TransactionFieldName.userId: userId,
          TransactionFieldName.transactionType: AccountVoucherType.sale.name,
          TransactionFieldName.status: status.name,
        },
      );
      return transactions;
    } catch (e) {
      return [];
    }
  }

  Future<void> processTransactions({required List<TransactionModel> transactions}) async {
    try {
      await mongoTransactionRepo.pushTransactions(transactions: transactions);
    } catch(e) {
      rethrow;
    } finally {
      if(transactions.first.transactionType == AccountVoucherType.purchase) {
        await updatePriceVendorAndDate(transactions: transactions);
      }
    }
  }

  Future<void> updatePriceVendorAndDate({required List<TransactionModel> transactions}) async {
    try {
      final List<CartModel> products = transactions.expand((transaction) => transaction.products!).toList();
      if(products.isNotEmpty) {
          for (var product in products) {
            product.vendor = transactions.first.fromAccountVoucher;
          }
          await productController.updateVendorAndPurchasePriceById(cartItems: products);
      }
    }catch(e){
      rethrow;
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction({required TransactionModel transaction}) async {
    try {
      await mongoTransactionRepo.deleteTransaction(id: transaction.id ?? '');
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

  Future<void> deleteTransactionByDialog({required TransactionModel transaction, required BuildContext context}) async {
    try {
        DialogHelper.showDialog(
          context: context,
          title: 'Delete Transaction',
          message: 'Are you sure you want to delete this transaction?',
          onSubmit: () async {
            await deleteTransaction(transaction: transaction);
            await refreshTransactions();
            Navigator.pop(context);
          },
          toastMessage: 'Transaction deleted successfully!',
        );

    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> updateTransactions({required List<String> ids, required Map<String, dynamic> updatedData}) async {
    try{
      await mongoTransactionRepo.updateTransactions(
          ids: ids,
          updatedData: updatedData
      );
    }catch(e){
      rethrow;
    }
  }

}
