import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../features/accounts/models/expense_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoExpenseRepo extends GetxController {
  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final String collectionName = DbCollections.expenses;
  final int itemsPerPage = int.tryParse(APIConstant.itemsPerPage) ?? 10;

  // Fetch expenses by search query & pagination
  Future<List<ExpenseModel>> fetchExpensesBySearchQuery({required String query, int page = 1}) async {
    try {
      final List<Map<String, dynamic>> expensesData =
      await _mongoFetch.fetchDocumentsBySearchQuery(
          collectionName: collectionName,
          query: query,
          itemsPerPage: itemsPerPage,
          page: page
      );
      return expensesData.map((data) => ExpenseModel.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch Expenses: $e';
    }
  }

  // Fetch all expenses from MongoDB
  Future<List<ExpenseModel>> fetchAllExpenses({int page = 1, required String userId}) async {
    try {
      final List<Map<String, dynamic>> expensesData =
      await _mongoFetch.fetchDocuments(
          collectionName: collectionName,
          filter: {ExpenseFieldName.userId: userId},
          page: page
      );
      return expensesData.map((data) => ExpenseModel.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch expenses: $e';
    }
  }

  // Upload a new expense
  Future<void> pushExpense({required ExpenseModel expense}) async {
    try {
      Map<String, dynamic> expenseMap = expense.toMap();
      await _mongoInsert.insertDocument(collectionName, expenseMap);
    } catch (e) {
      throw 'Failed to upload expense: $e';
    }
  }

  // Fetch expense by ID
  Future<ExpenseModel> fetchExpenseById({required String id}) async {
    try {
      final Map<String, dynamic>? expenseData =
      await _mongoFetch.fetchDocumentById(collectionName: collectionName, id: id);
      if (expenseData == null) {
        throw Exception('Expense not found with ID: $id');
      }
      return ExpenseModel.fromJson(expenseData);
    } catch (e) {
      throw 'Failed to fetch expense: $e';
    }
  }

  // Update an expense
  Future<void> updateExpense({required String id, required ExpenseModel expense}) async {
    try {
      Map<String, dynamic> expenseMap = expense.toJson();
      await _mongoUpdate.updateDocumentById(id: id, collectionName: collectionName, updatedData: expenseMap);
    } catch (e) {
      throw 'Failed to update expense: $e';
    }
  }

  // Delete an expense
  Future<void> deleteExpense({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      throw 'Failed to delete expense: $e';
    }
  }

  // Get the next expense ID
  Future<int> fetchExpenseGetNextId({required String userId}) async {
    try {
      return await _mongoFetch.fetchNextId(
          collectionName: collectionName,
          filter: {ExpenseFieldName.userId: userId},
          fieldName: ExpenseFieldName.expenseId
      );
    } catch (e) {
      throw 'Failed to fetch expense ID: $e';
    }
  }

  Future<List<ExpenseModel>> fetchExpensesByDate({
    required DateTime startDate, required DateTime endDate, required String userId,}) async {
    try {
      final List<Map<String, dynamic>> expensesData = await _mongoFetch.fetchDocumentsDate(
          collectionName: collectionName,
          filter: {ExpenseFieldName.userId: userId},
          startDate: startDate,
          endDate: endDate
      );
      return expensesData.map((data) => ExpenseModel.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }
}
