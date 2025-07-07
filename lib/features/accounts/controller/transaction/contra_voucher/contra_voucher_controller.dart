import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../models/account_voucher_model.dart';
import '../../../models/transaction_model.dart';
import '../transaction_controller.dart';

class ContraVoucherController extends GetxController {
  static ContraVoucherController get instance => Get.find();

  final AccountVoucherType voucherType = AccountVoucherType.contra;
  RxInt transactionId = 0.obs;

  Rx<AccountVoucherModel> fromBankAccount = AccountVoucherModel().obs;
  Rx<AccountVoucherModel> toBankAccount = AccountVoucherModel().obs;

  final amount = TextEditingController();
  final date = TextEditingController();
  GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();

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
    clearPaymentTransaction();
    super.onClose();
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

  void savePaymentTransaction() {
    TransactionModel transaction = TransactionModel(
      userId: userId,
      transactionId: transactionId.value,
      amount: double.tryParse(amount.text) ?? 0.0,
      date: DateTime.tryParse(date.text) ?? DateTime.now(),
      fromAccountVoucher: fromBankAccount.value,
      toAccountVoucher: toBankAccount.value,
      transactionType: voucherType,
    );

    addPaymentTransaction(transaction: transaction);
  }

  Future<void> addPaymentTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Adding your contra voucher transaction...', Images.docerAnimation);

      await validateTransaction();
      await transactionController.processTransactions(transactions: [transaction]);
      await clearPaymentTransaction();

      FullScreenLoader.stopLoading();
      transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'contra voucher transaction added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> clearPaymentTransaction() async {
    transactionId.value = await mongoTransactionRepo.fetchTransactionGetNextId(userId: userId, voucherType: voucherType);
    amount.text = '';
    fromBankAccount.value = AccountVoucherModel();
    toBankAccount.value = AccountVoucherModel();
    date.text = DateTime.now().toIso8601String();
  }

  void resetValue(TransactionModel transaction) {
    transactionId.value = transaction.transactionId ?? 0;
    amount.text = transaction.amount.toString();
    date.text = transaction.date?.toIso8601String() ?? '';
    fromBankAccount.value = transaction.fromAccountVoucher ?? AccountVoucherModel();
    toBankAccount.value = transaction.toAccountVoucher ?? AccountVoucherModel();
  }

  void saveUpdatedPaymentTransaction({required TransactionModel oldPaymentTransaction}) {
    TransactionModel newPaymentTransaction = TransactionModel(
      id: oldPaymentTransaction.id,
      transactionId: oldPaymentTransaction.transactionId,
      amount: double.tryParse(amount.text) ?? oldPaymentTransaction.amount,
      date: DateTime.tryParse(date.text) ?? oldPaymentTransaction.date,
      fromAccountVoucher: fromBankAccount.value,
      toAccountVoucher: toBankAccount.value,
      transactionType: oldPaymentTransaction.transactionType,
    );

    updateTransaction(transaction: newPaymentTransaction);
  }

  Future<void> updateTransaction({required TransactionModel transaction}) async {
    try {
      FullScreenLoader.openLoadingDialog('Updating contra voucher transaction...', Images.docerAnimation);

      await validateTransaction();

      await transactionController.processUpdateTransaction(transaction: transaction);

      FullScreenLoader.stopLoading();
      await transactionController.refreshTransactions();
      AppMassages.showToastMessage(message: 'contra voucher transaction updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<bool> validateTransaction() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        throw 'Internet Not connected';
      }
      if (!paymentFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        throw 'Form is not valid';
      }
      if (fromBankAccount.value.id == null) {
        throw Exception('Please select a supplier.');
      }
      if (toBankAccount.value.id == null) {
        throw Exception('Please select a supplier.');
      }
      if (date.text.isEmpty) {
        throw Exception('Please enter a date.');
      }
      return true;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Validation Error', message: e.toString());
      return false;
    }
  }
}
