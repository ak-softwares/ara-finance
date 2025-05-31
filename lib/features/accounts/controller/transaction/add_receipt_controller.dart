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
import 'transaction_controller.dart';

class AddReceiptController extends GetxController {
  static AddReceiptController get instance => Get.find();

  RxInt transactionId = 0.obs;


  Rx<UserModel> selectedCustomer = UserModel().obs;
  Rx<AccountModel> selectedAccount = AccountModel().obs;

  final amount = TextEditingController();
  final date = TextEditingController();
  GlobalKey<FormState> receiptFormKey = GlobalKey<FormState>();

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final transactionController = Get.put(TransactionController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    date.text = DateTime.now().toIso8601String(); // Store in ISO format
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId);
  }

  @override
  void onClose() {
    clearReceiptTransaction();
    super.onClose();
  }

  void addCustomer(UserModel getSelectedCustomer) {
    selectedCustomer.value = getSelectedCustomer;
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
  void saveReceiptTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      amount: double.tryParse(amount.text) ?? 0.0,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      fromEntityId: selectedCustomer.value.id, // Example vendor ID
      fromEntityName: selectedCustomer.value.name, // Example vendor ID
      fromEntityType: EntityType.customer,
      toEntityId: selectedAccount.value.id,
      toEntityName: selectedAccount.value.accountName,
      toEntityType: EntityType.account,
      transactionType: TransactionType.receipt,
    );

    addReceiptTransaction(transaction: transaction);
  }

  // Upload transaction
  Future<void> addReceiptTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating your receipt transaction...', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      // Form Validation
      if (!receiptFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processTransaction(transaction: transaction);

      await clearReceiptTransaction();

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Receipt transaction added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }


  Future<void> clearReceiptTransaction() async {
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId);
    amount.text = '';
    selectedAccount.value = AccountModel();
    selectedCustomer.value = UserModel();
    date.text = DateTime.now().toIso8601String();
  }

  // Reset fields before editing transaction
  void resetValue(TransactionModel receiptTransaction) {
    transactionId.value = receiptTransaction.transactionId ?? 0;
    amount.text = receiptTransaction.amount.toString();
    date.text = receiptTransaction.date?.toIso8601String() ?? '';
    selectedCustomer.value = UserModel(
      id: receiptTransaction.toEntityId,
      name: receiptTransaction.toEntityName,
    );
    selectedAccount.value = AccountModel(
      id: receiptTransaction.fromEntityId,
      accountName: receiptTransaction.fromEntityName,
    );
  }

  void saveUpdatedReceiptTransaction({required TransactionModel oldReceiptTransaction}) {

    TransactionModel newReceiptTransaction = TransactionModel(
      id: oldReceiptTransaction.id,
      transactionId: oldReceiptTransaction.transactionId,
      amount: double.tryParse(amount.text) ?? oldReceiptTransaction.amount,
      date: DateTime.tryParse(date.text) ?? oldReceiptTransaction.date,
      fromEntityId: selectedCustomer.value.id ?? oldReceiptTransaction.fromEntityId,
      fromEntityName: selectedCustomer.value.name ?? oldReceiptTransaction.fromEntityName,
      fromEntityType: oldReceiptTransaction.fromEntityType,
      toEntityId: selectedAccount.value.id ?? oldReceiptTransaction.toEntityId,
      toEntityName: selectedAccount.value.accountName ?? oldReceiptTransaction.toEntityName,
      toEntityType: oldReceiptTransaction.toEntityType,
      transactionType: oldReceiptTransaction.transactionType,
    );

    updateReceiptTransaction(newReceiptTransaction: newReceiptTransaction, oldReceiptTransaction: oldReceiptTransaction);
  }

  Future<void> updateReceiptTransaction({required TransactionModel newReceiptTransaction, required TransactionModel oldReceiptTransaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating receipt transaction...', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      // Form Validation
      if (!receiptFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processUpdateTransaction(newTransaction: newReceiptTransaction, oldTransaction: oldReceiptTransaction);

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Receipt transaction updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }


}
