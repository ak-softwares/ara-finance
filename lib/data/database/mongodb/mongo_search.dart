import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_base.dart';

class MongoSearch extends MongoDatabase {
  static final MongoSearch _instance = MongoSearch._internal();
  factory MongoSearch() => _instance;
  MongoSearch._internal();

  Future<void> _ensureConnected() async {
    await MongoDatabase.ensureConnected();
  }

  Future<List<Map<String, dynamic>>> searchDocumentsByFields1({
    required String collectionName,
    required String searchTerm,
    required List<String> searchFields,
    Map<String, dynamic>? filter,
    int page = 1,
    int itemsPerPage = 10,
    int sortOrder = 1,
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

      query = query.eq(searchFields.first, int.tryParse(searchTerm));

      final documents = await collection.find(query).toList();

      return documents;
    } catch (e) {
      throw Exception('Search failed: ${e.toString()}');
    }
  }




}