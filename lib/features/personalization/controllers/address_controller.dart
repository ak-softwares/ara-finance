import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../common/widgets/network_manager/network_manager.dart';
import '../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/data/state_iso_code_map.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';

class AddressController extends GetxController{
  static AddressController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  final address1 = TextEditingController();
  final address2 = TextEditingController();
  final pincode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final country = TextEditingController();
  GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();

  final mongoUserRepository = Get.put(MongoUserRepository());

  void initializedInPutField({required AddressModel address}) {
    firstName.text = address.firstName!;
    lastName.text = address.lastName!;
    address1.text = address.address1!;
    address2.text = address.address2!;
    city.text = address.city!;
    pincode.text = address.pincode!;
    state.text = address.state!;
    country.text = address.country!;
  }

  Future<void> updateAddress({required String userId, required UserType userType}) async {
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
      if (!addressFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      // update single field user
      final address = AddressModel(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        address1: address1.text.trim(),
        address2: address2.text.trim(),
        city: city.text.trim(),
        pincode: pincode.text.trim(),
        state: StateData.getISOFromState(state.text.trim()),
        country: CountryData.getISOFromCountry(country.text.trim()),
      );

      final user = UserModel(
          id: userId,
          billing: address,
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