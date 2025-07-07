import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_base.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';

class MongoFetch extends MongoDatabase {
  // Singleton implementation
  static final MongoFetch _instance = MongoFetch._internal();

  factory MongoFetch() => _instance;

  MongoFetch._internal();

  Future<void> _ensureConnected() async {
    await MongoDatabase.ensureConnected();
  }

  // Search documents with pagination
  Future<List<Map<String, dynamic>>> fetchDocumentsBySearchQuery({
    required String collectionName,
    required String query,
    int page = 1,
    int itemsPerPage = 10,
    Map<String, dynamic>? filter,
  }) async {
    await _ensureConnected();
    try {
      final pipeline = [
        {
          "\$search": {
            "index": "default",
            "text": {
              "query": query,
              "path": {"wildcard": "*"}
            }
          }
        },
        if (filter != null && filter.isNotEmpty)
          {"\$match": filter},
        {"\$skip": (page - 1) * itemsPerPage},
        {"\$limit": itemsPerPage}
      ];

      return await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();
    } catch (e) {
      throw Exception('Failed to search documents: $e');
    }
  }

  // Fetch document by ID
  Future<Map<String, dynamic>> fetchDocumentById(
      {required String collectionName, required String id}) async {
    await _ensureConnected();
    try {
      final objectId = ObjectId.fromHexString(id);
      var document = await db!.collection(collectionName).findOne(
          {'_id': objectId});
      if (document == null) {
        throw Exception('Document not found with ID: $id');
      }
      return document;
    } catch (e) {
      throw Exception('Failed to fetch document by ID: $e');
    }
  }

