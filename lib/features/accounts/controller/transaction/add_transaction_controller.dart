import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';

class AddTransactionController extends GetxController {

  RxInt transactionId = 0.obs;


  Rx<UserModel> selectedVendor = UserModel().obs;
  Rx<AccountModel> selectedPaymentMethod = AccountModel().obs;

  final amount = TextEditingController();
  final date = TextEditingController();
  GlobalKey<FormState> transactionFormKey = GlobalKey<FormState>();

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    date.text = DateTime.now().toIso8601String(); // Store in ISO format
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId);
  }


  void addVendor(UserModel getSelectedVendor) {
    selectedVendor.value = getSelectedVendor;
  }

  void selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      date.text = pickedDate.toIso8601String(); // Store as ISO format
      update(); // Ensure UI update
    }
  }

  // Save new transaction
  void saveTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      amount: double.tryParse(amount.text) ?? 0.0,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      fromEntityId: selectedPaymentMethod.value.id, // Example vendor ID
      fromEntityName: selectedPaymentMethod.value.accountName, // Example vendor ID
      fromEntityType: EntityType.account,
      toEntityId: selectedVendor.value.id,
      toEntityName: selectedVendor.value.companyName,
      toEntityType: EntityType.vendor,
      transactionType: TransactionType.payment,
    );

    addTransaction(transaction: transaction);
  }

  // Upload transaction
  Future<void> addTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating your transaction...', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      // Form Validation
      if (!transactionFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await processTransaction(transaction: transaction);

      clearTransaction();

      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Transaction uploaded successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      debugPrint('Error adding transaction: $e');
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
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


  Future<void> clearTransaction() async {
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId);
    amount.text = '';
    date.text = DateTime.now().toIso8601String();
  }

  // Reset fields before editing transaction
  void resetValue(TransactionModel transaction) {
    transactionId.value = transaction.transactionId ?? 0;
    amount.text = transaction.amount.toString();
    date.text = transaction.date?.toIso8601String() ?? '';
  }

  void saveUpdatedTransaction({required TransactionModel previousTransaction}) {

    TransactionModel transaction = TransactionModel(
      id: previousTransaction.id,
      transactionId: previousTransaction.transactionId,
      amount: double.tryParse(amount.text) ?? previousTransaction.amount,
      date: DateTime.tryParse(date.text) ?? previousTransaction.date,
      fromEntityId: selectedPaymentMethod.value.id ?? previousTransaction.fromEntityId,
      fromEntityName: selectedPaymentMethod.value.accountName ?? previousTransaction.fromEntityName,
      fromEntityType: previousTransaction.fromEntityType,
      toEntityId: selectedVendor.value.id ?? previousTransaction.toEntityId,
      toEntityName: selectedVendor.value.companyName ?? previousTransaction.toEntityName,
      toEntityType: previousTransaction.toEntityType,
      transactionType: previousTransaction.transactionType,
    );

    updateTransaction(transaction: transaction, previousTransaction: previousTransaction);
  }

  Future<void> updateTransaction({required TransactionModel transaction, required TransactionModel previousTransaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating transaction...', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      // Form Validation
      if (!transactionFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      processUpdateTransaction(transaction: transaction, previousTransaction: previousTransaction);

      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Transaction updated successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      debugPrint('Error updating transaction: $e');
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> processUpdateTransaction({required TransactionModel transaction, required TransactionModel previousTransaction}) async {
    try{
      List<Future<void>> futures = [];

      futures.add(processTransaction(transaction: previousTransaction, isDelete: true));
      futures.add(processTransaction(transaction: transaction, isUpdated: true));

      await Future.wait(futures);

    } catch(e) {
      rethrow;
    }
  }

  Future<void> updateTransactionByPurchaseId({required int purchaseId, required TransactionModel transaction}) async {
    try {
      final previousTransactions = await mongoTransactionRepo.findTransactionByPurchaseId(purchaseId: purchaseId);
      transaction.transactionId = previousTransactions.transactionId;
      await processUpdateTransaction(transaction: transaction, previousTransaction: previousTransactions);
    } catch (e) {
      rethrow;
    }
  }
}
