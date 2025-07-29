import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../common/widgets/network_manager/network_manager.dart';
import '../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../models/bank_account.dart';
import '../models/user_model.dart';

class BankAccountController extends GetxController {
  static BankAccountController get instance => Get.find();

  // variables
  final bankName = TextEditingController();
  final accountNumber = TextEditingController();
  final ifscCode = TextEditingController();
  final swiftCode = TextEditingController();

  GlobalKey<FormState> bankAccountFormKey = GlobalKey<FormState>();

  final mongoUserRepository = Get.put(MongoUserRepository());

  void initializedInPutField({required BankAccountModel bankAccount}) {
    bankName.text = bankAccount.bankName ?? '';
    accountNumber.text = bankAccount.accountNumber ?? '';
    ifscCode.text = bankAccount.ifscCode ?? '';
    swiftCode.text = bankAccount.swiftCode ?? '';
  }

  Future<void> updateBankAccount({required String userId, required UserType userType}) async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your Address..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!bankAccountFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      // update single field user
      final bankAccount = BankAccountModel(
        bankName: bankName.text.trim(),
        accountNumber: accountNumber.text.trim(),
        ifscCode: ifscCode.text.trim(),
        swiftCode: swiftCode.text.trim(),
      );

      final user = UserModel(
          id: userId,
          bankAccount: bankAccount,
          userType: userType
      );

      await mongoUserRepository.updateUserById(userId: userId, user: user);

      // remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Address updated successfully!');
      Navigator.of(Get.context!).pop();
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }


}