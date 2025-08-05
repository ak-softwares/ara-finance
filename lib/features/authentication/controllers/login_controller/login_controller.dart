import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/authentication/authentication_repositories.dart';
import '../../../../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  //variables
  final localStorage = GetStorage();
  final hidePassword = true.obs; //Observable for hiding/showing password
  final rememberMe = true.obs; //Observable for Remember me checked or not
  final email     = TextEditingController();
  final password  = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  final wooCustomersRepository = Get.put(WooCustomersRepository());
  final mongoAuthenticationRepository = Get.put(MongoAuthenticationRepository());
  final userController = Get.put(AuthenticationController());

  //Init method fetch user's saved password and email from local storage
  @override
  void onInit() {
    // Read email from local storage
    String? rememberedEmail = localStorage.read(LocalStorageName.rememberMeEmail);
    if (rememberedEmail != null) {
      email.text = rememberedEmail;
    }
    // Read password from local storage
    String? rememberedPassword = localStorage.read(LocalStorageName.rememberMePassword);
    if (rememberedPassword != null) {
      password.text = rememberedPassword;
    }
    super.onInit();
  }

  Future<void> mongoLogin() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are processing your information..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) return;

      // Form Validation
      if (!loginFormKey.currentState!.validate()) return;

      final UserModel user = await mongoAuthenticationRepository.loginWithEmailAndPass(email: email.text.trim(), password: password.text);

      //save to local storage
      if (rememberMe.value) {
        localStorage.write(LocalStorageName.rememberMeEmail, email.text.trim());
        localStorage.write(LocalStorageName.rememberMePassword, password.text);
      }
      userController.login(user: user);
    } catch (error) {
      //remove Loader
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    } finally {
      FullScreenLoader.stopLoading();
    }
  }

}




