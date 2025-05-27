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
  Future<List<TransactionModel>> fetchTransactionsBySearchQuery({required String query, int page = 1}) async {
    try {
      // Fetch transactions from MongoDB with search and pagination
      final List<Map<String, dynamic>> transactionsData =
      await _mongoFetch.fetchDocumentsBySearchQuery(
          collectionName: collectionName,
          query: query,
          itemsPerPage: itemsPerPage,
          page: page
      );
      // Convert data to a list of TransactionModel
      final List<TransactionModel> transactions = transactionsData.map((data) => TransactionModel.fromJson(data)).toList();
      return transactions;
    } catch (e) {
      throw 'Failed to fetch Transactions: $e';
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
      throw 'Failed: $e';
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

  // Update a transaction
  Future<void> updateTransaction({required String id, required TransactionModel transaction}) async {
    try {
      Map<String, dynamic> transactionMap = transaction.toJson();
         await _mongoUpdate.updateDocumentById(id: id, collectionName: collectionName, updatedData: transactionMap);
    } catch (e) {
      throw 'Failed to update transaction: $e';
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }

  Future<void> deleteTransactionByPurchaseId({required int purchaseId}) async {
    try {
      // Fetch the transaction linked to the given purchase ID
      final transaction = await _mongoFetch.findOne(
        collectionName: collectionName,
        filter: {TransactionFieldName.purchaseId: purchaseId},
      );

      if (transaction == null) {
        throw 'No transaction found for the given purchase ID';
      }

      // Convert ObjectId to String before deletion
      final String transactionId = (transaction['_id'] as ObjectId).toHexString();

      // Delete the transaction
      await _mongoDelete.deleteDocumentById(
        id: transactionId,
        collectionName: collectionName,
      );
    } catch (e) {
      throw 'Failed to delete transaction: $e';
    }
  }

  Future<TransactionModel> findTransactionByPurchaseId({required int purchaseId}) async {
    try {
      // Fetch the transaction linked to the given purchase ID
      final transactionData = await _mongoFetch.findOne(
        collectionName: collectionName,
        filter: {TransactionFieldName.purchaseId: purchaseId},
      );

      if (transactionData == null) {
        throw 'No transaction found!';
      }

      // Convert JSON to TransactionModel and return
      return TransactionModel.fromJson(transactionData);
    } catch (e) {
      throw 'Failed to find transaction: $e';
    }
  }




  // Get the next id
  Future<int> fetchTransactionGetNextId({required String userId}) async {
    try {
      int nextID = await _mongoFetch.fetchNextId(
          collectionName: collectionName,
          filter: {TransactionFieldName.userId: userId},
          fieldName: TransactionFieldName.transactionId
      );
      return nextID;
    } catch (e) {
      throw 'Failed to fetch transaction id: $e';
    }
  }

  // Update Balance
  Future<void> updateBalanceById({required String collectionName, required String entityId, required double amount, required bool isAddition}) async {
    try {
      await _mongoUpdate.updateBalance(
          collectionName: collectionName,
          entityId: entityId,
          amount: amount,
          isAddition: isAddition,
      );
    } catch (e) {
      throw 'Failed to update balance: $e';
    }
  }

  Future<List<TransactionModel>> fetchTransactionByEntity({required EntityType entityType, required String entityId, int page = 1,}) async {
    try {

      // Fetch transactions matching the given entity type and ID
      final List<Map<String, dynamic>> transactionData =
            await _mongoFetch.fetchTransactionByEntity(
              collectionName: collectionName,
              entityType: entityType,
              entityId: entityId,
              page: page
            );

      // Convert data to a list of TransactionModel
      final List<TransactionModel> transactions =
            transactionData.map((data) => TransactionModel.fromJson(data)).toList();

      return transactions;
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

}