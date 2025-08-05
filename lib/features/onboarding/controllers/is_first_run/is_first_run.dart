import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/constants/local_storage_constants.dart';
import '../../../authentication/controllers/phone_otp_controller/phone_otp_controller.dart';
import '../../../personalization/controllers/change_profile_controller.dart';
import '../../../personalization/models/user_model.dart';

class IsFirstRunController extends GetxController {
  static IsFirstRunController get instance => Get.find();

  static final localStorage = GetStorage();

  static final oTPController = Get.put(OTPController());
  static final changeProfileController = Get.put(ChangeProfileController());


  static bool isFirstRun() {
    return localStorage.read(LocalStorageName.isFirstRun) ?? true;
  }

  static void updateIsFirstRun() {
    localStorage.write(LocalStorageName.isFirstRun, false);
  }

  static Future<void> activation(UserModel customer) async {
    try {
      final userId = customer.documentId.toString();

      // set
      updateIsFirstRun();
    }catch(e){
      rethrow;
    }
  }

}