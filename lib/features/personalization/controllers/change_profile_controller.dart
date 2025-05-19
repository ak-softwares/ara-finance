import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../common/text/section_heading.dart';
import '../../../common/widgets/network_manager/network_manager.dart';
import '../../../data/repositories/mongodb/authentication/authentication_repositories.dart';
import '../../../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/local_storage_constants.dart';
import '../../../utils/constants/sizes.dart';
import '../models/user_model.dart';
import '../screens/user_profile/user_profile.dart';
import '../../authentication/controllers/authentication_controller/authentication_controller.dart';

class ChangeProfileController extends GetxController {
  static ChangeProfileController get instance => Get.find();

  // variables
  final fullName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();

  final updatePhone = TextEditingController();
  RxBool isPhoneUpdating = false.obs;
  RxBool isPhoneVerified = true.obs;

  GlobalKey<FormState> changeProfileFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> updatePhoneFormKey = GlobalKey<FormState>();

  final localStorage = GetStorage();
  final auth = Get.put(AuthenticationController());
  final wooCustomersRepository = Get.put(WooCustomersRepository());
  final mongoAuthenticationRepository = Get.put(MongoAuthenticationRepository());

  // Mongo update profile details
  Future<void> mongoChangeProfileDetails() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your information..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!changeProfileFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      //update single field user
      final updatedUser = UserModel(
          userType: UserType.admin,
          name: fullName.text.trim(),
          email: email.text.trim(),
          phone: phone.text.trim(),
      );
      await mongoAuthenticationRepository.updateUserById(id: auth.userId, user: updatedUser);

      //update the Rx user value
      auth.admin(updatedUser);

      // update email to local storage too
      localStorage.write(LocalStorage.rememberMeEmail, email.text.trim());

      //remove Loader
      FullScreenLoader.stopLoading();

      // UserController.instance.fetchUserRecord();
      AppMassages.showToastMessage(message: 'Details updated successfully!');
      // move to next screen
      Get.close(1);
      Get.off(() => const UserProfileScreen());
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }


}

