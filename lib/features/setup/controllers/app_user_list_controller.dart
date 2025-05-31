import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../../../../utils/constants/enums.dart';
import '../../personalization/models/user_model.dart';

class AppUserListController extends GetxController{
  static AppUserListController get instance => Get.find();

  // Variable
  final UserType userType = UserType.admin;
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<UserModel> users = <UserModel>[].obs;
  final mongoUserRepository = Get.put(MongoUserRepository());
  final wooCustomersRepository = Get.put(WooCustomersRepository());

  // Get All products
  Future<void> getAllUsers() async {
    try {
      final fetchedCustomers = await mongoUserRepository.fetchAppUsers(userType: userType, page: currentPage.value);
      users.addAll(fetchedCustomers);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in users Fetching', message: e.toString());
    }
  }

  Future<void> refreshUsers() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      users.clear(); // Clear existing orders
      await getAllUsers();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

}

