import 'package:ara_finance/utils/constants/enums.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../features/accounts/models/account_voucher_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoAccountVoucherRepo extends GetxController {
  static MongoAccountVoucherRepo get instance => Get.find();

  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final String collectionName = DbCollections.accountVouchers;
  final int itemsPerPage = int.tryParse(APIConstant.itemsPerPage) ?? 10;

  // Fetch vouchers by search query & pagination
  Future<List<AccountVoucherModel>> fetchVouchersBySearchQuery({
    required String query,
    int page = 1,
    required AccountVoucherType voucherType,
    required String userId
  }) async {
    try {
      final List<Map<String, dynamic>> voucherData =
      await _mongoFetch.fetchDocumentsBySearchQuery(
        collectionName: collectionName,
        query: query,
        itemsPerPage: itemsPerPage,
        filter: {AccountVoucherFieldName.voucherType: voucherType.name, AccountVoucherFieldName.userId: userId},
        page: page,
      );
      return voucherData.map((data) => AccountVoucherModel.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch account vouchers: $e';
    }
  }

  // Fetch all vouchers from MongoDB
  Future<List<AccountVoucherModel>> fetchAllVouchers({required String userId, required AccountVoucherType voucherType, int page = 1}) async {
    try {
      final List<Map<String, dynamic>> voucherData =
      await _mongoFetch.fetchDocuments(
        collectionName: collectionName,
        filter: {AccountVoucherFieldName.userId: userId, AccountVoucherFieldName.voucherType: voucherType.name},
        page: page,
      );
      return voucherData.map((data) => AccountVoucherModel.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch account vouchers: $e';
    }
  }

  // Upload a new voucher
  Future<void> pushVoucher({required AccountVoucherModel voucher}) async {
    try {
      Map<String, dynamic> voucherMap = voucher.toMap();
      await _mongoInsert.insertDocument(collectionName, voucherMap);
    } catch (e) {
      throw 'Failed to upload account voucher: $e';
    }
  }

  // Fetch voucher by ID
  Future<AccountVoucherModel> fetchVoucherById({required String id}) async {
    try {
      final Map<String, dynamic> voucherData =
      await _mongoFetch.fetchDocumentById(collectionName: collectionName, id: id);
      return AccountVoucherModel.fromJson(voucherData);
    } catch (e) {
      throw 'Failed to fetch account voucher: $e';
    }
  }

  // Update a voucher
  Future<void> updateVoucher({required String id, required AccountVoucherModel voucher}) async {
    try {
      Map<String, dynamic> voucherMap = voucher.toJson();
      await _mongoUpdate.updateDocumentById(
        id: id,
        collectionName: collectionName,
        updatedData: voucherMap,
      );
    } catch (e) {
      throw 'Failed to update account voucher: $e';
    }
  }

  // Delete a voucher
  Future<void> deleteVoucher({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      throw 'Failed to delete account voucher: $e';
    }
  }

  // Get the next voucher ID
  Future<int> fetchVoucherGetNextId({required String userId, required AccountVoucherType voucherType}) async {
    try {
      return await _mongoFetch.fetchNextId(
        collectionName: collectionName,
        filter: {AccountVoucherFieldName.userId: userId, AccountVoucherFieldName.voucherType: voucherType.name},
        fieldName: AccountVoucherFieldName.voucherId,
      );
    } catch (e) {
      throw 'Failed to fetch next account voucher ID: $e';
    }
  }

  // Get the next voucher ID
  Future<double> fetchVoucherBalance({required String voucherId}) async {
    try {
      final amount = await _mongoFetch.calculateVoucherBalance(
        collectionName: DbCollections.transactions,
        voucherId: voucherId
      );
      return amount;
    } catch (e) {
      throw 'Failed to fetch account voucher balance: $e';
    }
  }

  // Fetch vouchers by date
  Future<List<AccountVoucherModel>> fetchVouchersByDate({
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
  }) async {
    try {
      final List<Map<String, dynamic>> voucherData = await _mongoFetch.fetchDocumentsDate(
        collectionName: collectionName,
        filter: {AccountVoucherFieldName.userId: userId},
        startDate: startDate,
        endDate: endDate,
      );
      return voucherData.map((data) => AccountVoucherModel.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch account vouchers by date: $e';
    }
  }
}
