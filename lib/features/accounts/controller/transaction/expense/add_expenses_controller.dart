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

class AddExpenseTransactionController extends GetxController {
  static AddExpenseTransactionController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.expense;
  RxInt transactionId = 0.obs;

  Rx<AccountVoucherModel> selectedExpense = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> selectedBankAccount = AccountVoucherModel().obs;

  final amount = TextEditingController();
  final description = TextEditingController();
  final date = TextEditingController();
  GlobalKey<FormState> expenseFormKey = GlobalKey<FormState>();

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
    clearExpenseTransaction();
    super.onClose();
  }

  void addExpense(AccountVoucherModel getSelectedExpense) {
    selectedExpense.value = getSelectedExpense;
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

  void saveExpenseTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      amount: double.tryParse(amount.text) ?? 0.0,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      description: description.text,
      fromAccountVoucher: selectedBankAccount.value,
      toAccountVoucher: selectedExpense.value,
      transactionType: AccountVoucherType.expense,
    );

    addExpenseTransaction(transaction: transaction);
  }

  Future<void> addExpenseTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating your expense transaction...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      if (!expenseFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processTransactions(transactions: [transaction]);
      await clearExpenseTransaction();

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Expense transaction added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> clearExpenseTransaction() async {
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
    amount.text = '';
    selectedBankAccount.value = AccountVoucherModel();
    selectedExpense.value = AccountVoucherModel();
    date.text = DateTime.now().toIso8601String();
    description.text = '';
  }

  void resetValue(TransactionModel transaction) {
    transactionId.value = transaction.transactionId ?? 0;
    amount.text = transaction.amount.toString();
    date.text = transaction.date?.toIso8601String() ?? '';
    description.text = transaction.description ?? '';
    selectedBankAccount.value = transaction.fromAccountVoucher ?? AccountVoucherModel();
    selectedExpense.value = transaction.toAccountVoucher ?? AccountVoucherModel();
  }

  void saveUpdatedExpenseTransaction({required TransactionModel oldExpenseTransaction}) {
    TransactionModel newExpenseTransaction = TransactionModel(
      id: oldExpenseTransaction.id,
      transactionId: oldExpenseTransaction.transactionId,
      amount: double.tryParse(amount.text) ?? oldExpenseTransaction.amount,
      date: DateTime.tryParse(date.text) ?? oldExpenseTransaction.date,
      description: description.text,
      fromAccountVoucher: selectedBankAccount.value,
      toAccountVoucher: selectedExpense.value,
      transactionType: oldExpenseTransaction.transactionType,
    );

    updateTransaction(transaction: newExpenseTransaction);
  }

  Future<void> updateTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating expense transaction...', Images.docerAnimation);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }

      if (!expenseFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }

      await transactionController.processUpdateTransaction(transaction: transaction);

      FullScreenLoader.stopLoading();
      await transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'Expense transaction updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
