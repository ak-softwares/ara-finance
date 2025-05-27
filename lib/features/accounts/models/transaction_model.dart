import 'package:mongo_dart/mongo_dart.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';

class TransactionModel {
  String? id;
  String? userId;
  int? transactionId;
  DateTime? date;
  double? amount;
  String? fromEntityId; // ID of the sender
  String? fromEntityName;
  EntityType? fromEntityType; // Type: "Customer", "Vendor", "PaymentMethod"
  String? toEntityId; // ID of the receiver
  String? toEntityName;
  EntityType? toEntityType; // Type: "Customer", "Vendor", "PaymentMethod"
  TransactionType? transactionType; // Enum-based transaction type
  int? _purchaseId; // Private field

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
    int? purchaseId, // Constructor parameter
  }) {
    if (transactionType == TransactionType.purchase && purchaseId == null) {
      throw ArgumentError('Purchase ID is required for purchase transactions.');
    }
    _purchaseId = purchaseId;
  }

  int? get purchaseId => _purchaseId;

  set purchaseId(int? value) {
    if (transactionType == TransactionType.purchase && value == null) {
      throw ArgumentError('Purchase ID is required for purchase transactions.');
    }
    _purchaseId = value;
  }

  /// Factory method to create an instance from JSON
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
      purchaseId: json.containsKey(TransactionFieldName.purchaseId)
          ? json[TransactionFieldName.purchaseId] as int?
          : null, // Only parse purchaseId if it exists
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
    };
  }




  /// Convert TransactionModel to a Map (alias for toJson)
  Map<String, dynamic> toMap() => toJson();

  /// Factory method to create a TransactionModel from a Map (alias for fromJson)
  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel.fromJson(map);
}
