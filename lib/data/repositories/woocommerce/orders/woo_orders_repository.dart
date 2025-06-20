import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../features/accounts/models/order_model.dart';
import '../../../../utils/constants/api_constants.dart';


class WooOrdersRepository extends GetxController {
  static WooOrdersRepository get instance => Get.find();

  void _ensureCredentialsInitialized() {
    if (APIConstant.wooBaseDomain.isEmpty ||
        APIConstant.wooConsumerKey.isEmpty ||
        APIConstant.wooConsumerSecret.isEmpty) {
      throw Exception('WooCommerce credentials are not initialized.');
    }
  }

  // Fetch Orders Count
  Future<int> fetchOrdersCount() async {
    try {
      final Map<String, String> queryParams = {
        'per_page': '1',
        'page': '1',
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooOrdersApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Extract total product count from response headers
        String? orderTotal = response.headers['x-wp-total'];
        return orderTotal != null ? int.parse(orderTotal) : 0;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch orders count';
      }
    } catch (error) {
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // fetchShippedOrders
  Future<List<OrderModel>> fetchOrdersByStatus({required List<String> status, required String page}) async {
    try{
      _ensureCredentialsInitialized();
      final Map<String, String> queryParams = {
        'status': status.join(','), // Joins list elements into a single string
        'orderby': 'date', //date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': APIConstant.itemsPerPageSync,
        'page': page,
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooOrdersApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        final List<OrderModel> orders = ordersJson.map((json) => OrderModel.fromJsonWoo(json)).toList();
        return orders;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Orders';
      }
    } catch(error){
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // Fetch All Orders
  Future<List<OrderModel>> fetchAllOrders({required String page}) async {
    try{
      final Map<String, String> queryParams = {
        'orderby': 'date', //date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': APIConstant.itemsPerPage,
        'page': page,
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooOrdersApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        final List<OrderModel> orders = ordersJson.map((json) => OrderModel.fromJsonWoo(json)).toList();
        return orders;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Orders';
      }
    } catch(error){
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // Fetch orders by customer's id
  Future<List<OrderModel>> fetchOrdersByCustomerId({required String customerId, required String page}) async {
    try {
      final Map<String, String> queryParams = {
        'customer': customerId,
        'orderby': 'date', //date, id, include, title and slug. Default is date.
        'per_page': '20',
        'page': page,
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooOrdersApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        final List<OrderModel> orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
        return orders;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Orders';
      }
    } catch (error) {
      rethrow;
    }
  }

  // Fetch orders by customer's email
  Future<List<OrderModel>> fetchOrdersByCustomerEmail({required String customerEmail, required String page}) async {
    try {
      final Map<String, String> queryParams = {
        // 'customer': customersId,
        'search': customerEmail,
        'orderby': 'date', //date, id, include, title and slug. Default is date.
        'per_page': '10',
        'page': page,
      };

      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooOrdersApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersJson = json.decode(response.body);
        final List<OrderModel> orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
        return orders;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Orders';
      }
    } catch (error) {
      rethrow;
    }
  }

  // Cancel order
  Future<OrderModel> updateStatusByOrderId(String orderId, String status) async {
    try {
      Map<String, dynamic> data = {
        'status': status,
      };
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooOrdersApiPath + orderId,
      );
      final http.Response response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': APIConstant.authorization,
        },
        body: jsonEncode(data),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        final Map<String, dynamic> orderJson = json.decode(response.body);
        final OrderModel order = OrderModel.fromJson(orderJson);
        return order;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to update order status';
      }
    } catch (error) {
      rethrow;
    }
  }

  // Fetch order by id
  Future<OrderModel> fetchOrderById({required String orderId}) async {

    try {
      final Uri uri = Uri.https(
        APIConstant.wooBaseDomain,
        APIConstant.wooOrdersApiPath + orderId,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': APIConstant.authorization,
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> orderJson = json.decode(response.body);
        final OrderModel order = OrderModel.fromJsonWoo(orderJson);
        return order;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Order #$orderId';
      }
    } catch (error) {
      print('--------------------$error');
      rethrow;
    }
  }

}