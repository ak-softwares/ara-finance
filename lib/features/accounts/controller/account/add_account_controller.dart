import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/accounts/mongo_account_repo.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/account_model.dart';
import 'account_controller.dart';

class AddAccountController extends GetxController {

  RxInt accountId = 0.obs;

  final accountsName = TextEditingController();
  final balance = TextEditingController();

  GlobalKey<FormState> accountsFormKey = GlobalKey<FormState>();

  final mongoAccountsRepo = Get.put(MongoAccountsRepo());
  final paymentController = Get.put(AccountController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    accountId.value = await mongoAccountsRepo.fetchAccountGetNextId(userId: userId);
  }

  // Save
  void savePaymentMethods() {
    AccountModel paymentMethod = AccountModel(
      accountId: accountId.value,
      userId: userId,
      balance: double.tryParse(balance.text) ?? 0.0, // Convert string to double safely
      accountName: accountsName.text,
      dateCreated: DateTime.now(), // Keep it as DateTime
    );

    addPayment(paymentMethod: paymentMethod);
  }

  // Upload vendor
  Future<void> addPayment({required AccountModel paymentMethod}) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are adding your Account..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!accountsFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      final fetchedPaymentId = await mongoAccountsRepo.fetchAccountGetNextId(userId: userId);
      if(fetchedPaymentId != accountId.value) {
        throw 'Account id is same';
      }
      await mongoAccountsRepo.pushAccountsMethod(paymentMethod: paymentMethod); // Use batch insert function
      clearPayment();
      paymentController.refreshAccounts();
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Account added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> clearPayment() async {
    accountId.value = await mongoAccountsRepo.fetchAccountGetNextId(userId: userId);
    accountsName.text = '';
    balance.text = '';
  }

  // Update vendor
  void resetValue(AccountModel payment) {
    accountId.value = payment.accountId ?? 0;
    accountsName.text = payment.accountName ?? '';
    balance.text = payment.balance.toString();
  }

  void saveUpdatedPayment({required AccountModel previousPayment}) {
    AccountModel payment = AccountModel(
      id: previousPayment.id,
      accountId: previousPayment.accountId,
      balance: double.tryParse(balance.text) ?? 0.0, // Convert string to double safely
      accountName: accountsName.text,
    );

    updatePayment(payment: payment);
  }

  Future<void> updatePayment({required AccountModel payment}) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating account..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!accountsFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      await mongoAccountsRepo.updateAccount(id: payment.id ?? '', account: payment); // Use batch insert function
      paymentController.refreshAccounts();
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Account updated successfully!');
      Get.close(2);
    } catch (e) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}
