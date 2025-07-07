import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/account_voucher/account_voucher_repo.dart';
import '../../../../data/repositories/mongodb/products/product_repositories.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/enums.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/account_voucher_model.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';

class SearchController1 extends GetxController {
  static SearchController1 get instance => Get.find();

  // Variable
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxInt currentPage = 1.obs;

  RxList<ProductModel> products = <ProductModel>[].obs;
  RxList<AccountVoucherModel> accountVouchers = <AccountVoucherModel>[].obs;
  RxList<TransactionModel> transactions = <TransactionModel>[].obs;


  final mongoProductRepo = Get.put(MongoProductRepo());
  final mongoAccountVoucherRepo = Get.put(MongoAccountVoucherRepo());
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  String get userId => AuthenticationController.instance.admin.value.id!;

  @override
  void onClose() {
    super.onClose();
    _clearItems();
  }

  void _clearItems() {
    products.clear();
    accountVouchers.clear();
    transactions.clear();
  }


  // Get all products with optional search query
  Future<void> getItemsBySearchQuery({
    required String query, required SearchType searchType,
    required int page, AccountVoucherType? voucherType
  }) async {
    try {
      if(query.isNotEmpty) {
        if(searchType == SearchType.product) {
          await getProductsBySearchQuery(query: query, page: page);
        }else if(searchType == SearchType.accountVoucher) {
          await getVouchersBySearchQuery(query: query, voucherType: voucherType!, page: page);
        }else if(searchType == SearchType.transaction) {
          await getTransactionsBySearchQuery(query: query, voucherType: voucherType, page: page);
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> refreshSearch({required String query, required SearchType searchType, AccountVoucherType? voucherType}) async {
    try {
      isLoading(true);
      currentPage.value = 1;
      products.clear();
      transactions.clear();
      accountVouchers.clear();
      await getItemsBySearchQuery(query: query, searchType: searchType, voucherType: voucherType, page: 1);
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
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
      rethrow;
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
      rethrow;
    }
  }

  // Get transaction by search query
  Future<void> getTransactionsBySearchQuery({required String query, AccountVoucherType? voucherType, required int page}) async {
    try {
      if (query.isNotEmpty) {
        final List<TransactionModel> fetchedTransactions = await mongoTransactionRepo.fetchTransactionsBySearchQuery(
            query: query,
            voucherType: voucherType,
            userId: userId,
            page: page
        );
        for (var transaction in fetchedTransactions) {
          if (!accountVouchers.any((a) => a.id == transaction.id)) {
            transactions.add(transaction);
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

}