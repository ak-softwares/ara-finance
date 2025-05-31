import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/widgets/network_manager/network_manager.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/address_model.dart';
import '../../../personalization/models/user_model.dart';
import 'vendor_controller.dart';

class AddVendorController extends GetxController {
  static AddVendorController get instance => Get.find();

  final UserType userType = UserType.vendor;
  RxInt vendorId = 0.obs;

  // Basic Information Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Company Information Controllers
  final companyController = TextEditingController();
  final gstNumberController = TextEditingController();
  final balanceController = TextEditingController();

  // Address Controllers
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController();

  GlobalKey<FormState> vendorFormKey = GlobalKey<FormState>();

  final mongoUserRepository = Get.put(MongoUserRepository());
  final vendorController = Get.put(VendorController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    vendorId.value = await mongoUserRepository.fetchUserGetNextId(userType: userType, userId: userId);
  }

  void resetValue(UserModel vendor) {
    vendorId.value = vendor.documentId ?? 0;
    nameController.text = vendor.name ?? '';
    emailController.text = vendor.email ?? '';
    phoneController.text = vendor.phone ?? '';
    companyController.text = vendor.companyName ?? '';
    gstNumberController.text = vendor.gstNumber ?? '';
    balanceController.text = vendor.balance.toString();
    address1Controller.text = vendor.billing?.address1 ?? '';
    address2Controller.text = vendor.billing?.address2 ?? '';
    cityController.text = vendor.billing?.city ?? '';
    stateController.text = vendor.billing?.state ?? '';
    pincodeController.text = vendor.billing?.pincode ?? '';
    countryController.text = vendor.billing?.country ?? '';
  }

  void saveVendor() {
    AddressModel address = AddressModel(
      phone: phoneController.text,
      email: emailController.text,
      address1: address1Controller.text,
      address2: address2Controller.text,
      city: cityController.text,
      state: stateController.text,
      pincode: pincodeController.text,
      country: countryController.text,
    );

    UserModel vendor = UserModel(
      userId: userId,
      documentId: vendorId.value,
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      companyName: companyController.text,
      gstNumber: gstNumberController.text,
      balance: double.tryParse(balanceController.text) ?? 0.0,
      billing: address,
      userType: userType,
      dateCreated: DateTime.now(),
    );

    addVendor(vendor: vendor);
  }

  Future<void> addVendor({required UserModel vendor}) async {
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('We are adding vendor..', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!vendorFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      final fetchedVendorId = await mongoUserRepository.fetchUserGetNextId(userType: userType, userId: userId);
      if (fetchedVendorId != vendorId.value) {
        throw 'Vendor ID mismatch!';
      }

      await mongoUserRepository.insertUser(customer: vendor);

      vendorController.refreshVendors();

      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Vendor added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void saveUpdatedVendor({required UserModel previousVendor}) {
    AddressModel address = AddressModel(
      phone: phoneController.text,
      email: emailController.text,
      address1: address1Controller.text,
      address2: address2Controller.text,
      city: cityController.text,
      state: stateController.text,
      pincode: pincodeController.text,
      country: countryController.text,
    );

    UserModel vendor = UserModel(
      id: previousVendor.id,
      documentId: previousVendor.documentId,
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      companyName: companyController.text,
      gstNumber: gstNumberController.text,
      balance: double.tryParse(balanceController.text) ?? 0.0,
      billing: address,
      userType: userType,
      dateCreated: previousVendor.dateCreated,
    );

    updateVendor(vendor: vendor);
  }

  Future<void> updateVendor({required UserModel vendor}) async {
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('We are updating vendor..', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!vendorFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      await mongoUserRepository.updateUserById(userId: vendor.id ?? '', user: vendor);

      // Update in RxList
      final index = vendorController.vendors.indexWhere((v) => v.id == vendor.id);
      if (index != -1) {
        vendorController.vendors[index] = vendor;
      }
      vendorController.refreshVendors();
      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Vendor updated successfully!');
      Get.close(2);
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    gstNumberController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    super.onClose();
  }
}