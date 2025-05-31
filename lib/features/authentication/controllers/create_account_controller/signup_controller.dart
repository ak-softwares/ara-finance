import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/authentication/authentication_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../../../utils/helpers/encryption_hepler.dart';
import '../authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../login_controller/login_controller.dart';

class SignupController extends GetxController{
  static SignupController get instance => Get.find();

  ///variables
  final localStorage = GetStorage();
  final hidePassword = true.obs; //Observable for hiding/showing password
  final privacyPolicyChecked = true.obs; //Observable for privacy policy checked or not
  final fullName = TextEditingController();
  final email     = TextEditingController();
  final password  = TextEditingController();
  final phone     = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>(); //Form key for form validation

  final userController = Get.put(AuthenticationController());
  final loginController = Get.put(LoginController());
  final mongoAuthenticationRepository = Get.put(MongoAuthenticationRepository());

  void signupWithEmailPassword() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are creating account..', Images.docerAnimation);
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      if(!signupFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      //privacy policy check
      if(!privacyPolicyChecked.value) {
        AppMassages.warningSnackBar(title: 'Accept Privacy Policy', message: 'In order to create account, you have to read and accept the privacy Policy & Terms of Use.');
        return;
      }

      UserModel user = UserModel(
        name: fullName.text.trim(),
        email: email.text.trim(),
        password: EncryptionHelper.hashPassword(password: password.text.trim()),
        phone: phone.text.trim(),
        dateCreated: DateTime.now(),
        userType: UserType.admin,
      );

      await mongoAuthenticationRepository.singUpWithEmailAndPass(user: user);

      //save to local storage
      if(loginController.rememberMe.value) {
        localStorage.write(LocalStorage.rememberMeEmail, email.text.trim());
        localStorage.write(LocalStorage.rememberMePassword, password.text);
      }

      FullScreenLoader.stopLoading();
      userController.login(user: user);
    } catch (error) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Oh Snap!', message: error.toString());
    }
  }

}




