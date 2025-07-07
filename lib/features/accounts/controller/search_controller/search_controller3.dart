import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/account_voucher/account_voucher_repo.dart';
import '../../../../data/repositories/mongodb/accounts/mongo_account_repo.dart';
import '../../../../data/repositories/mongodb/products/product_repositories.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/account_voucher_model.dart';
import '../../models/product_model.dart';

class SearchController3 extends GetxController {
  static SearchController3 get instance => Get.find();

  // Variable
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxInt currentPage = 1.obs;

  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<ProductModel> selectedProducts = <ProductModel>[].obs;

  RxList<AccountVoucherModel> accountVouchers = <AccountVoucherModel>[].obs;
  Rx<AccountVoucherModel> selectedVoucher = AccountVoucherModel().obs;


  final mongoProductRepo = Get.put(MongoProductRepo());
  final mongoUserRepository = Get.put(MongoUserRepository());
  final mongoPaymentMethodsRepo = Get.put(MongoAccountsRepo());
  final mongoAccountVoucherRepo = Get.put(MongoAccountVoucherRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  void onClose() {
    super.onClose();
    _clearItems();
  }

  void _clearItems() {
    products.clear();
    selectedProducts.clear();
    accountVouchers.clear();
    selectedVoucher.value = AccountVoucherModel();
  }

  // Get all products with optional search query
  void confirmSelection({required BuildContext context, required AccountVoucherType voucherType}) {
    if(voucherType == AccountVoucherType.product) {
      Navigator.of(context).pop(selectedProducts.toList());
      selectedProducts.clear();
    } else {
      Navigator.of(context).pop(selectedVoucher.value);
      selectedVoucher.value = AccountVoucherModel();
    }
  }


  void toggleAccountVoucherSelection({required AccountVoucherModel voucher}) {
    if (selectedVoucher.value.id == voucher.id) {
      selectedVoucher.value = AccountVoucherModel(); // Deselect
    } else {
      selectedVoucher.value = voucher; // Select
    }
  }


  // Toggle product selection
  void toggleProductSelection(ProductModel product) {
    if (selectedProducts.contains(product)) {
      selectedProducts.remove(product); // Deselect
    } else {
      selectedProducts.add(product); // Select
    }
  }

  // Get all products with optional search query
  int getItemsCount({required AccountVoucherType voucherType}) {
    if(voucherType == AccountVoucherType.product){
      return selectedProducts.length;
    }else{
      return selectedVoucher.value.id != null ? 1 : 0;
    }
  }

  // Get all products with optional search query
  Future<void> getItemsBySearchQuery({required String query, required AccountVoucherType voucherType, required int page}) async {
    try {
      if(query.isNotEmpty) {
        if(voucherType == AccountVoucherType.product) {
          await getProductsBySearchQuery(query: query, page: page);
        } else {
          await getVouchersBySearchQuery(query: query, voucherType: voucherType, page: page);
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> getProductsBySearchQuery({required String query, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final fetchedProducts = await mongoProductRepo.fetchProductsBySearchQuery(query: query, page: page);
        for (var product in fetchedProducts) {
          if (!products.any((p) => p.productId == product.productId)) {
            products.add(product);
          }
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get all Customers Voucher with optional search query
  Future<void> getVouchersBySearchQuery({required String query, required AccountVoucherType voucherType, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final fetchedAccountVouchers = await mongoAccountVoucherRepo.fetchVouchersBySearchQuery(
            query: query,
            voucherType: voucherType,
            userId: userId,
            page: page
        );
        for (var voucher in fetchedAccountVouchers) {
          if (!accountVouchers.any((a) => a.id == voucher.id)) {
            accountVouchers.add(voucher);
          }
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> refreshSearch({required String query, required AccountVoucherType voucherType}) async {
    try {
      isLoading(true);
      currentPage.value = 1;
      products.clear();
      accountVouchers.clear();
      await getItemsBySearchQuery(query: query, voucherType: voucherType, page: 1);
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }
}