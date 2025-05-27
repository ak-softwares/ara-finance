import 'package:get/get.dart';

import '../../../../features/accounts/models/order_model.dart';
import '../../../../features/accounts/models/purchase_item_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoPurchaseListRepo extends GetxController {
  static MongoPurchaseListRepo get instance => Get.find();
  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final String collectionName = DbCollections.purchaseList;
  final String collectionNameMetaData = DbCollections.meta;
  final int itemsPerPage = int.tryParse(APIConstant.itemsPerPageSync) ?? 10;

  // Fetch All Orders from MongoDB
  Future<List<OrderModel>> fetchOrders({required String userId, int page = 1}) async {
    try {

      // Fetch orders from MongoDB with pagination
      final List<Map<String, dynamic>> ordersData = await _mongoFetch.fetchDocuments(
          collectionName:collectionName,
          filter: {UserFieldConstants.userId: userId},
          page: page,
          itemsPerPage: itemsPerPage
      );

      // Convert data to a list of OrdersModel
      final List<OrderModel> orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();

      return orders;
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  // Upload multiple orders
  Future<void> pushOrders({required List<OrderModel> orders}) async {
    try {
      List<Map<String, dynamic>> ordersMaps = orders.map((order) => order.toMap()).toList();
          await _mongoInsert.insertDocuments(collectionName, ordersMaps); // Use batch insert function
    } catch (e) {
      throw 'Failed to upload orders: $e';
    }
  }

  // Delete all orders from the collection
  Future<void> deleteAllOrders({required String userId}) async {
    try {
      // Use an empty filter to match all documents in the collection
      await _mongoDelete.deleteDocuments(
          collectionName: collectionName,
          filter: {UserFieldConstants.userId: userId}
      );
    } catch (e) {
      throw 'Failed to delete all orders: $e';
    }
  }

  // Fetch All Orders from MongoDB
  Future<PurchaseListMetaModel> fetchMetaData({required String userId}) async {
    try {
      // Fetch orders from MongoDB with pagination
      final jsonData = await _mongoFetch.findOne(
          collectionName: collectionNameMetaData,
          filter: { UserFieldConstants.userId: userId},
      );
      return PurchaseListMetaModel.fromJson(jsonData!);
    } catch (e) {
      throw 'Failed to fetch Meta data: $e';
    }
  }

  Future<void> pushMetaData({required Map<String, dynamic> value, required String userId}) async {
    try {
      await _mongoUpdate.updateDocument(
          collectionName: collectionNameMetaData,
          filter: {UserFieldConstants.userId: userId},
          updatedData: value
      );
    } catch (e) {
      throw Exception('Failed to push metadata: $e');
    }
  }

  Future<void> deleteMetaData({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(
        collectionName: collectionNameMetaData,
        id: id,
      );
    } catch (e) {
      throw Exception('Failed to delete metadata: $e');
    }
  }

}