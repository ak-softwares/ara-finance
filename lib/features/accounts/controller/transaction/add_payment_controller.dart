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

class AddPaymentController extends GetxController {
  static AddPaymentController get instance => Get.find();

  RxInt transactionId = 0.obs;


  Rx<UserModel> selectedVendor = UserModel().obs;
  Rx<AccountModel> selectedAccount = AccountModel().obs;

  final amount = TextEditingController();
  final date = TextEditingController();
  GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();

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
    clearPaymentTransaction();
    super.onClose();
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
  void savePaymentTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      amount: double.tryParse(amount.text) ?? 0.0,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      fromEntityId: selectedAccount.value.id, // Example vendor ID
      fromEntityName: selectedAccount.value.accountName, // Example vendor ID
      fromEntityType: EntityType.account,
      toEntityId: selectedVendor.value.id,
      toEntityName: selectedVendor.value.companyName,
      toEntityType: EntityType.vendor,
      transactionType: TransactionType.payment,
    );

    addPaymentTransaction(transaction: transaction);
  }

  // Upload transaction
  Future<void> addPaymentTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating your payment transaction...', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      // Form Validation
      if (!paymentFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processTransaction(transaction: transaction);

      await clearPaymentTransaction();

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Payment transaction added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> clearPaymentTransaction() async {
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId);
    amount.text = '';
    selectedAccount.value = AccountModel();
    selectedVendor.value = UserModel();
    date.text = DateTime.now().toIso8601String();
  }

  // Reset fields before editing transaction
  void resetValue(TransactionModel transaction) {
    transactionId.value = transaction.transactionId ?? 0;
    amount.text = transaction.amount.toString();
    date.text = transaction.date?.toIso8601String() ?? '';
    selectedVendor.value = UserModel(
      id: transaction.toEntityId,
      companyName: transaction.toEntityName,
    );
    selectedAccount.value = AccountModel(
      id: transaction.fromEntityId,
      accountName: transaction.fromEntityName,
    );
  }

  void saveUpdatedPaymentTransaction({required TransactionModel oldPaymentTransaction}) {

    TransactionModel newPaymentTransaction = TransactionModel(
      id: oldPaymentTransaction.id,
      transactionId: oldPaymentTransaction.transactionId,
      amount: double.tryParse(amount.text) ?? oldPaymentTransaction.amount,
      date: DateTime.tryParse(date.text) ?? oldPaymentTransaction.date,
      fromEntityId: selectedAccount.value.id ?? oldPaymentTransaction.fromEntityId,
      fromEntityName: selectedAccount.value.accountName ?? oldPaymentTransaction.fromEntityName,
      fromEntityType: oldPaymentTransaction.fromEntityType,
      toEntityId: selectedVendor.value.id ?? oldPaymentTransaction.toEntityId,
      toEntityName: selectedVendor.value.companyName ?? oldPaymentTransaction.toEntityName,
      toEntityType: oldPaymentTransaction.toEntityType,
      transactionType: oldPaymentTransaction.transactionType,
    );

    updateTransaction(newPaymentTransaction: newPaymentTransaction, oldPaymentTransaction: oldPaymentTransaction);
  }

  Future<void> updateTransaction({required TransactionModel newPaymentTransaction, required TransactionModel oldPaymentTransaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating payment transaction...', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      // Form Validation
      if (!paymentFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processUpdateTransaction(newTransaction: newPaymentTransaction, oldTransaction: oldPaymentTransaction);

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Payment transaction updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

}
