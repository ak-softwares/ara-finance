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
import 'customer_controller.dart';

class AddCustomerController extends GetxController{
  static AddCustomerController get instance => Get.find();

  final UserType userType = UserType.customer;
  RxInt customerId = 0.obs;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController();
  GlobalKey<FormState> customerFormKey = GlobalKey<FormState>();

  final mongoCustomersRepo = Get.put(MongoUserRepository());
  final customerController = Get.put(CustomerController());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  Future<void> onInit() async {
    super.onInit();
    customerId.value = await mongoCustomersRepo.fetchUserGetNextId(userType: userType, userId: userId);
  }

  void resetValue(UserModel customer) {
    customerId.value = customer.documentId ?? 0;
    nameController.text = customer.name ?? '';
    emailController.text = customer.email ?? '';
    phoneController.text = customer.phone ?? '';

    address1Controller.text = customer.billing?.address1 ?? '';
    address2Controller.text = customer.billing?.address2 ?? '';
    cityController.text = customer.billing?.city ?? '';
    stateController.text = customer.billing?.state ?? '';
    pincodeController.text = customer.billing?.pincode ?? '';
    countryController.text = customer.billing?.country ?? '';
  }

  void saveCustomer() {
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

    UserModel customer = UserModel(
      documentId: customerId.value,
      name: nameController.text,
      email: emailController.text,
      billing: address,
      userType: userType,
      dateCreated: DateTime.now().toString(),
    );

    addCustomer(customer: customer);
  }

  Future<void> addCustomer({required UserModel customer}) async {
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('We are adding customer..', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!customerFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      final fetchedCustomerId = await mongoCustomersRepo.fetchUserGetNextId(userType: userType, userId: userId);
      if (fetchedCustomerId != customerId.value) {
        throw 'Customer ID mismatch!';
      }

      await mongoCustomersRepo.insertUser(customer: customer);

      customerController.refreshCustomers();

      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Customer added successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  void saveUpdatedCustomer({required UserModel previousCustomer}) {
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

    UserModel customer = UserModel(
      id: previousCustomer.id,
      documentId: previousCustomer.documentId,
      name: nameController.text,
      email: emailController.text,
      billing: address,
      userType: userType,
      dateCreated: previousCustomer.dateCreated,
    );

    updateCustomer(customer: customer);
  }

  Future<void> updateCustomer({required UserModel customer}) async {
    try {
      // Start Loading
      FullScreenLoader.openLoadingDialog('We are updating customer..', Images.docerAnimation);

      // Check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!customerFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }
      await mongoCustomersRepo.updateUser(user: customer);

      // Update in RxList
      final index = customerController.customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        customerController.customers[index] = customer;
      }
      await  customerController.refreshCustomers();

      FullScreenLoader.stopLoading();
      AppMassages.showToastMessage(message: 'Customer updated successfully!');
      Navigator.of(Get.context!).pop();
    } catch (e) {
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> updateCustomerAddressById({required String id, required UserType userType, required AddressModel address}) async {
    try {
      final user = UserModel(
        id: id,
        billing: address,
        userType: userType
      );
      await mongoCustomersRepo.updateUser(user: user);
    } catch (e) {
      rethrow;
    }
  }

}