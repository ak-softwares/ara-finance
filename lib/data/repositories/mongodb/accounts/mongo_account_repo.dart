import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../features/accounts/models/account_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoAccountsRepo extends GetxController {
  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final String collectionName = DbCollections.accounts;
  final int itemsPerPage = int.tryParse(APIConstant.itemsPerPage) ?? 10;

  // Fetch products by search query & pagination
  Future<List<AccountModel>> fetchAccountsBySearchQuery({required String query, int page = 1}) async {
    try {
      // Fetch products from MongoDB with search and pagination
      final List<Map<String, dynamic>> paymentsData =
      await _mongoFetch.fetchDocumentsBySearchQuery(
          collectionName: collectionName,
          query: query,
          itemsPerPage: itemsPerPage,
          page: page
      );
      // Convert data to a list of ProductModel
      final List<AccountModel> payments = paymentsData.map((data) => AccountModel.fromJson(data)).toList();
      return payments;
    } catch (e) {
      throw 'Failed to fetch Vendors: $e';
    }
  }

  // Fetch All Products from MongoDB
  Future<List<AccountModel>> fetchAllAccountsMethod({int page = 1, required String userId}) async {
    try {
      // Fetch products from MongoDB with pagination
      final List<Map<String, dynamic>> paymentMethodData =
      await _mongoFetch.fetchDocuments(
          collectionName:collectionName,
          filter: {AccountFieldName.userId: userId},
          page: page
      );
      // Convert data to a list of ProductModel
      final List<AccountModel> paymentMethod = paymentMethodData.map((data) => AccountModel.fromJson(data)).toList();
      return paymentMethod;
    } catch (e) {
      throw 'Failed to fetch payment method: $e';
    }
  }

  // Upload multiple products
  Future<void> pushAccountsMethod({required AccountModel paymentMethod}) async {
    try {
      Map<String, dynamic> paymentMap = paymentMethod.toMap(); // Convert a single vendor to a map
      await _mongoInsert.insertDocument(collectionName, paymentMap);
    } catch (e) {
      throw 'Failed to upload payment: $e';
    }
  }

  // Fetch payment by id
  Future<AccountModel> fetchAccountById({required String id}) async {
    try {
      // Fetch a single document by ID
      final Map<String, dynamic>? vendorData =
                  await _mongoFetch.fetchDocumentById(collectionName: collectionName, id: id);

      // Check if the document exists
      if (vendorData == null) {
        throw Exception('Payment not found with ID: $id');
      }
      // Convert the document to a PurchaseModel object
      final AccountModel payment = AccountModel.fromJson(vendorData);
      return payment;
    } catch (e) {
      throw 'Failed to fetch payment: $e';
    }
  }

  // Update a payment
  Future<void> updateAccount({required String id, required AccountModel account}) async {
    try {
      Map<String, dynamic> accountMap = account.toMap();
      await _mongoUpdate.updateDocumentById(id: id, collectionName: collectionName, updatedData: accountMap);
    } catch (e) {
      throw 'Failed to upload payment: $e';
    }
  }

  // Delete a payment
  Future<void> deleteAccount({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      throw 'Failed to Delete Payment: $e';
    }
  }

  // Get the next id
  Future<int> fetchAccountGetNextId({required String userId}) async {
    try {
      int nextID = await _mongoFetch.fetchNextId(
          collectionName: collectionName,
          filter: {AccountFieldName.userId: userId},
          fieldName: AccountFieldName.accountId
      );
      return nextID;
    } catch (e) {
      throw 'Failed to fetch payment id: $e';
    }
  }

  // Fetch All Products from MongoDB
  Future<double> fetchTotalBalance({required String userId}) async {
    try {
      // Fetch products from MongoDB with pagination
      final double totalStockValue = await _mongoFetch.fetchTotalAccountBalance(
          collectionName: collectionName,
          filter: {AccountFieldName.userId: userId},
      );
      return totalStockValue;
    } catch (e) {
      rethrow;
    }
  }
}