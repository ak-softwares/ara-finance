import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../../features/accounts/models/product_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../initialization/woocommerce_initialization.dart';

class WooProductRepository extends GetxController {
  static WooProductRepository get instance => Get.find();

  @override
  void onInit() {
    Woocommerce().initialize();
    super.onInit();
  }
  
  // Fetch Product Count
  Future<int> fetchProductCount() async {
    try {
      final Map<String, String> queryParams = {
        'per_page': '1',
        'page': '1',
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        // Extract total product count from response headers
        String? totalProducts = response.headers['x-wp-total'];
        return totalProducts != null ? int.parse(totalProducts) : 0;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch product count';
      }
    } catch (error) {
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // Fetch All Products
  Future<List<ProductModel>> fetchAllProducts({required String page}) async {
    try{
      final Map<String, String> queryParams = {
        // 'orderby': 'date', //date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': Woocommerce.wooItemsPerPageSync,
        'page': page,
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        // Uri.parse('https://aramarket.in/wp-json/wc/v3/products?category=246&orderby=popularity'),
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        final List<ProductModel> allProducts = productsJson.map((json) => ProductModel.fromJsonWoo(json)).toList();
        return allProducts;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products';
      }
    } catch(error){
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // Fetch All Featured Products
  Future<List<ProductModel>> fetchFeaturedProducts({required String page}) async {
    try{
      final Map<String, String> queryParams = {
        'featured': 'true',
        // 'orderby': 'popularity', //date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': '10',
        'page': page,
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        // Uri.parse('https://aramarket.in/wp-json/wc/v3/products?category=246&orderby=popularity'),
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        final List<ProductModel> productsByCategory =
        productsJson.map((json) => ProductModel.fromJson(json)).toList();
        return productsByCategory;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Featured Products';
      }
    } catch(error) {
      rethrow;
    }
  }

  // Fetch Products Under price
  Future<List<ProductModel>> fetchProductsUnderPrice({required String page, required String price}) async {
    try{
      final Map<String, String> queryParams = {
        'orderby': 'popularity', //date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': '10',
        'max_price': price,  // 'min_price': '199',
        'page': page,
        'stock_status': 'instock'  //instock, outofstock and onbackorder
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        // Uri.parse('https://aramarket.in/wp-json/wc/v3/products?category=246&orderby=popularity'),
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      );

      if (response.statusCode == 200) {
        final productsByCategory = await Isolate.run(() {
          final List<dynamic> productsJson = json.decode(response.body);
          return productsJson.map((json) => ProductModel.fromJson(json)).toList();
        });
        return productsByCategory;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Featured Products';
      }
    } catch(error) {
      rethrow;
    }
  }

  // Fetch Products By Category ID
  Future<List<ProductModel>> fetchProductsByCategoryID({required String categoryId, required String page}) async {
    try{
      final Map<String, String> queryParams = {
        'category': categoryId,
        'orderby': 'popularity',
        //date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': '10',
        'page': page,
        // 'page': page.toString(),
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        // Uri.parse('https://aramarket.in/wp-json/wc/v3/products?category=246&orderby=popularity'),
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        final List<ProductModel> productsByCategory =
        productsJson.map((json) => ProductModel.fromJson(json)).toList();
        return productsByCategory;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products by category';
      }
    } catch(error) {
      rethrow;
    }
  }

  // Fetch Products By Brand ID
  Future<List<ProductModel>> fetchProductsByBrandID({required String brandID, required String page}) async {
    try{
      final Map<String, String> queryParams = {
        'brand': brandID,
        'orderby': 'popularity', //date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': '10',
        'page': page,
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> productsByBrandIDJson = json.decode(response.body);
        final List<ProductModel> productsByBrandID = productsByBrandIDJson.map((json) => ProductModel.fromJson(json)).toList();
        return productsByBrandID;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products';
      }
    } catch(error){
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // Fetch Products By Ids
  Future<List<ProductModel>> fetchProductsByIds({required String productIds, required String page}) async {
    try{
      final Map<String, String> queryParams = {
        'include': productIds,
        'orderby' : 'include', // date, id, include, title, slug, price, popularity and rating. Default is date.
        'per_page': '10',
        'page': page,
        // 'page': page.toString(),
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        // Uri.parse('https://aramarket.in/wp-json/wc/v3/products?category=246&orderby=popularity'),
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      ).timeout(const Duration(seconds: 30)); // Set a timeout of 30 seconds for the HTTP request

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        final List<ProductModel> productsByCategory = productsJson.map((json) => ProductModel.fromJson(json)).toList();
        return productsByCategory;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products by Ids';
      }
    } catch(error) {
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // Fetch Products By Ids
  Future<List<ProductModel>> fetchVariationByProductsIds({required String parentID}) async {
    try {

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        '${Woocommerce.wooProductsApiPath}$parentID/variations/',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      ).timeout(const Duration(seconds: 30)); // Set a timeout of 30 seconds for the HTTP request

      if (response.statusCode == 200) {
        final List<dynamic> childrenJson = json.decode(response.body) as List<dynamic>;
        final List<ProductModel> childrenByParentID =
        childrenJson.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
        return childrenByParentID;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Children by parentID';
      }
    } catch(error) {
      if (error is TimeoutException) {
        throw 'Connection timed out. Please check your internet connection and try again.';
      } else {
        rethrow;
      }
    }
  }

  // Fetch Product By Id
  Future<ProductModel> fetchProductById(String productId) async {
    try{
      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath + productId,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> productJson = json.decode(response.body);
        final ProductModel product = ProductModel.fromJson(productJson);
        return product;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products by Ids';
      }
    } catch(error) {
      rethrow;
    }
  }

  // Fetch Product By Slug
  Future<ProductModel> fetchProductBySlug(String slug) async {
    try{
      final Map<String, String> queryParams = {
        'slug': slug,
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productJson = json.decode(response.body);
        if(productJson.isNotEmpty){
          final ProductModel product = ProductModel.fromJson(productJson.first);
          return product;
        } else{
          throw 'No Product found! Please try again';
        }
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products by Ids';
      }
    } catch(error) {
      rethrow;
    }
  }

  // Fetch Products By Search Query
  Future<List<ProductModel>> fetchProductsBySearchQuery({required String query, required String page}) async {
    try{
      final Map<String, String> queryParams = {
        'search': query,
        'orderby': 'popularity',
        //date, id, include, title, slug, price, popularity and rating. Default is date.
        'type': 'simple',
        //simple, grouped, external and variable. Default is simple
        'per_page': '10',
        'page': page,
        // 'page': page.toString(),
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooProductsApiPath,
        queryParams,
      );

      final response = await http.get(
        uri,
        // Uri.parse('https://aramarket.in/wp-json/wc/v3/products?category=246&orderby=popularity'),
        headers: {
          'Authorization': Woocommerce().authorization,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        final List<ProductModel> productsByCategory = productsJson.map((json) => ProductModel.fromJson(json)).toList();
        return productsByCategory;
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products search query';
      }
    } catch(error) {
      rethrow;
    }
  }

  // Fetch Frequently Bought Together Products
  Future<List<ProductModel>> fetchFBTProducts({required String productId}) async {
    try{
      final Map<String, String> queryParams = {
        'product_id': productId,
      };

      final Uri uri = Uri.https(
        Woocommerce().wooBaseDomain,
        Woocommerce.wooFBT,
        queryParams,
      );

      final response = await http.get(
        uri,
        // headers: {
        //   'Content-Type': 'application/json',
        // },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        // final List productsFBTStringList = productsJson.map((int value) => value.toString()).toList();
        if(productsJson.isNotEmpty){
          final List<ProductModel>  productsFBT = await fetchProductsByIds(productIds: productsJson.join(','), page: '1');
          return productsFBT;
        } else{
          return [];
        }
      } else {
        final Map<String, dynamic> errorJson = json.decode(response.body);
        final errorMessage = errorJson['message'];
        throw errorMessage ?? 'Failed to fetch Products search query';
      }
    } catch(error) {
      rethrow;
    }
  }
}