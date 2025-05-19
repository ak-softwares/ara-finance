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
  RxBool isStopped = false.obs; // New: Track if the user wants to stop syncing
  RxBool isSyncing = false.obs;
  RxBool isGettingCount = false.obs;
  RxInt processedCustomers = 0.obs;
  RxInt totalProcessedCustomers = 0.obs;
  RxInt fincomCustomersCount = 0.obs;
  RxInt wooCustomersCount = 0.obs;
  RxList<UserModel> customers = <UserModel>[].obs;
  final mongoUserRepository = Get.put(MongoUserRepository());
  final wooCustomersRepository = Get.put(WooCustomersRepository());

  String get userId => AuthenticationController.instance.admin.value.id!;


  Future<void> syncCustomers() async {
    try {
      isSyncing(true);
      isStopped(false); // Reset stop flag
      processedCustomers.value = 0; // Reset progress
      totalProcessedCustomers.value = 0; // Reset total compared customers count

      int batchSize = 500; // Adjust based on API limits and DB capacity

      // **Step 1: Fetch Existing Customer IDs Efficiently**
      Set<int> uploadedCustomerIds = await mongoUserRepository.fetchUserIds(userId: userId); // Consider paginating this

      int currentPage = 1;
      while (!isStopped.value) {
        // **Step 2: Fetch a batch of customers from API**
        List<UserModel> customers = await wooCustomersRepository.fetchAllCustomers(page: currentPage.toString());

        if (customers.isEmpty) break; // Stop if no more customers are available

        totalProcessedCustomers.value += customers.length; // Track total compared customers

        // **Step 3: Filter only new customers**
        List<UserModel> newCustomers = customers.where((customer) {
          return !uploadedCustomerIds.contains(customer.documentId);
        }).toList();

        // **Step 4: Bulk Insert**
        if (newCustomers.isNotEmpty) {
          for (int i = 0; i < newCustomers.length; i += batchSize) {
            if (isStopped.value) {
              AppMassages.warningSnackBar(title: 'Sync Stopped', message: 'Syncing stopped by user.');
              return;
            }

            int end = (i + batchSize < newCustomers.length) ? i + batchSize : newCustomers.length;
            List<UserModel> chunk = newCustomers.sublist(i, end);

            await mongoUserRepository.insertUsers(customers: chunk); // Upload chunk

            processedCustomers.value += chunk.length; // Update progress
          }
        }

        currentPage++; // Move to the next page
      }

      if (!isStopped.value) {
        AppMassages.successSnackBar(title: 'Sync Complete', message: 'All new customers uploaded.');
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Sync Error', message: e.toString());
    } finally {
      isSyncing(false);
    }
  }

  void stopSyncing() {
    isStopped(true);
  }

  // Get total customer count
  Future<void> getTotalCustomerCount() async {
    try {
      isGettingCount(true);
      int fincomCustomersCounts = await mongoUserRepository.fetchUserCount(userId: userId);
      fincomCustomersCount.value = fincomCustomersCounts;
      int wooCustomersCounts = await wooCustomersRepository.fetchCustomerCount();
      wooCustomersCount.value = wooCustomersCounts;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Customer Count Fetching', message: e.toString());
    } finally {
      isGettingCount(false);
    }
  }

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

