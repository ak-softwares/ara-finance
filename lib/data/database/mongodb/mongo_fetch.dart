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
  Future<Map<String, dynamic>> fetchDocumentById({required String collectionName, required String id}) async {
    await _ensureConnected();
    try {
      final objectId = ObjectId.fromHexString(id);
      var document = await db!.collection(collectionName).findOne({'_id': objectId});
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

      query = query.gte(OrderFieldName.dateCreated, startDate);
      query = query.lte(OrderFieldName.dateCreated, endDate);

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

  Future<double> fetchTotalStockValue({
    required String collectionName,
    Map<String, dynamic> filter = const {},
  }) async {
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

  Future<double> fetchTotalAccountBalance({
    required String collectionName,
    Map<String, dynamic>? filter, // Add filter parameter
  }) async {
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
            "${OrderFieldName.lineItems}.${ProductFieldName.purchasePrice}": {"\$gt": 0},
            "${OrderFieldName.lineItems}.quantity": {"\$gt": 0}
          }
        },
        {
          "\$addFields": {
            "stockValue": {
              "\$multiply": [
                "\$${OrderFieldName.lineItems}.quantity",
                "\$${OrderFieldName.lineItems}.${ProductFieldName.purchasePrice}"
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

  Future<List<Map<String, dynamic>>> fetchDocumentsByFieldName({
    required String collectionName,
    required String fieldName,
    required List<int> documentIds,
  }) async {
    await _ensureConnected();
    try {
      return await db!
          .collection(collectionName)
          .find(where.oneFrom(fieldName, documentIds))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch documents by IDs: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactionByEntity({
    required String collectionName,
    required EntityType entityType,
    required String entityId,
    int page = 1,
    int itemsPerPage = 10,
  }) async {
    await _ensureConnected();
    try {
      final skip = (page - 1) * itemsPerPage;
      final query = where
          .eq('from_entity_type', entityType.name)
          .eq('from_entity_id', entityId)
          .or(where
          .eq('to_entity_type', entityType.name)
          .eq('to_entity_id', entityId))
          .sortBy('_id', descending: true)
          .skip(skip)
          .limit(itemsPerPage);

      return await db!.collection(collectionName).find(query).toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchTransactionBySale({
    required String collectionName,
    required int orderNumber,
  }) async {
    await _ensureConnected();
    try {
      final query = where
          .eq(TransactionFieldName.transactionType, TransactionType.sale.name)
          .eq(TransactionFieldName.salesIds, orderNumber); // Match sale id in array

      final result = await db!
          .collection(collectionName)
          .findOne(query); // use findOne to get a single map

      return result;
    } catch (e) {
      throw Exception('Failed to fetch transaction: $e');
    }
  }


  Future<int> fetchNextId({
    required String collectionName,
    required String fieldName,
    Map<String, dynamic>? filter,
  }) async {
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
              .eq(ProductFieldName.userId, userId)  // Using variables for field name and value
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

  Future<int> fetchCollectionCount({required String collectionName, Map<String, dynamic>? filter}) async {
    await _ensureConnected();
    try {
      final effectiveFilter = filter ?? {};
      return await db!.collection(collectionName).count(effectiveFilter) ?? 0;
    } catch (e) {
      throw Exception('Failed to get collection count: $e');
    }
  }

  Future<Map<String, dynamic>?> findOne({required String collectionName, required Map<String, dynamic> filter,}) async {
    await _ensureConnected();
    try {
      return await db!.collection(collectionName).findOne(filter);
    } catch (e) {
      throw Exception('Failed to find document: $e');
    }
  }

  Future<List<Map<String, dynamic>>> findMany({
    required String collectionName,
    required Map<String, dynamic> query,
  }) async {
    await _ensureConnected();
    try {
      return await db!.collection(collectionName).find(query).toList();
    } catch (e) {
      throw Exception('Failed to find documents: $e');
    }
  }
}