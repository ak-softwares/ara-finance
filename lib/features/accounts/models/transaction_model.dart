import 'package:mongo_dart/mongo_dart.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';

class TransactionModel {
  String? id;
  String? userId;
  int? transactionId;
  DateTime? date;
  double? amount;
  String? fromEntityId;
  String? fromEntityName;
  EntityType? fromEntityType;
  String? toEntityId;
  String? toEntityName;
  EntityType? toEntityType;
  TransactionType? transactionType;
  int? _purchaseId;
  List<int>? _salesIds;

  TransactionModel({
    this.id,
    this.userId,
    this.transactionId,
    this.date,
    this.amount,
    this.fromEntityId,
    this.fromEntityName,
    this.fromEntityType,
    this.toEntityId,
    this.toEntityName,
    this.toEntityType,
    this.transactionType,
    int? purchaseId,
    List<int>? salesIds,
  }) {
    if (transactionType == TransactionType.purchase && purchaseId == null) {
      throw ArgumentError('Purchase ID is required for purchase transactions.');
    }
    if (transactionType == TransactionType.sale && (salesIds == null || salesIds.isEmpty)) {
      throw ArgumentError('Sales IDs are required for sale transactions.');
    }
    _purchaseId = purchaseId;
    _salesIds = salesIds;
  }

  int? get purchaseId => _purchaseId;
  set purchaseId(int? value) {
    if (transactionType == TransactionType.purchase && value == null) {
      throw ArgumentError('Purchase ID is required for purchase transactions.');
    }
    _purchaseId = value;
  }

  List<int>? get salesIds => _salesIds;
  set salesIds(List<int>? value) {
    if (transactionType == TransactionType.sale && (value == null || value.isEmpty)) {
      throw ArgumentError('Sales IDs are required for sale transactions.');
    }
    _salesIds = value;
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json[TransactionFieldName.id] is ObjectId
          ? (json[TransactionFieldName.id] as ObjectId).toHexString()
          : json[TransactionFieldName.id]?.toString(),
      userId: json[TransactionFieldName.userId],
      transactionId: json[TransactionFieldName.transactionId] as int?,
      date: json[TransactionFieldName.date],
      amount: (json[TransactionFieldName.amount] as num?)?.toDouble(),
      fromEntityId: json[TransactionFieldName.fromEntityId] as String?,
      fromEntityName: json[TransactionFieldName.fromEntityName],
      fromEntityType: json[TransactionFieldName.fromEntityType] != null
          ? EntityType.values.byName(json[TransactionFieldName.fromEntityType])
          : null,
      toEntityId: json[TransactionFieldName.toEntityId] as String?,
      toEntityName: json[TransactionFieldName.toEntityName],
      toEntityType: json[TransactionFieldName.toEntityType] != null
          ? EntityType.values.byName(json[TransactionFieldName.toEntityType])
          : null,
      transactionType: json[TransactionFieldName.transactionType] != null
          ? TransactionType.values.byName(json[TransactionFieldName.transactionType])
          : null,
      purchaseId: json[TransactionFieldName.purchaseId] as int?,
      salesIds: (json[TransactionFieldName.salesIds] as List<dynamic>?)
          ?.map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) TransactionFieldName.userId: userId,
      if (transactionId != null) TransactionFieldName.transactionId: transactionId,
      if (amount != null) TransactionFieldName.amount: amount,
      if (date != null) TransactionFieldName.date: date,
      if (transactionType != null) TransactionFieldName.transactionType: transactionType!.name,
      if (id != null) TransactionFieldName.id: id,
      if (fromEntityType != null) ...{
        TransactionFieldName.fromEntityId: fromEntityId,
        TransactionFieldName.fromEntityName: fromEntityName,
        TransactionFieldName.fromEntityType: fromEntityType!.name,
      },
      if (toEntityType != null) ...{
        TransactionFieldName.toEntityId: toEntityId,
        TransactionFieldName.toEntityName: toEntityName,
        TransactionFieldName.toEntityType: toEntityType!.name,
      },
      if (transactionType == TransactionType.purchase && purchaseId != null)
        TransactionFieldName.purchaseId: purchaseId,
      if (transactionType == TransactionType.sale && salesIds != null)
        TransactionFieldName.salesIds: salesIds,
    };
  }

  Map<String, dynamic> toMap() => toJson();
  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel.fromJson(map);
}
