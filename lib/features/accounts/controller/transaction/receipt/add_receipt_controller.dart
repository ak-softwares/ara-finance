import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../models/account_model.dart';
import '../../../models/account_voucher_model.dart';
import '../../../models/transaction_model.dart';
import '../transaction_controller.dart';

class AddReceiptController extends GetxController {
  static AddReceiptController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.receipt;
  RxInt transactionId = 0.obs;

  Rx<AccountVoucherModel> selectedBankAccount = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> selectedCustomer = AccountVoucherModel().obs;

  final amount = TextEditingController();
  final date = TextEditingController();
  GlobalKey<FormState> receiptFormKey = GlobalKey<FormState>();

  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final transactionController = Get.put(TransactionController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    date.text = DateTime.now().toIso8601String();
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
  }

  @override
  void onClose() {
    clearReceiptTransaction();
    super.onClose();
  }

  void addSender(AccountVoucherModel getSelectedSender) {
    selectedCustomer.value = getSelectedSender;
  }

  void selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      date.text = pickedDate.toIso8601String();
      update();
    }
  }

  void saveReceiptTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      amount: double.tryParse(amount.text) ?? 0.0,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      fromAccountVoucher: selectedCustomer.value,
      toAccountVoucher: selectedBankAccount.value,
      transactionType: AccountVoucherType.receipt,
    );

    addReceiptTransaction(transaction: transaction);
  }

  Future<void> addReceiptTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Adding your receipt transaction...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      if (!receiptFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processTransactions(transactions: [transaction]);
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
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
    amount.text = '';
    selectedBankAccount.value = AccountVoucherModel();
    selectedCustomer.value = AccountVoucherModel();
    date.text = DateTime.now().toIso8601String();
  }

  void resetValue(TransactionModel transaction) {
    transactionId.value = transaction.transactionId ?? 0;
    amount.text = transaction.amount.toString();
    date.text = transaction.date?.toIso8601String() ?? '';
    selectedCustomer.value = transaction.fromAccountVoucher ?? AccountVoucherModel();
    selectedBankAccount.value = transaction.toAccountVoucher ?? AccountVoucherModel();
  }

  void saveUpdatedReceiptTransaction({required TransactionModel oldReceiptTransaction}) {
    TransactionModel newReceiptTransaction = TransactionModel(
      id: oldReceiptTransaction.id,
      transactionId: oldReceiptTransaction.transactionId,
      amount: double.tryParse(amount.text) ?? oldReceiptTransaction.amount,
      date: DateTime.tryParse(date.text) ?? oldReceiptTransaction.date,
      fromAccountVoucher: selectedCustomer.value,
      toAccountVoucher: selectedBankAccount.value,
      transactionType: oldReceiptTransaction.transactionType,
    );

    updateTransaction(transaction: newReceiptTransaction);
  }

  Future<void> updateTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating receipt transaction...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      if (!receiptFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processUpdateTransaction(transaction: transaction);

      FullScreenLoader.stopLoading();
      await transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Receipt transaction updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
