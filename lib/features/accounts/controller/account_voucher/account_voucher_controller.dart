import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/account_voucher/account_voucher_repo.dart';
import '../../../../data/repositories/mongodb/authentication/authentication_repositories.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/account_voucher_model.dart';
import '../../models/transaction_model.dart';

class AccountVoucherController extends GetxController {
  static AccountVoucherController get instance => Get.find();

  // Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<AccountVoucherModel> accountVouchers = <AccountVoucherModel>[].obs;
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;

  final mongoAccountVoucherRepo = Get.put(MongoAccountVoucherRepo());
  final mongoAuthenticationRepository = Get.put(MongoAuthenticationRepository());
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;
  UserModel get admin => AuthenticationController.instance.admin.value;

  Future<void> getAccountVouchers({required AccountVoucherType voucherType}) async {
    try {
      final List<AccountVoucherModel> fetchedAccountVouchers = await mongoAccountVoucherRepo.fetchAllVouchers(
          userId: userId,
          voucherType: voucherType,
          page: currentPage.value
      );
      accountVouchers.addAll(fetchedAccountVouchers);
    } catch (e) {
      rethrow;
    }
  }

  // Upload a new voucher
  Future<double> getAllVoucherBalance({required AccountVoucherType voucherType}) async {
    try {
      final double total = await mongoAccountVoucherRepo.fetchAllVoucherBalance(
          userId: userId,
          voucherType: voucherType
      );
      return total;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshAccountVouchers({required AccountVoucherType voucherType}) async {
    try {
      isLoading(true);
      currentPage.value = 1;
      accountVouchers.clear();
      await getAccountVouchers(voucherType: voucherType);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in AccountVoucher getting', message: e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Get accountVoucher by ID
  Future<AccountVoucherModel> getAccountVoucherByID({required String id}) async {
    try {
      final fetchedAccountVoucher = await mongoAccountVoucherRepo.fetchVoucherById(id: id);
      return fetchedAccountVoucher;
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error in accountVoucher getting', message: e.toString());
      return AccountVoucherModel();
    }
  }

  // Get total of all accountVoucher values (if needed)
  // Future<double> getTotalAccountVoucherAmount({required String voucherId}) async {
  //   try {
  //     final total = await mongoAccountVoucherRepo.fetchVoucherBalance(voucherId: voucherId);
  //     return total;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Delete an accountVoucher
  Future<void> deleteAccountVoucher({required String id, required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
        context: context,
        title: 'Delete AccountVoucher',
        message: 'Are you sure to delete this AccountVoucher?',
        onSubmit: () async => await mongoAccountVoucherRepo.deleteVoucher(id: id),
        toastMessage: 'Deleted successfully!',
      );
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }
}