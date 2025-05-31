import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';

class CustomerController extends GetxController{
  static CustomerController get instance => Get.find();

  // Variable
  final UserType userType = UserType.customer;
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<UserModel> customers = <UserModel>[].obs;
  final mongoUserRepository = Get.put(MongoUserRepository());
  final wooCustomersRepository = Get.put(WooCustomersRepository());

  String get userId => AuthenticationController.instance.admin.value.id!;


  // Get All Customer
  Future<List<UserModel>> getCustomersSearchQuery({required String query, required int page}) async {
    try {
      final customers = await mongoUserRepository.fetchUsersBySearchQuery(query: query, userType: userType, page: currentPage.value, userId: userId);
      return customers;
    } catch (e) {
      rethrow; // Rethrow the exception to handle it in the caller
    }
  }


  // Get All products
  Future<void> getAllCustomers() async {
    try {
      final fetchedCustomers = await mongoUserRepository.fetchUsers(userType: userType, page: currentPage.value, userId: userId);
      customers.addAll(fetchedCustomers);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Products Fetching', message: e.toString());
    }
  }

  Future<void> refreshCustomers() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      customers.clear(); // Clear existing orders
      await getAllCustomers();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get Customer by ID
  Future<UserModel> getCustomerByID({required String id}) async {
    try {
      final fetchedCustomer = await mongoUserRepository.fetchUserById(id: id);
      return fetchedCustomer;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in getting customer', message: e.toString());
      return UserModel.empty(); // Return an empty customer model in case of failure
    }
  }

  Future<void> deleteCustomer({required String id, required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
        context: context,
        title: 'Delete Customer',
        message: 'Are you sure you want to delete this customer?',
        actionButtonText: 'Delete',
        onSubmit: () async {
          await mongoUserRepository.deleteUserById(id: id);
          Get.back();
          refreshCustomers();
        },
        toastMessage: 'Deleted successfully!',
      );
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }


}

