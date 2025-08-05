import 'package:mongo_dart/mongo_dart.dart';
import 'mongo_base.dart';

class MongoInsert extends MongoDatabase {
  // Singleton implementation
  static final MongoInsert _instance = MongoInsert._internal();
  factory MongoInsert() => _instance;
  MongoInsert._internal();

  Future<void> _ensureConnected() async {
    await MongoDatabase.ensureConnected();
  }

  // Insert a single document
  Future<String> insertDocument(String collectionName, Map<String, dynamic> data) async {
    await _ensureConnected();
    try {
      final result = await db!.collection(collectionName).insertOne(data);
      if (result.isSuccess) {
        final ObjectId id = data['_id'];
        return id.toHexString(); // or: id.toString()
      } else {
        throw Exception('Insert failed: ${result.errmsg}');
      }
    } catch (e) {
      throw Exception('Failed to insert document: $e');
    }
  }


  // Insert multiple documents
  Future<void> insertDocuments(String collectionName, List<Map<String, dynamic>> dataList) async {
    await _ensureConnected();
    try {
      await db!.collection(collectionName).insertMany(dataList);
    } catch (e) {
      throw Exception('Failed to insert documents: $e');
    }
  }

  Future<String> insertDocumentGetId(String collectionName, Map<String, dynamic> data) async {
    await _ensureConnected();
    try {
      final result = await db!.collection(collectionName).insertOne(data);
      if (result.isSuccess && result.id != null) {
        return (result.id as ObjectId).toHexString();
      } else {
        throw Exception('Insert failed.');
      }
    } catch (e) {
      throw Exception('Failed to insert document: $e');
    }
  }
}