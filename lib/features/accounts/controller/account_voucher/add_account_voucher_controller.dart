import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/account_voucher/account_voucher_repo.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/account_voucher_model.dart';
import 'account_voucher_controller.dart';

class AddAccountVoucherController extends GetxController {

  AddAccountVoucherController({required this.voucherType});

  final AccountVoucherType voucherType;

  RxInt accountVoucherId = 0.obs;
  final accountVoucherName = TextEditingController();
  final openingBalance = TextEditingController();

  GlobalKey<FormState> accountVoucherFormKey = GlobalKey<FormState>();

  final mongoAccountVoucherRepo = Get.put(MongoAccountVoucherRepo());
  final accountVoucherController = Get.put(AccountVoucherController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    accountVoucherId.value = await mongoAccountVoucherRepo.fetchVoucherGetNextId(userId: userId, voucherType: voucherType);
  }

  // Save new Account Voucher
  void saveAccountVoucher() {
    AccountVoucherModel accountVoucher = AccountVoucherModel(
      voucherId: accountVoucherId.value,
      userId: userId,
      title: accountVoucherName.text.trim(),
      openingBalance: double.tryParse(openingBalance.text) ?? 0.0,
      dateCreated: DateTime.now(),
      voucherType: voucherType,
    );

    addAccountVoucher(accountVoucher: accountVoucher);
  }

  // Upload Account Voucher
  Future<void> addAccountVoucher({required AccountVoucherModel accountVoucher}) async {
    try {
      FullScreenLoader.openLoadingDialog('We are adding your Account Voucher..', Images.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      if (!accountVoucherFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      final fetchedAccountVoucherId = await mongoAccountVoucherRepo.fetchVoucherGetNextId(userId: userId, voucherType: voucherType);
      if (fetchedAccountVoucherId != accountVoucherId.value) {
        accountVoucher.voucherId = fetchedAccountVoucherId;
      }
      await mongoAccountVoucherRepo.pushVoucher(voucher: accountVoucher);
      clearAccountVoucher();
      accountVoucherController.refreshAccountVouchers(voucherType: voucherType);
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Account voucher added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> clearAccountVoucher() async {
    accountVoucherId.value = await mongoAccountVoucherRepo.fetchVoucherGetNextId(userId: userId, voucherType: voucherType);
    accountVoucherName.text = '';
    openingBalance.text = '';
  }

  void resetValue(AccountVoucherModel accountVoucher) {
    accountVoucherId.value = accountVoucher.voucherId ?? 0;
    accountVoucherName.text = accountVoucher.title ?? '';
    openingBalance.text = accountVoucher.openingBalance.toString();
  }

  void saveUpdatedAccountVoucher({required AccountVoucherModel previousAccountVoucher}) {
    AccountVoucherModel accountVoucher = AccountVoucherModel(
      id: previousAccountVoucher.id,
      voucherId: previousAccountVoucher.voucherId,
      openingBalance: double.tryParse(openingBalance.text) ?? 0.0,
      title: accountVoucherName.text,
    );

    updateAccountVoucher(accountVoucher: accountVoucher, voucherType: voucherType);
  }

  Future<void> updateAccountVoucher({required AccountVoucherModel accountVoucher, required AccountVoucherType voucherType}) async {
    try {
      FullScreenLoader.openLoadingDialog('We are updating account voucher..', Images.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      if (!accountVoucherFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      await mongoAccountVoucherRepo.updateVoucher(id: accountVoucher.id ?? '', voucher: accountVoucher);
      await accountVoucherController.refreshAccountVouchers(voucherType: voucherType);
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Account voucher updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}