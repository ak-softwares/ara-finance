import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../../features/accounts/models/transaction_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoTransactionRepo extends GetxController {
  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final String collectionName = DbCollections.transactions;
  final int itemsPerPage = int.tryParse(APIConstant.itemsPerPage) ?? 10;

  // Fetch transactions by search query & pagination
  Future<List<TransactionModel>> fetchTransactionsBySearchQuery({
    required String query,
    int page = 1,
    AccountVoucherType? voucherType,
    required String userId
  }) async {
    try {
      final Map<String, String> filter = {
        TransactionFieldName.userId: userId,
        if (voucherType != null) TransactionFieldName.transactionType: voucherType.name,
      };
      // Fetch transactions from MongoDB with search and pagination
      final List<Map<String, dynamic>> transactionsData = await _mongoFetch.fetchDocumentsBySearchQuery(
          collectionName: collectionName,
          query: query,
          filter: filter,
          itemsPerPage: itemsPerPage,
          page: page
      );
      // Convert data to a list of TransactionModel
      final List<TransactionModel> transactions = transactionsData.map((data) => TransactionModel.fromJson(data)).toList();

      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch All Transactions from MongoDB
  Future<List<TransactionModel>> fetchAllTransactions({int page = 1, required String userId}) async {
    try {
      // Fetch transactions from MongoDB with pagination
      final List<Map<String, dynamic>> transactionData =
      await _mongoFetch.fetchDocuments(
          collectionName: collectionName,
          filter: {TransactionFieldName.userId: userId},
          page: page
      );
      // Convert data to a list of TransactionModel
      final List<TransactionModel> transactions = transactionData.map((data) => TransactionModel.fromJson(data)).toList();
      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchTransactionsByDate({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    AccountVoucherType? voucherType,
    int page = 1,
  }) async {
    try {
      final List<Map<String, dynamic>> transactionData = await _mongoFetch.fetchDocumentsDate(
        collectionName: collectionName,
        filter: {TransactionFieldName.userId: userId, TransactionFieldName.transactionType: voucherType?.name},
        startDate: startDate,
        endDate: endDate
      );

      final List<TransactionModel> transactions = transactionData.map((data) => TransactionModel.fromJson(data)).toList();
      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  // Upload a transaction
  Future<String> pushTransaction({required TransactionModel transaction}) async {
    try {
      Map<String, dynamic> transactionMap = transaction.toMap(); // Convert a single transaction to a map
      final String transactionId = await _mongoInsert.insertDocumentGetId(collectionName, transactionMap);
      return transactionId;
    } catch (e) {
      throw 'Failed to upload transaction: $e';
    }
  }

  // Upload multiple orders
  Future<void> pushTransactions({required List<TransactionModel> transactions}) async {
    try {
      List<Map<String, dynamic>> ordersMaps = transactions.map((order) => order.toMap()).toList();
      await _mongoInsert.insertDocuments(collectionName, ordersMaps); // Use batch insert function
    } catch (e) {
      throw 'Failed to upload orders: $e';
    }
  }

  // Fetch transaction by id
  Future<TransactionModel> fetchTransactionById({required String id}) async {
    try {
      // Fetch a single document by ID
      final Map<String, dynamic>? transactionData =
      await _mongoFetch.fetchDocumentById(collectionName: collectionName, id: id);

      // Check if the document exists
      if (transactionData == null) {
        throw Exception('Transaction not found with ID: $id');
      }
      // Convert the document to a TransactionModel object
      final TransactionModel transaction = TransactionModel.fromJson(transactionData);
      return transaction;
    } catch (e) {
      throw 'Failed to fetch transaction: $e';
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      rethrow;
    }
  }

  // Get the next id
  Future<int> fetchTransactionGetNextId({required String userId, required AccountVoucherType voucherType}) async {
    try {
      int nextID = await _mongoFetch.fetchNextId(
          collectionName: collectionName,
          filter: {TransactionFieldName.userId: userId, TransactionFieldName.transactionType: voucherType.name},
          fieldName: TransactionFieldName.transactionId
      );
      return nextID;
    } catch (e) {
      throw 'Failed to fetch transaction id: $e';
    }
  }

  Future<List<TransactionModel>> fetchTransactionByEntity({required String voucherId, int page = 1}) async {
    try {
      // Fetch transactions matching the given entity type and ID
      final List<Map<String, dynamic>> transactionData =
            await _mongoFetch.fetchTransactionByEntity(
              collectionName: collectionName,
                voucherId: voucherId,
              page: page
            );

      // Convert data to a list of TransactionModel
      final List<TransactionModel> transactions =
            transactionData.map((data) => TransactionModel.fromJson(data)).toList();

      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchTransactionByProductId({required int productId, int page = 1}) async {
    try {
      // Fetch transactions matching the given entity type and ID
      final List<Map<String, dynamic>> transactionData =
      await _mongoFetch.fetchTransactionByProductId(
          collectionName: collectionName,
          productId: productId,
          page: page
      );

      // Convert data to a list of TransactionModel
      final List<TransactionModel> transactions =
      transactionData.map((data) => TransactionModel.fromJson(data)).toList();

      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> fetchTransactionWithFilter({required Map<String, dynamic> filter}) async {
    try {
      // Fetch transactions matching the given entity type and ID
      final Map<String, dynamic>? transactionData =
          await _mongoFetch.findOne(collectionName: collectionName, filter: filter);

      // Convert data to a list of TransactionModel
      if(transactionData != null){
        final TransactionModel transaction = TransactionModel.fromJson(transactionData);
        return transaction;
      }else{
        return TransactionModel();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<TransactionModel>> fetchTransactionsWithFilter({
    required Map<String, dynamic> filter,
  }) async {
    try {
      final List<Map<String, dynamic>> transactionDataList =
      await _mongoFetch.findMany(collectionName: collectionName, filter: filter);

      return transactionDataList
          .map((data) => TransactionModel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update a transaction
  Future<void> updateTransactionById({required String id, required TransactionModel transaction}) async {
    try {
      Map<String, dynamic> transactionMap = transaction.toJson();
      await _mongoUpdate.updateDocumentById(id: id, collectionName: collectionName, updatedData: transactionMap);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransactions({required List<String> ids, required Map<String, dynamic> updatedData}) async {
    try{
      await _mongoUpdate.updateManyDocumentsById(
        collectionName: collectionName,
        ids: ids,
        updatedData: updatedData
      );
    }catch(e){
      rethrow;
    }
  }
}