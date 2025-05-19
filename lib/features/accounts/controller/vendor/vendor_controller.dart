import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';

class VendorController extends GetxController {
  static VendorController get instance => Get.find();

  // Variable
  final UserType userType = UserType.vendor;
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<UserModel> vendors = <UserModel>[].obs;
  final mongoUserRepository = Get.put(MongoUserRepository());

  String get userId => AuthenticationController.instance.admin.value.id!;

  // Get All vendors
  Future<List<UserModel>> getVendorsSearchQuery({required String query, required int page}) async {
    try {
      final vendors = await mongoUserRepository.fetchUsersBySearchQuery(userId: userId, query: query, userType: userType, page: currentPage.value);
      return vendors;
    } catch (e) {
      rethrow; // Rethrow the exception to handle it in the caller
    }
  }

  // Get All vendors
  Future<void> getAllVendors() async {
    try {
      final fetchedVendors = await mongoUserRepository.fetchUsers(userType: userType, userId: userId, page: currentPage.value);
      vendors.addAll(fetchedVendors);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Vendors Fetching', message: e.toString());
    }
  }

  Future<void> refreshVendors() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      vendors.clear(); // Clear existing orders
      await getAllVendors();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Errors', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get Vendor by ID
  Future<UserModel> getVendorByID({required String id}) async {
    try {
      final fetchedVendor = await mongoUserRepository.fetchUserById(id: id);
      return fetchedVendor;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in getting vendor', message: e.toString());
      return UserModel.empty(); // Return an empty vendor model in case of failure
    }
  }

  Future<void> deleteVendor({required String id, required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
        context: context,
        title: 'Delete Vendor',
        message: 'Are you sure you want to delete this vendor?',
        actionButtonText: 'Delete',
        onSubmit: () async {
          await mongoUserRepository.deleteUserById(id: id);
          Get.back();
          refreshVendors();
        },
        toastMessage: 'Deleted successfully!',
      );
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<double> calculateAccountPayable() async {
    try {
      final double totalStockValue = await mongoUserRepository.calculateAccountPayable(userType: userType, userId: userId);
      return totalStockValue;
    } catch (e) {
      rethrow;
    }
  }
}