  // Fetch documents with pagination
  Future<List<Map<String, dynamic>>> fetchDocuments({
    required String collectionName,
    Map<String, dynamic>? filter,
    int page = 1,
    int itemsPerPage = 10
  }) async {
    await _ensureConnected();
    var collection = db!.collection(collectionName);
    int skip = (page - 1) * itemsPerPage;

    try {
      var query = where
        ..sortBy('_id', descending: true)
        ..skip(skip)
        ..limit(itemsPerPage);

      if (filter != null) {
        filter.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      var documents = await collection.find(query).toList();
      return documents;
    } catch (e) {
      throw Exception('Error fetching documents: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDocumentsDate({
    required String collectionName,
    Map<String, dynamic>? filter,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _ensureConnected();
    var collection = db!.collection(collectionName);

    try {
      var query = where..sortBy('_id', descending: true);

      if (filter != null) {
        filter.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      query = query.gte(TransactionFieldName.date, startDate);
      query = query.lte(TransactionFieldName.date, endDate);

      var documents = await collection.find(query).toList();
      return documents;
    } catch (e) {
      throw Exception('Error fetching documents: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts({
    required String collectionName,
    Map<String, dynamic>? filter,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    await _ensureConnected();
    try {
      final effectiveFilter = filter ?? {};

      final pipeline = [
        if (effectiveFilter.isNotEmpty)
          {"\$match": effectiveFilter,},
        {"\$addFields": {
          "totalStock": "\$${ProductFieldName.stockQuantity}",
          "stockPriority": {
            "\$switch": {
              "branches": [
                {
                  "case": {"\$lt": ["\$${ProductFieldName.stockQuantity}", 0]},
                  "then": 2
                },
                {
                  "case": {"\$gt": ["\$${ProductFieldName.stockQuantity}", 0]},
                  "then": 1
                },
              ],
              "default": 0
            }
          },
          "absStock": {"\$abs": "\$${ProductFieldName.stockQuantity}"}
        }},
        {"\$sort": {
          "stockPriority": -1,
          "absStock": -1,
          ProductFieldName.id: -1
        }
        },
        {"\$skip": (page - 1) * itemsPerPage},
        {"\$limit": itemsPerPage},
        {
          "\$project": {
            "stockPriority": 0,
            "absStock": 0
          }
        }
      ];

      return await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsWithStockByDate({
    required String productCollectionName,
    required String transactionCollectionName,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? filter,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    await _ensureConnected();
    int skip = (page - 1) * itemsPerPage;

    try {
      // Step 1: Prepare product query with filter and sorting
      var query = where
        ..sortBy(ProductFieldName.dateModified, descending: true)
        ..skip(skip)
        ..limit(itemsPerPage);

      if (filter != null) {
        filter.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      // Step 2: Fetch products
      final products = await db!
          .collection(productCollectionName)
          .find(query)
          .toList();

      // Step 3: Calculate stock for each product within date range
      List<Map<String, dynamic>> result = [];

      for (var product in products) {
        String productId = product['_id'].toHexString();

        final pipeline = [
          {
            r'$match': {
              'products.id': productId,
              'transaction_type': {r'$in': ['purchase', 'sale']},
              'date': {
                r'$gte': startDate.toIso8601String(),
                r'$lte': endDate.toIso8601String(),
              }
            }
          },
          {
            r'$unwind': r'$products'
          },
          {
            r'$match': {
              'products.id': productId
            }
          },
          {
            r'$project': {
              'quantity': r'$products.quantity',
              'transaction_type': 1
            }
          },
          {
            r'$project': {
              'adjustedQuantity': {
                r'$cond': [
                  {r'$eq': [r'$transaction_type', 'purchase']},
                  r'$quantity',
                  {r'$multiply': [r'$quantity', -1]}
                ]
              }
            }
          },
          {
            r'$group': {
              '_id': null,
              'totalStock': {r'$sum': r'$adjustedQuantity'}
            }
          }
        ];

        final stockResult = await db!
            .collection(transactionCollectionName)
            .aggregateToStream(pipeline)
            .toList();

        final totalStock = (stockResult.isNotEmpty && stockResult[0]['totalStock'] != null)
            ? (stockResult[0]['totalStock'] as num).toInt()
            : 0;

        result.add({
          ...product,
          ProductFieldName.stockQuantity: totalStock,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<double> fetchTotalStockValue(
      {required String collectionName, Map<String, dynamic> filter = const {
      },}) async {
    await _ensureConnected();
    try {
      final matchFilter = {
        ProductFieldName.stockQuantity: {"\$ne": 0},
        ProductFieldName.purchasePrice: {"\$ne": 0},
        ...filter, // Merge extra filters like userId, category etc.
      };

      final pipeline = [
        {
          "\$match": matchFilter,
        },
        {
          "\$addFields": {
            "stockValue": {
              "\$multiply": [
                "\$${ProductFieldName.stockQuantity}",
                "\$${ProductFieldName.purchasePrice}"
              ]
            }
          }
        },
        {
          "\$group": {
            "_id": null,
            "totalStockValue": {"\$sum": "\$stockValue"}
          }
        }
      ];

      final result = await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['totalStockValue'] != null) {
        return (result[0]['totalStockValue'] as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      throw Exception('Failed to calculate stock value: $e');
    }
  }

  Future<double> fetchTotalAccountBalance(
      {required String collectionName, Map<String, dynamic>? filter}) async {
    await _ensureConnected();
    try {
      final matchStage = {
        "\$match": {
          AccountFieldName.balance: {"\$ne": null},
          if (filter != null) ...filter, // Merge filter if provided
        }
      };

      final pipeline = [
        matchStage,
        {
          "\$group": {
            "_id": null,
            "totalBalance": {"\$sum": "\$balance"},
          }
        }
      ];

      final result = await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['totalBalance'] != null) {
        return (result[0]['totalBalance'] as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      throw Exception('Failed to calculate total balance: $e');
    }
  }

  Future<double> calculateAccountPayable({
    required String collectionName,
    Map<String, dynamic>? filter,
  }) async {
    await _ensureConnected();
    try {
      final pipeline = [
        {
          r'$match': filter ?? {},
        },
        {
          r'$group': {
            '_id': null,
            'totalBalance': {
              r'$sum': '\$${UserFieldConstants.balance}',
            }
          }
        }
      ];

      final result = await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['totalBalance'] != null) {
        return (result[0]['totalBalance'] as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      throw Exception('Failed to calculate total account balance: $e');
    }
  }

  Future<double> calculateVoucherBalance({
    required String voucherId,
    required String collectionName,
  }) async {
    await _ensureConnected();
    try {
      final pipeline = [
        {
          r'$match': {
            r'$or': [
              {'form_account_voucher._id': voucherId},
              {'to_account_voucher._id': voucherId},
            ]
          }
        },
        {
          r'$project': {
            'amount': 1,
            'isForm': {
              r'$eq': ['\$form_account_voucher._id', voucherId]
            },
            'isTo': {
              r'$eq': ['\$to_account_voucher._id', voucherId]
            }
          }
        },
        {
          r'$project': {
            'netAmount': {
              r'$cond': [
                {'\$eq': ['\$isForm', true]}, // If voucher is form
                {'\$multiply': ['\$amount', -1]},
                {'\$cond': [
                  {'\$eq': ['\$isTo', true]}, // Else if voucher is to
                  '\$amount', // Add amount
                  0 // Else 0 (shouldn't happen)
                ]}
              ]
            }
          }
        },
        {
          r'$group': {
            '_id': null,
            'totalBalance': {r'$sum': '\$netAmount'}
          }
        }
      ];

      final result = await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['totalBalance'] != null) {
        return (result[0]['totalBalance'] as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      throw Exception('Failed to calculate voucher balance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCogsDetailsByProductIds({
    required String collectionName,
    required List<int> productIds,
  }) async {
    await _ensureConnected();
    try {
      final pipeline = [
        {
          "\$match": {
            ProductFieldName.productId: {"\$in": productIds}
          }
        },
        {
          "\$project": {
            ProductFieldName.productId: 1,
            ProductFieldName.purchasePrice: 1,
            "_id": 0
          }
        }
      ];

      final result = await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();

      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch product COGS details: $e');
    }
  }

  Future<double> fetchInTransitStockValue({
    required String collectionName,
    required OrderType orderType,
    required OrderStatus orderStatus,
  }) async {
    await _ensureConnected();
    try {
      final pipeline = [
        {
          "\$match": {
            OrderFieldName.status: orderStatus.name,
            OrderFieldName.orderType: orderType.name,
          }
        },
        {
          "\$unwind": "\$${OrderFieldName.lineItems}"
        },
        {
          "\$match": {
            "${OrderFieldName.lineItems}.${ProductFieldName.purchasePrice}": {
              "\$gt": 0
            },
            "${OrderFieldName.lineItems}.quantity": {"\$gt": 0}
          }
        },
        {
          "\$addFields": {
            "stockValue": {
              "\$multiply": [
                "\$${OrderFieldName.lineItems}.quantity",
                "\$${OrderFieldName.lineItems}.${ProductFieldName
                    .purchasePrice}"
              ]
            }
          }
        },
        {
          "\$group": {
            "_id": null,
            "totalInTransitStockValue": {"\$sum": "\$stockValue"}
          }
        }
      ];

      final result = await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['totalInTransitStockValue'] != null) {
        return (result[0]['totalInTransitStockValue'] as num).toDouble();
      } else {
        return 0.0;
      }
    } catch (e) {
      throw Exception('Failed to fetch in-transit stock value: $e');
    }
  }


  Future<List<Map<String, dynamic>>> fetchTransactionByEntity({
    required String collectionName,
    required String voucherId,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    await _ensureConnected();
    try {
      final skip = (page - 1) * itemsPerPage;
      final query = where.eq(
          '${TransactionFieldName.fromAccountVoucher}._id', voucherId)
          .or(
          where.eq('${TransactionFieldName.toAccountVoucher}._id', voucherId))
          .sortBy('_id', descending: false)
          .skip(skip)
          .limit(itemsPerPage);

      final result = await db!.collection(collectionName).find(query).toList();
      return result;
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactionByProductId({
    required String collectionName,
    required int productId,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    await _ensureConnected();
    try {
      final skip = (page - 1) * itemsPerPage;

      final query = where
          .eq('products.product_id', productId)
          .sortBy('_id', descending: true)
          .skip(skip)
          .limit(itemsPerPage);

      final result = await db!.collection(collectionName).find(query).toList();
      return result;
    } catch (e) {
      throw Exception('Failed to fetch transactions by productId: $e');
    }
  }


  Future<Map<String, dynamic>?> fetchTransactionBySale({
    required String collectionName,
    required int orderNumber,
  }) async {
    await _ensureConnected();
    try {
      final query = where
          .eq(
          TransactionFieldName.transactionType, AccountVoucherType.sale.name);
      // .eq(TransactionFieldName.salesIds, orderNumber); // Match sale id in array

      final result = await db!
          .collection(collectionName)
          .findOne(query); // use findOne to get a single map

      return result;
    } catch (e) {
      throw Exception('Failed to fetch transaction: $e');
    }
  }


  Future<int> fetchNextId(
      {required String collectionName, required String fieldName, Map<
          String,
          dynamic>? filter,}) async {
    await _ensureConnected();
    var collection = db!.collection(collectionName);
    try {
      var query = where.sortBy(fieldName, descending: true).limit(1);

      if (filter != null) {
        filter.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      var lastDocument = await collection.find(query).toList();

      if (lastDocument.isEmpty) {
        return 1;
      } else {
        return lastDocument[0][fieldName] + 1;
      }
    } catch (e) {
      throw Exception('Error fetching the next ID: $e');
    }
  }

  Future<Set<int>> fetchDocumentIds({
    required String collectionName,
    required String userId,
  }) async {
    await _ensureConnected();
    try {
      final collection = db!.collection(collectionName);
      final allIds = <int>{};
      int page = 1;
      const pageSize = 1000;

      while (true) {
        final batch = await collection
            .find(
          where
              .eq(ProductFieldName.userId,
              userId) // Using variables for field name and value
              .fields([ProductFieldName.productId])
              .skip((page - 1) * pageSize)
              .limit(pageSize),
        )
            .toList();

        if (batch.isEmpty) break;

        allIds.addAll(batch.map((p) => p[ProductFieldName.productId] as int));
        page++;
      }

      return allIds;
    } catch (e) {
      throw Exception('Failed to fetch collection IDs: $e');
    }
  }

  Future<int> fetchCollectionCount(
      {required String collectionName, Map<String, dynamic>? filter}) async {
    await _ensureConnected();
    try {
      final effectiveFilter = filter ?? {};
      return await db!.collection(collectionName).count(effectiveFilter) ?? 0;
    } catch (e) {
      throw Exception('Failed to get collection count: $e');
    }
  }

  Future<Map<String, dynamic>?> findOne({
    required String collectionName, required Map<String, dynamic> filter}) async {
    await _ensureConnected();
    try {
      return await db!.collection(collectionName).findOne(filter);
    } catch (e) {
      throw Exception('Failed to find document: $e');
    }
  }

  Future<List<Map<String, dynamic>>> findMany({
    required String collectionName,
    required Map<String, dynamic> filter,
  }) async {
    await _ensureConnected();
    try {
      return await db!.collection(collectionName).find(filter).toList();
    } catch (e) {
      throw Exception('Failed to find documents: $e');
    }
  }

  Future<int> calculateProductStockTotal( {required String id, required String collectionName}) async {
    await _ensureConnected();
    try {
      final pipeline = [
        {
          r'$match': {
            'products.id': id,
            'transaction_type': {r'$in': ['purchase', 'sale']}
          }
        },
        {
          r'$unwind': r'$products'
        },
        {
          r'$match': {
            'products.id': id
          }
        },
        {
          r'$project': {
            'quantity': r'$products.quantity',
            'transaction_type': 1
          }
        },
        {
          r'$project': {
            'adjustedQuantity': {
              r'$cond': [
                {r'$eq': [r'$transaction_type', 'purchase']},
                r'$quantity',
                {r'$multiply': [r'$quantity', -1]}
              ]
            }
          }
        },
        {
          r'$group': {
            '_id': null,
            'totalStock': {r'$sum': r'$adjustedQuantity'}
          }
        }
      ];

      final result = await db!
          .collection(collectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['totalStock'] != null) {
        return (result[0]['totalStock'] as num).toInt();
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to calculate product stock: $e');
    }
  }



  // Products
  Future<Map<String, dynamic>?> fetchProductByIdWithStock({
    required String productCollectionName,
    required String transactionCollectionName,
    required String id,
  }) async {
    await _ensureConnected();

    try {
      // Step 1: Fetch product by ID
      final product = await db!
          .collection(productCollectionName)
          .findOne(where.id(ObjectId.parse(id)));

      if (product == null) return null;

      // Step 2: Build stock calculation pipeline
      final pipeline = [
        {
          r'$match': {
            'products.id': id,
            r'$or': [
              {'transaction_type': 'purchase'},
              {
                'transaction_type': 'sale',
                'status': {r'$ne': 'returned'}
              }
            ]
          }
        },
        {
          r'$unwind': r'$products'
        },
        {
          r'$match': {
            'products.id': id
          }
        },
        {
          r'$project': {
            'quantity': r'$products.quantity',
            'transaction_type': 1
          }
        },
        {
          r'$project': {
            'adjustedQuantity': {
              r'$cond': [
                {r'$eq': [r'$transaction_type', 'purchase']},
                r'$quantity',
                {r'$multiply': [r'$quantity', -1]}
              ]
            }
          }
        },
        {
          r'$group': {
            '_id': null,
            'totalStock': {r'$sum': r'$adjustedQuantity'}
          }
        }
      ];

      // Step 3: Execute aggregation
      final stockResult = await db!
          .collection(transactionCollectionName)
          .aggregateToStream(pipeline)
          .toList();

      final totalStock = (stockResult.isNotEmpty && stockResult[0]['totalStock'] != null)
          ? (stockResult[0]['totalStock'] as num).toInt()
          : 0;

      // Step 4: Return product with stock info
      return {
        ...product,
        ProductFieldName.stockQuantity: totalStock,
      };
    } catch (e) {
      throw Exception('Failed to fetch product by ID with stock: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsWithStock({
    required String productCollectionName,
    required String transactionCollectionName,
    Map<String, dynamic>? filter,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    await _ensureConnected();
    int skip = (page - 1) * itemsPerPage;

    try {
      // Step 1: Prepare query with filter and sorting
      var query = where;
      filter?.forEach((key, value) {
        query = query.eq(key, value);
      });


      query = query
        ..sortBy(ProductFieldName.dateModified, descending: true)
        ..sortBy('_id', descending: true) // add stable sort
        ..skip(skip)
        ..limit(itemsPerPage);

      // Step 2: Fetch products
      final List<Map<String, dynamic>> products = await db!
          .collection(productCollectionName)
          .find(query)
          .toList();

      // Step 3: For each product, calculate total stock from transactions
      List<Map<String, dynamic>> result = [];
      for (var product in products) {
        String productId = product['_id'].toHexString(); // or product['_id'] depending on your schema

        final pipeline = [
          {
            r'$match': {
              'products.id': productId,
              r'$or': [
                {'transaction_type': 'purchase'},
                {
                  'transaction_type': 'sale',
                  'status': {r'$ne': 'returned'}
                }
              ]
            }
          },
          {
            r'$unwind': r'$products'
          },
          {
            r'$match': {
              'products.id': productId
            }
          },
          {
            r'$project': {
              'quantity': r'$products.quantity',
              'transaction_type': 1
            }
          },
          {
            r'$project': {
              'adjustedQuantity': {
                r'$cond': [
                  {r'$eq': [r'$transaction_type', 'purchase']},
                  r'$quantity',
                  {r'$multiply': [r'$quantity', -1]}
                ]
              }
            }
          },
          {
            r'$group': {
              '_id': null,
              'totalStock': {r'$sum': r'$adjustedQuantity'}
            }
          }
        ];

        final stockResult = await db!
            .collection(transactionCollectionName)
            .aggregateToStream(pipeline)
            .toList();

        final totalStock = (stockResult.isNotEmpty && stockResult[0]['totalStock'] != null)
            ? (stockResult[0]['totalStock'] as num).toInt()
            : 0;

        // Add stock info to product
        result.add({
          ...product,
          ProductFieldName.stockQuantity: totalStock,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchProductsWithStock({
    required String productCollectionName,
    required String transactionCollectionName,
    required String searchQuery,
    int page = 1,
    int itemsPerPage = 10,
    Map<String, dynamic>? filter,
  }) async {
    await _ensureConnected();
    int skip = (page - 1) * itemsPerPage;

    try {
      final searchPipeline = [
        {
          r'$search': {
            'index': 'default',
            'text': {
              'query': searchQuery,
              'path': {'wildcard': '*'},
            }
          }
        },
        if (filter != null && filter.isNotEmpty) {r'$match': filter},
        {r'$skip': skip},
        {r'$limit': itemsPerPage}
      ];

      // Step 1: Search and filter products
      final products = await db!
          .collection(productCollectionName)
          .aggregateToStream(searchPipeline)
          .toList();

      // Step 2: Append stock info
      List<Map<String, dynamic>> result = [];
      for (var product in products) {
        String productId = product['_id'].toHexString();

        final stockPipeline = [
          {
            r'$match': {
              'products.id': productId,
              r'$or': [
                {'transaction_type': 'purchase'},
                {
                  'transaction_type': 'sale',
                  'status': {r'$ne': 'returned'}
                }
              ]
            }
          },
          {r'$unwind': r'$products'},
          {
            r'$match': {
              'products.id': productId
            }
          },
          {
            r'$project': {
              'quantity': r'$products.quantity',
              'transaction_type': 1
            }
          },
          {
            r'$project': {
              'adjustedQuantity': {
                r'$cond': [
                  {r'$eq': [r'$transaction_type', 'purchase']},
                  r'$quantity',
                  {r'$multiply': [r'$quantity', -1]}
                ]
              }
            }
          },
          {
            r'$group': {
              '_id': null,
              'totalStock': {r'$sum': r'$adjustedQuantity'}
            }
          }
        ];

        final stockResult = await db!
            .collection(transactionCollectionName)
            .aggregateToStream(stockPipeline)
            .toList();

        final totalStock = (stockResult.isNotEmpty && stockResult[0]['totalStock'] != null)
            ? (stockResult[0]['totalStock'] as num).toInt()
            : 0;

        result.add({
          ...product,
          ProductFieldName.stockQuantity: totalStock,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Error searching products with stock: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByProductIdsWithStock({
    required String productCollectionName,
    required String transactionCollectionName,
    required String fieldName,
    required List<int> documentIds,
  }) async {
    await _ensureConnected();

    try {
      // Step 1: Fetch products by IDs
      final products = await db!
          .collection(productCollectionName)
          .find(where.oneFrom(fieldName, documentIds))
          .toList();

      List<Map<String, dynamic>> result = [];

      for (final product in products) {
        final id = product['_id'].toHexString();

        // Step 2: Build pipeline for each product
        final pipeline = [
          {
            r'$match': {
              'products.id': id,
              r'$or': [
                {'transaction_type': 'purchase'},
                {
                  'transaction_type': 'sale',
                  'status': {r'$ne': 'returned'}
                }
              ]
            }
          },
          {
            r'$unwind': r'$products'
          },
          {
            r'$match': {
              'products.id': id
            }
          },
          {
            r'$project': {
              'quantity': r'$products.quantity',
              'transaction_type': 1
            }
          },
          {
            r'$project': {
              'adjustedQuantity': {
                r'$cond': [
                  {r'$eq': [r'$transaction_type', 'purchase']},
                  r'$quantity',
                  {r'$multiply': [r'$quantity', -1]}
                ]
              }
            }
          },
          {
            r'$group': {
              '_id': null,
              'totalStock': {r'$sum': r'$adjustedQuantity'}
            }
          }
        ];

        // Step 3: Aggregate stock
        final stockResult = await db!
            .collection(transactionCollectionName)
            .aggregateToStream(pipeline)
            .toList();

        final totalStock = (stockResult.isNotEmpty && stockResult[0]['totalStock'] != null)
            ? (stockResult[0]['totalStock'] as num).toInt()
            : 0;

        // Step 4: Add stock info to product
        result.add({
          ...product,
          ProductFieldName.stockQuantity: totalStock,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Failed to fetch products with stock: $e');
    }
  }


  Future<int> calculateActiveStockCount({required String transactionCollectionName, Map<String, dynamic>? filter}) async {
    await _ensureConnected();

    try {
      final Map<String, dynamic> matchStage = {
        'transaction_type': {r'$in': ['purchase', 'sale']}
      };

      if (filter != null) {
        matchStage.addAll(filter);
      }

      final pipeline = [
        {
          r'$match': matchStage
        },
        {
          r'$unwind': r'$products'
        },
        {
          r'$project': {
            'transaction_type': 1,
            'product_id': r'$products.id',
            'quantity': r'$products.quantity'
          }
        },
        {
          r'$project': {
            'product_id': 1,
            'adjustedQuantity': {
              r'$cond': [
                {r'$eq': [r'$transaction_type', 'purchase']},
                r'$quantity',
                {r'$multiply': [r'$quantity', -1]}
              ]
            }
          }
        },
        {
          r'$group': {
            '_id': r'$product_id',
            'totalStock': {r'$sum': r'$adjustedQuantity'}
          }
        },
        {
          r'$match': {
            'totalStock': {r'$gt': 0}
          }
        },
        {
          r'$count': 'activeStockCount'
        }
      ];

      final result = await db!
          .collection(transactionCollectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['activeStockCount'] != null) {
        return (result[0]['activeStockCount'] as num).toInt();
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to calculate active stock count: $e');
    }
  }

  Future<double> calculateTotalStockValue({required String transactionCollectionName, Map<String, dynamic>? filter,}) async {
    await _ensureConnected();

    try {
      final Map<String, dynamic> matchStage = {
        r'$or': [
          {'transaction_type': 'purchase'},
          {
            'transaction_type': 'sale',
            'status': {r'$ne': 'returned'} // Exclude returned transactions
          }
        ]
      };

      if (filter != null) {
        matchStage.addAll(filter);
      }

      final pipeline = [
        {
          r'$match': matchStage
        },
        {
          r'$unwind': r'$products'
        },
        {
          r'$project': {
            'transaction_type': 1,
            'quantity': r'$products.quantity',
            'purchase_price': r'$products.purchase_price',
          }
        },
        {
          r'$project': {
            'adjustedQuantity': {
              r'$cond': [
                {r'$eq': [r'$transaction_type', 'purchase']},
                r'$quantity',
                {r'$multiply': [r'$quantity', -1]}
              ]
            },
            'purchase_price': 1
          }
        },
        {
          r'$project': {
            'costValue': {
              r'$multiply': [r'$adjustedQuantity', r'$purchase_price']
            }
          }
        },
        {
          r'$group': {
            '_id': null,
            'totalCostValue': {r'$sum': r'$costValue'}
          }
        }
      ];

      final result = await db!
          .collection(transactionCollectionName)
          .aggregateToStream(pipeline)
          .toList();

      if (result.isNotEmpty && result[0]['totalCostValue'] != null) {
        return (result[0]['totalCostValue'] as num).toDouble();
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to calculate total stock value: $e');
    }
  }

  // Account Voucher functions
  Future<Map<String, dynamic>?> fetchVoucherById({
    required String accountCollectionName,
    required String transactionCollectionName,
    required String voucherId,
  }) async {
    await _ensureConnected();

    try {
      // Step 1: Find the voucher by ID
      final voucher = await db!
          .collection(accountCollectionName)
          .findOne(where.id(ObjectId.parse(voucherId)));

      if (voucher == null) return null;

      // Step 2: Prepare aggregation pipeline for balance calculation
      final pipeline = [
        {
          r'$match': {
            r'$or': [
              {'form_account_voucher._id': voucherId},
              {'to_account_voucher._id': voucherId},
            ]
          }
        },
        {
          r'$project': {
            'amount': 1,
            'isForm': {
              r'$eq': [r'$form_account_voucher._id', voucherId]
            },
            'isTo': {
              r'$eq': [r'$to_account_voucher._id', voucherId]
            }
          }
        },
        {
          r'$project': {
            'netAmount': {
              r'$cond': [
                {r'$eq': [r'$isForm', true]},
                {r'$multiply': [r'$amount', -1]},
                {
                  r'$cond': [
                    {r'$eq': [r'$isTo', true]},
                    r'$amount',
                    0
                  ]
                }
              ]
            }
          }
        },
        {
          r'$group': {
            '_id': null,
            'totalBalance': {r'$sum': r'$netAmount'}
          }
        }
      ];

      final balanceResult = await db!
          .collection(transactionCollectionName)
          .aggregateToStream(pipeline)
          .toList();

      final balance = (balanceResult.isNotEmpty && balanceResult[0]['totalBalance'] != null)
          ? (balanceResult[0]['totalBalance'] as num).toDouble()
          : 0.0;

      // Step 3: Return voucher with balance
      return {
        ...voucher,
        'current_balance': balance,
      };
    } catch (e) {
      throw Exception('Failed to fetch voucher by ID: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAccountsWithBalance({
    required String accountCollectionName,
    required String transactionCollectionName,
    Map<String, dynamic>? filter,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    await _ensureConnected();
    int skip = (page - 1) * itemsPerPage;

    try {
      // Step 1: Prepare query with filter and pagination
      var query = where..skip(skip)..limit(itemsPerPage);
      if (filter != null) {
        filter.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      // Step 2: Fetch accounts
      final accounts = await db!
          .collection(accountCollectionName)
          .find(query)
          .toList();

      // Step 3: For each account, calculate balance
      List<Map<String, dynamic>> result = [];

      for (var account in accounts) {
        String accountId = account['_id'].toHexString();

        final pipeline = [
          {
            r'$match': {
              r'$or': [
                {'form_account_voucher._id': accountId},
                {'to_account_voucher._id': accountId},
              ]
            }
          },
          {
            r'$project': {
              'amount': 1,
              'isForm': {
                r'$eq': [r'$form_account_voucher._id', accountId]
              },
              'isTo': {
                r'$eq': [r'$to_account_voucher._id', accountId]
              }
            }
          },
          {
            r'$project': {
              'netAmount': {
                r'$cond': [
                  {r'$eq': [r'$isForm', true]},
                  {r'$multiply': [r'$amount', -1]},
                  {
                    r'$cond': [
                      {r'$eq': [r'$isTo', true]},
                      r'$amount',
                      0
                    ]
                  }
                ]
              }
            }
          },
          {
            r'$group': {
              '_id': null,
              'totalBalance': {r'$sum': r'$netAmount'}
            }
          }
        ];

        final balanceResult = await db!
            .collection(transactionCollectionName)
            .aggregateToStream(pipeline)
            .toList();

        final balance = (balanceResult.isNotEmpty && balanceResult[0]['totalBalance'] != null)
            ? (balanceResult[0]['totalBalance'] as num).toDouble()
            : 0.0;

        // Add balance to account object
        result.add({
          ...account,
          'current_balance': balance,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Failed to fetch accounts with balance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllAccountsWithBalance({
    required String accountCollectionName,
    required String transactionCollectionName,
    Map<String, dynamic>? filter,
  }) async {
    await _ensureConnected();

    try {
      // Step 1: Prepare query with filter (no pagination)
      var query = where;
      if (filter != null) {
        filter.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      // Step 2: Fetch accounts
      final accounts = await db!
          .collection(accountCollectionName)
          .find(query)
          .toList();

      // Step 3: For each account, calculate balance
      List<Map<String, dynamic>> result = [];

      for (var account in accounts) {
        String accountId = account['_id'].toHexString();

        final pipeline = [
          {
            r'$match': {
              r'$or': [
                {'form_account_voucher._id': accountId},
                {'to_account_voucher._id': accountId},
              ]
            }
          },
          {
            r'$project': {
              'amount': 1,
              'isForm': {
                r'$eq': [r'$form_account_voucher._id', accountId]
              },
              'isTo': {
                r'$eq': [r'$to_account_voucher._id', accountId]
              }
            }
          },
          {
            r'$project': {
              'netAmount': {
                r'$cond': [
                  {r'$eq': [r'$isForm', true]},
                  {r'$multiply': [r'$amount', -1]},
                  {
                    r'$cond': [
                      {r'$eq': [r'$isTo', true]},
                      r'$amount',
                      0
                    ]
                  }
                ]
              }
            }
          },
          {
            r'$group': {
              '_id': null,
              'totalBalance': {r'$sum': r'$netAmount'}
            }
          }
        ];

        final balanceResult = await db!
            .collection(transactionCollectionName)
            .aggregateToStream(pipeline)
            .toList();

        final balance = (balanceResult.isNotEmpty && balanceResult[0]['totalBalance'] != null)
            ? (balanceResult[0]['totalBalance'] as num).toDouble()
            : 0.0;

        result.add({
          ...account,
          'current_balance': balance,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Failed to fetch accounts with balance: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchAccountVoucherWithBalance({
    required String voucherCollectionName,
    required String transactionCollectionName,
    required String searchQuery,
    int page = 1,
    int itemsPerPage = 10,
    Map<String, dynamic>? filter,
  }) async {
    await _ensureConnected();
    int skip = (page - 1) * itemsPerPage;

    try {
      final searchPipeline = [
        {
          r'$search': {
            'index': 'default',
            'text': {
              'query': searchQuery,
              'path': {'wildcard': '*'},
            }
          }
        },
        if (filter != null && filter.isNotEmpty) {r'$match': filter},
        {r'$skip': skip},
        {r'$limit': itemsPerPage}
      ];

      // Step 1: Search and filter vouchers
      final vouchers = await db!
          .collection(voucherCollectionName)
          .aggregateToStream(searchPipeline)
          .toList();

      // Step 2: Append total balance info
      List<Map<String, dynamic>> result = [];

      for (var voucher in vouchers) {
        String voucherId = voucher['_id'].toHexString();

        final balancePipeline = [
          {
            r'$match': {
              r'$or': [
                {'form_account_voucher._id': voucherId},
                {'to_account_voucher._id': voucherId},
              ]
            }
          },
          {
            r'$project': {
              'amount': 1,
              'isForm': {
                r'$eq': [r'$form_account_voucher._id', voucherId]
              },
              'isTo': {
                r'$eq': [r'$to_account_voucher._id', voucherId]
              }
            }
          },
          {
            r'$project': {
              'netAmount': {
                r'$cond': [
                  {r'$eq': [r'$isForm', true]},
                  {r'$multiply': [r'$amount', -1]},
                  {
                    r'$cond': [
                      {r'$eq': [r'$isTo', true]},
                      r'$amount',
                      0
                    ]
                  }
                ]
              }
            }
          },
          {
            r'$group': {
              '_id': null,
              'totalBalance': {r'$sum': r'$netAmount'}
            }
          }
        ];

        final balanceResult = await db!
            .collection(transactionCollectionName)
            .aggregateToStream(balancePipeline)
            .toList();

        final totalBalance = (balanceResult.isNotEmpty && balanceResult[0]['totalBalance'] != null)
            ? (balanceResult[0]['totalBalance'] as num).toDouble()
            : 0.0;

        result.add({
          ...voucher,
          'current_balance': totalBalance,
        });
      }

      return result;
    } catch (e) {
      throw Exception('Error searching vouchers with total balance: $e');
    }
  }


}