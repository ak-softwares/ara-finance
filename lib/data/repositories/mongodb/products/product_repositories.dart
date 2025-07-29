import 'dart:async';
import 'package:get/get.dart';

import '../../../../features/accounts/models/cart_item_model.dart';
import '../../../../features/accounts/models/product_model.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/db_constants.dart';
import '../../../database/mongodb/mongo_delete.dart';
import '../../../database/mongodb/mongo_fetch.dart';
import '../../../database/mongodb/mongo_insert.dart';
import '../../../database/mongodb/mongo_update.dart';

class MongoProductRepo extends GetxController {

  static MongoProductRepo get instance => Get.find();
  final MongoFetch _mongoFetch = MongoFetch();
  final MongoInsert _mongoInsert = MongoInsert();
  final MongoUpdate _mongoUpdate = MongoUpdate();
  final MongoDelete _mongoDelete = MongoDelete();
  final String collectionName = DbCollections.products;
  final int itemsPerPage = int.tryParse(APIConstant.itemsPerPage) ?? 10;

  // Fetch products by search query & pagination
  Future<List<ProductModel>> fetchProductsBySearchQuery({required String query, int page = 1}) async {
    try {
      // Fetch products from MongoDB with search and pagination
      final List<Map<String, dynamic>> productData = await _mongoFetch.searchProductsWithStock(
          productCollectionName: collectionName,
          transactionCollectionName: DbCollections.transactions,
          searchQuery: query,
          itemsPerPage: itemsPerPage,
          page: page
      );

      // Convert data to a list of ProductModel
      final List<ProductModel> products = productData.map((data) => ProductModel.fromJson(data)).toList();
      return products;
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  // Fetch All Products from MongoDB
  Future<List<ProductModel>> fetchProductsWithStock({int page = 1, required String userId}) async {
    try {

      // Fetch products from MongoDB with pagination
      final List<Map<String, dynamic>> productData = await _mongoFetch.fetchProductsWithStock(
          productCollectionName: collectionName,
          transactionCollectionName: DbCollections.transactions,
          filter: { ProductFieldName.userId: userId },
          page: page
      );
      // Convert data to a list of ProductModel
      final List<ProductModel> products = productData.map((data) => ProductModel.fromJson(data)).toList();

      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductModel> fetchProductByIdWithStock({required String id}) async {
    try {
      // Fetch a single document by ID
      final Map<String, dynamic>? productData = await _mongoFetch.fetchProductByIdWithStock(
        productCollectionName: collectionName,
        transactionCollectionName: DbCollections.transactions,
        id: id,
      );

      // Check if the document exists
      if (productData == null) {
        throw Exception('Product not found with ID: $id');
      }

      // Convert the document to a ProductModel object
      final ProductModel product = ProductModel.fromJson(productData);
      return product;
    } catch (e) {
      throw 'Failed to fetch product: $e';
    }
  }

  Future<double> fetchTotalStockValue({required String userId}) async {
    try {
      // Fetch products from MongoDB with pagination
      final double totalStockValue = await _mongoFetch.calculateTotalStockValue(
        transactionCollectionName: DbCollections.transactions,
        filter: { ProductFieldName.userId: userId },
      );
      return totalStockValue;
    } catch (e) {
      rethrow;
    }
  }


  // Fetch Product's IDs from MongoDB
  Future<Set<int>> fetchProductIds({required String userId}) async {
    try {
      // Fetch product IDs from MongoDB
      return await _mongoFetch.fetchDocumentIds(
          collectionName: collectionName,
          userId: userId
      );
    } catch (e) {
      throw 'Failed to fetch product IDs: $e';
    }
  }

  // Fetch Products by IDs from MongoDB
  Future<List<ProductModel>> fetchProductsByProductIds({required List<int> productIds}) async {
    try {
      if (productIds.isEmpty) return []; // Return empty list if no IDs provided

      // Fetch products from MongoDB where the ID matches any in the list
      final List<Map<String, dynamic>> productData = await _mongoFetch.fetchProductsByProductIdsWithStock(
          productCollectionName: collectionName,
          transactionCollectionName: DbCollections.transactions,
          fieldName: ProductFieldName.productId,
          documentIds: productIds
      );

      // Convert data to a list of ProductModel
      final List<ProductModel> products = productData.map((data) => ProductModel.fromJson(data)).toList();

      return products;
    } catch (e) {
      rethrow;
    }
  }

 // Upload multiple products
  Future<void> pushProducts({required List<ProductModel> products}) async {
    try {
      List<Map<String, dynamic>> productMaps = products.map((product) => product.toMap()).toList();
      await _mongoInsert.insertDocuments(collectionName, productMaps); // Use batch insert function
    } catch (e) {
      throw 'Failed to upload products: $e';
    }
  }

  // Get the total count of products in the collection
  Future<int> fetchProductsCount({required String userId}) async {
    try {
      int count = await _mongoFetch.fetchCollectionCount(
        collectionName: collectionName,
        filter: { ProductFieldName.userId: userId},
      );
      return count;
    } catch (e) {
      throw 'Failed to fetch products count: $e';
    }
  }

  // Get the total count of products in the collection
  Future<int> fetchProductsActiveCount({required String userId}) async {
    try {
      int count = await _mongoFetch.calculateActiveStockCount(
        transactionCollectionName: DbCollections.transactions,
        filter: { ProductFieldName.userId: userId },
      );
      return count;
    } catch (e) {
      throw 'Failed to fetch products count: $e';
    }
  }

  Future<void> updateQuantities({required List<CartModel> cartItems, bool isAddition = false, bool isPurchase = false}) async {
    try {
      await _mongoUpdate.updateQuantities(collectionName: collectionName, cartItems: cartItems, isAddition: isAddition, isPurchase: isPurchase);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantitiesById({required List<CartModel> cartItems, bool isAddition = false, bool isPurchase = false}) async {
    try {
      await _mongoUpdate.updateQuantitiesById(collectionName: collectionName, cartItems: cartItems, isAddition: isAddition, isPurchase: isPurchase);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateVendorAndPurchasePriceById({required List<CartModel> cartItems}) async {
    try {
      await _mongoUpdate.updateVendorAndPurchasePriceById(collectionName: collectionName, cartItems: cartItems);
    } catch (e) {
      rethrow;
    }
  }


  Future<void> deleteProduct({required String id}) async {
    try {
      await _mongoDelete.deleteDocumentById(id: id, collectionName: collectionName);
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  // Get the total count of purchases in the collection
  Future<int> fetchProductGetNextId() async {
    try {
      int nextID = await _mongoFetch.fetchNextId(collectionName: collectionName, fieldName: ProductFieldName.productId);
      return nextID;
    } catch (e) {
      throw 'Failed to fetch vendor id: $e';
    }
  }

  // Add product
  Future<void> pushProduct({required ProductModel product}) async {
    try {
      Map<String, dynamic> productMap = product.toMap(); // Convert a single product to a map
      await _mongoInsert.insertDocument(collectionName, productMap);
    } catch (e) {
      throw 'Failed to add Product: $e';
    }
  }

  // Update a product
  Future<void> updateProduct({required String id, required ProductModel product}) async {
    try {
      Map<String, dynamic> productMap = product.toMap();
          await _mongoUpdate.updateDocumentById(id: id, collectionName: collectionName, updatedData: productMap);
    } catch (e) {
      rethrow;
    }
  }

  // Update multiple products
  Future<void> updateMultipleProducts({required List<ProductModel> products}) async {
    try {
      List<Map<String, dynamic>> productMaps = products.map((product) => product.toMap(isUpdate: true)).toList();
      await _mongoUpdate.updateManyDocuments(
          collectionName: collectionName,
          updates: productMaps
      );
    } catch (e) {
      throw 'Failed to update products: $e';
    }
  }

  Future<int> fetchProductTotalById({required String id}) async {
    try {
      final int total = await _mongoFetch.calculateProductStockTotal(
          collectionName: DbCollections.transactions,
          id: id
      );
      return total;
    } catch (e) {
      rethrow;
    }
  }



}
