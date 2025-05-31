import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/accounts/mongo_account_repo.dart';
import '../../../../data/repositories/mongodb/orders/orders_repositories.dart';
import '../../../../data/repositories/mongodb/products/product_repositories.dart';
import '../../../../data/repositories/mongodb/user/user_repositories.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../personalization/models/user_model.dart';
import '../../models/order_model.dart';
import '../../models/account_model.dart';
import '../../models/product_model.dart';
import '../vendor/vendor_controller.dart';

class SearchVoucherController extends GetxController {
  static SearchVoucherController get instance => Get.find();

  // Variable
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxInt currentPage = 1.obs;
  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<ProductModel> selectedProducts = <ProductModel>[].obs;

  RxList<UserModel> vendors = <UserModel>[].obs;
  Rx<UserModel> selectedVendor = UserModel().obs;

  RxList<UserModel> customers = <UserModel>[].obs;
  Rx<UserModel> selectedCustomer = UserModel().obs;

  RxList<AccountModel> accounts = <AccountModel>[].obs;
  Rx<AccountModel> selectedAccounts = AccountModel().obs;

  RxList<OrderModel> sales = <OrderModel>[].obs;
  RxList<OrderModel> purchases = <OrderModel>[].obs;

  final mongoProductRepo = Get.put(MongoProductRepo());
  final mongoUserRepository = Get.put(MongoUserRepository());
  final mongoOrderRepo = Get.put(MongoOrderRepo());
  final vendorController = Get.put(VendorController());
  final mongoPaymentMethodsRepo = Get.put(MongoAccountsRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  void onClose() {
    super.onClose();
    _clearItems();
  }

  void _clearItems() {
    products.clear();
    vendors.clear();
    customers.clear();
    accounts.clear();
    sales.clear();
    purchases.clear();
    selectedProducts.clear();
    selectedVendor.value = UserModel();
    selectedCustomer.value = UserModel();
    selectedAccounts.value = AccountModel();
  }

  // Get all products with optional search query
  void confirmSelection({required BuildContext context, required SearchType searchType}) {
    switch (searchType) {
      case SearchType.products:
        Navigator.of(context).pop(selectedProducts.toList());
        selectedProducts.clear();
        break;
      case SearchType.customer:
        Navigator.of(context).pop(selectedCustomer.value);
        selectedCustomer.value = UserModel();
        break;
      case SearchType.sale:
        break;
      case SearchType.vendor:
        Navigator.of(context).pop(selectedVendor.value);
        selectedVendor.value = UserModel();
        break;
      case SearchType.account:
        Navigator.of(context).pop(selectedAccounts.value);
        selectedAccounts.value = AccountModel();
        break;
      case SearchType.purchase:
        break;
    }
  }

  void toggleAccountSelection(AccountModel account) {
    if (account.id == selectedAccounts.value.id) { // if already selected than deselect
      selectedAccounts.value = AccountModel();
    } else {
      selectedAccounts.value = account; // Select
    }
  }

  void toggleVendorSelection(UserModel vendor) {
    if (vendor.id == selectedVendor.value.id) {
      selectedVendor.value = UserModel();
    } else {
      selectedVendor.value = vendor; // Select
    }
  }

  void toggleCustomerSelection(UserModel customer) {
    if (customer.id == selectedCustomer.value.id) {
      selectedCustomer.value = UserModel();
    } else {
      selectedCustomer.value = customer; // Select
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
  int getItemsCount({required SearchType searchType}) {
      switch (searchType) {
        case SearchType.products:
          return selectedProducts.length;
        case SearchType.customer:
          return selectedCustomer.value.id != null ? 1 : 0;
        case SearchType.sale:
          // TODO: Handle this case.
          throw UnimplementedError();
        case SearchType.vendor:
          return selectedVendor.value.id != null ? 1 : 0;
        case SearchType.account:
          return selectedAccounts.value.id != null ? 1 : 0;
        case SearchType.purchase:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
  }

  // Get all products with optional search query
  Future<void> getItemsBySearchQuery({required String query, required SearchType searchType, required int page}) async {
    try {
      if(query.isNotEmpty) {
        switch (searchType) {
          case SearchType.products:
            await getProductsBySearchQuery(query: query, page: page);
            break;
          case SearchType.customer:
            await getCustomersBySearchQuery(query: query, page: page);
            break;
          case SearchType.sale:
            await getSalesBySearchQuery(query: query, page: page);
            break;
          case SearchType.vendor:
            await getVendorsBySearchQuery(query: query, page: page);
            break;
          case SearchType.account:
            await getAccountBySearchQuery(query: query, page: page);
            break;
          case SearchType.purchase:
            await getPurchaseBySearchQuery(query: query, page: page);
            break;
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


  // Get all products with optional search query
  Future<void> getCustomersBySearchQuery({required String query, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final fetchedCustomers = await mongoUserRepository.fetchUsersBySearchQuery(
            query: query, userType: UserType.customer, page: page, userId: userId);
        for (var customer in fetchedCustomers) {
          if (!customers.any((c) => c.id == customer.id)) {
            customers.add(customer);
          }
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get all products with optional search query
  Future<void> getVendorsBySearchQuery({required String query, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final fetchedVendors = await vendorController.getVendorsSearchQuery(query: query, page: page);
        for (var vendor in fetchedVendors) {
          if (!vendors.any((v) => v.id == vendor.id)) {
            vendors.add(vendor);
          }
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get all products with optional search query
  Future<void> getAccountBySearchQuery({required String query, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final fetchedPayments = await mongoPaymentMethodsRepo.fetchAccountsBySearchQuery(query: query, page: page);
        for (var account in fetchedPayments) {
          if (!accounts.any((a) => a.id == account.id)) {
            accounts.add(account);
          }
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get all products with optional search query
  Future<void> getSalesBySearchQuery({required String query, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final List<OrderModel> fetchedSales = await mongoOrderRepo.fetchOrdersByManualSearch(orderType: OrderType.sale, userId: userId, query: query, page: page);
        for (var sale in fetchedSales) {
          if (!sales.any((a) => a.id == sale.id)) {
            sales.add(sale);
          }
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Get all products with optional search query
  Future<void> getPurchaseBySearchQuery({required String query, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final List<OrderModel> fetchedPurchase = await mongoOrderRepo.fetchOrdersByManualSearch(orderType: OrderType.purchase, userId: userId, query: query, page: page);
        for (var purchase in fetchedPurchase) {
          if (!purchases.any((a) => a.id == purchase.id)) {
            purchases.add(purchase);
          }
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> refreshSearch({required String query, required SearchType searchType}) async {
    try {
      isLoading(true);
      currentPage.value = 1;
      products.clear();
      customers.clear();
      sales.clear();
      vendors.clear();
      await getItemsBySearchQuery(query: query, searchType: searchType, page: 1);
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }
}