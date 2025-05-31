import 'dart:async';
import 'package:get/get.dart';

import '../../../../features/accounts/models/order_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_search.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoOrderRepo extends GetxController {
  static MongoOrderRepo get instance => Get.find();
  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final MongoSearch _mongoSearch = MongoSearch();
  final String collectionName = DbCollections.orders;
  final int itemsPerPage = int.tryParse(APIConstant.itemsPerPage) ?? 10;

  // Fetch orders by search query & pagination
  Future<List<OrderModel>> fetchOrdersBySearchQuery({required OrderType orderType, required String userId, required String query, int page = 1}) async {
    try {
      // Fetch orders from MongoDB with search and pagination
      final List<Map<String, dynamic>> ordersData =
          await _mongoFetch.fetchDocumentsBySearchQuery(
              collectionName: collectionName,
              filter: {OrderFieldName.orderType: orderType.name, OrderFieldName.userId: userId},
              query: query,
              itemsPerPage: itemsPerPage,
              page: page
          );
      // Convert data to a list of OrdersModel
      final List<OrderModel> orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();
      return orders;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch orders by search query & pagination
  Future<List<OrderModel>> fetchOrdersByManualSearch({required OrderType orderType, required String userId, required String query, int page = 1}) async {
    try {
      // Fetch orders from MongoDB with search and pagination
      final List<Map<String, dynamic>> ordersData =
      await _mongoSearch.searchDocumentsByFields1(
          collectionName: collectionName,
          searchTerm: query,
          // searchFields: [OrderFieldName.orderId, OrderFieldName.invoiceNumber, OrderFieldName.status],
          searchFields: [OrderFieldName.orderId],
          filter: {OrderFieldName.orderType: orderType.name, OrderFieldName.userId: userId},
          itemsPerPage: itemsPerPage,
          page: page
      );
      // Convert data to a list of OrdersModel
      final List<OrderModel> orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();
      return orders;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch All Sales from MongoDB
  Future<List<OrderModel>> fetchOrders({required OrderType orderType, required String userId, int page = 1}) async {
    try {
      final List<Map<String, dynamic>> ordersData = await _mongoFetch.fetchDocuments(
          collectionName: collectionName,
          filter: {OrderFieldName.orderType: orderType.name, OrderFieldName.userId: userId},
          page: page);
      final List<OrderModel> orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();
      return orders;
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  Future<List<OrderModel>> fetchOrdersByDate({
    required OrderType orderType,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final filter = {OrderFieldName.orderType: orderType.name, OrderFieldName.userId: userId};

      final List<Map<String, dynamic>> ordersData = await _mongoFetch.fetchDocumentsDate(
        collectionName: collectionName,
        filter: filter,
        startDate: startDate,
        endDate: endDate
      );
      return ordersData.map((data) => OrderModel.fromJson(data)).toList();
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

  // Fetch Orders by IDs from MongoDB
  Future<List<OrderModel>> fetchOrdersByIds(List<int> ordersIds) async {
    try {
      if (ordersIds.isEmpty) return []; // Return empty list if no IDs provided

      // Fetch orders from MongoDB where the ID matches any in the list
      final List<Map<String, dynamic>> ordersData = await _mongoFetch.fetchDocumentsByFieldName(
        collectionName:  collectionName,
        fieldName: OrderFieldName.orderId,
        documentIds: ordersIds,
      );

      // Convert data to a list of OrdersModel
      final List<OrderModel> orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();

      return orders;
    } catch (e) {
      throw 'Failed to fetch orders by IDs: $e';
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

  // Update a order
  Future<void> updateOrder({required OrderModel order}) async {
    try {
      Map<String, dynamic> customerMap = order.toMap();
        await _mongoUpdate.updateDocumentById(
            id: order.id ?? '',
            collectionName: collectionName,
            updatedData: customerMap
        );
    } catch (e) {
      throw 'Failed to update order: $e';
    }
  }

  Future<void> updateOrders({required List<OrderModel> orders, required Map<String, dynamic> updatedData}) async {
    try {
      if (orders.isEmpty) {
        throw Exception('❌ No orders provided');
      }

      final orderIds = orders.map((order) => order.id).where((id) => id != null && id.isNotEmpty).toList();

      if (orderIds.length != orders.length) {
        throw Exception('🚫 Some orders have missing or invalid IDs');
      }

      await _mongoUpdate.updateManyDocumentsById(
        collectionName: collectionName,
        ids: orderIds.cast<String>(),
        updatedData: updatedData,
      );
    } on FormatException catch (e) {
      throw Exception('🆔 ID Error in order list: ${e.message}');
    } catch (e) {
      throw Exception('❌ Failed to update orders: ${e.toString()}');
    }
  }

  // Update a order
  Future<void> updateOrdersPaymentByOrderId({required List<int> orderNumbers}) async {
    try {
      await _mongoUpdate.updateDocuments(
          collectionName: collectionName,
          filter: {
            OrderFieldName.orderId: {'\$in': orderNumbers},
          },
          updatedData: {
            OrderFieldName.status: OrderStatus.completed.name,
            OrderFieldName.dateCompleted: DateTime.now(),
          }
      );
    } catch (e) {
      throw 'Failed to update order: $e';
    }
  }

  Future<void> updateOrdersStatus({required List<OrderModel> orders, required OrderStatus newStatus}) async {
    try {
      if (orders.isEmpty) {
        throw Exception('❌ No orders provided');
      }

      final orderIds = orders.map((order) => order.id).where((id) => id != null && id.isNotEmpty).toList();

      if (orderIds.length != orders.length) {
        throw Exception('🚫 Some orders have missing or invalid IDs');
      }

      await _mongoUpdate.updateManyDocumentsById(
        collectionName: collectionName,
        ids: orderIds.cast<String>(),
        updatedData: {
          OrderFieldName.status: newStatus.name,
          if (newStatus == OrderStatus.completed)
            OrderFieldName.dateCompleted: DateTime.now(),
          if (newStatus == OrderStatus.returned)
            OrderFieldName.dateReturned: DateTime.now(),
        },
      );
    } on FormatException catch (e) {
      throw Exception('🆔 ID Error in order list: ${e.message}');
    } catch (e) {
      throw Exception('❌ Failed to update orders: ${e.toString()}');
    }
  }

  // Get the total count of purchases in the collection
  Future<int> fetchOrderGetNextId({required OrderType orderType, required String userId}) async {
    try {
      int nextID = await _mongoFetch.fetchNextId(
          collectionName: collectionName,
          fieldName: OrderFieldName.invoiceNumber,
          filter: {OrderFieldName.orderType: orderType.name, OrderFieldName.userId: userId},
      );
      return nextID;
    } catch (e) {
      throw 'Failed to fetch sale id: $e';
    }
  }

  // Delete a purchase
  Future<void> deleteOrderById({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      throw 'Failed to Delete sale: $e';
    }
  }

  Future<OrderModel> fetchOrderById({required String saleId}) async {
    try {
      final Map<String, dynamic> orderData = await _mongoFetch.fetchDocumentById(id: saleId, collectionName: collectionName);
      final OrderModel order = OrderModel.fromJson(orderData);
      return order;
    } catch (e) {
      throw 'Failed to Delete sale: $e';
    }
  }

  Future<OrderModel> fetchOrderByOrderId({required int orderId, required OrderType orderType}) async {
    try {
      // Check if a user with the provided email exists
      final saleData = await _mongoFetch.findOne(
        collectionName: collectionName,
        filter: {
          OrderFieldName.orderId: orderId,
          OrderFieldName.orderType: orderType.name, // assuming you're storing userType as a string like 'admin'
        },
      );
      if (saleData == null) {
        throw 'Invalid order id no order found'; // User not found
      }
      final OrderModel sale = OrderModel.fromJson(saleData);
      return sale;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch All Products from MongoDB
  Future<double> fetchStockValueOfInTransit({required OrderType orderType, required OrderStatus orderStatus}) async {
    try {
      final double totalStockValue = await _mongoFetch.fetchInTransitStockValue(collectionName: collectionName, orderType: orderType, orderStatus: orderStatus);
      return totalStockValue;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch All Sales from MongoDB
  Future<List<OrderModel>> fetchOrdersByProductId({required int productId, required String userId, int page = 1}) async {
    try {
      final List<Map<String, dynamic>> ordersData = await _mongoFetch.fetchDocuments(
          collectionName: collectionName,
          filter: {'${OrderFieldName.lineItems}.${CartFieldName.productId}': productId, OrderFieldName.userId: userId},
          page: page);
      final List<OrderModel> orders = ordersData.map((data) => OrderModel.fromJson(data)).toList();
      return orders;
    } catch (e) {
      throw 'Failed to fetch orders: $e';
    }
  }

}
