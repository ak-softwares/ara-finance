import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/accounts/mongo_account_repo.dart';
import '../../../../data/repositories/mongodb/authentication/authentication_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/account_model.dart';

class AccountController extends GetxController {
  static AccountController get instance => Get.find();

  // Variable
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<AccountModel> accounts = <AccountModel>[].obs;

  final mongoAccountsRepo = Get.put(MongoAccountsRepo());
  final mongoAuthenticationRepository = Get.put(MongoAuthenticationRepository());

  String get userId => AuthenticationController.instance.admin.value.id!;
  UserModel get admin => AuthenticationController.instance.admin.value;

  bool isSelectedAccount(String accountId) {
    return admin.selectedAccount?.id == accountId;
  }

  // Get All products
  Future<void> getAccounts() async {
    try {
      final fetchedPayments = await mongoAccountsRepo.fetchAllAccountsMethod(userId: userId ,page: currentPage.value);
      accounts.addAll(fetchedPayments);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshAccounts() async {
    try {
      isLoading(true);
      currentPage.value = 1; // Reset page number
      accounts.clear(); // Clear existing orders
      await getAccounts();
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in Payment Methods getting', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get payment by id
  Future<AccountModel> getPaymentByID({required String id}) async {
    try {
      final fetchedPayment = await mongoAccountsRepo.fetchAccountById(id: id);
      return fetchedPayment;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in payment getting', message: e.toString());
      return AccountModel();
    }
  }

  // Delete Payment
  Future<void> makeAccountDefault ({required AccountModel account}) async {
    try {

      final newUser = UserModel(
        userType: UserType.admin,
        selectedAccount: account,
      );
      await mongoAuthenticationRepository.updateUserById(id: userId, user: newUser);
      refreshAccounts();
      AppMassages.showToastMessage(message: 'Account made default successfully!');
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Delete Payment
  Future<void> deleteAccount ({required String id, required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
          context: context,
          title: 'Delete Payment',
          message: 'Are you sure to delete this Payment',
          onSubmit: () async { await mongoAccountsRepo.deleteAccount(id: id); },
          toastMessage: 'Deleted successfully!'
      );
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<double> getTotalBalance() async {
    try {
      final double totalStockValue = await mongoAccountsRepo.fetchTotalBalance(userId: userId);
      return totalStockValue;
    } catch (e) {
      rethrow;
    }
  }

}