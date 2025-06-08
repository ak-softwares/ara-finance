import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/constants/db_constants.dart';

class ExpenseModel {
  final String? id;
  final String? userId;
  final String? title;
  final int? expenseId;
  final double? openingBalance;
  final DateTime? dateCreated;

  ExpenseModel({
    this.id,
    this.userId,
    this.title,
    this.expenseId,
    this.openingBalance,
    this.dateCreated,
  });


  // Factory constructor to create model from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json[ExpenseFieldName.id] is ObjectId
          ? (json[ExpenseFieldName.id] as ObjectId).toHexString()
          : json[ExpenseFieldName.id]?.toString(),
      userId: json[ExpenseFieldName.userId] as String?,
      title: json[ExpenseFieldName.title] as String?,
      expenseId: json[ExpenseFieldName.expenseId] as int?,
      openingBalance: json[ExpenseFieldName.openingBalance] != null ? double.tryParse(json[ExpenseFieldName.openingBalance].toString()) : null,
      dateCreated: json[ExpenseFieldName.dateCreated],
    );
  }

  // Convert model to JSON for database insertion
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data[ExpenseFieldName.id] = id;
    if (userId != null) data[ExpenseFieldName.userId] = userId;
    if (title != null) data[ExpenseFieldName.title] = title;
    if (expenseId != null) data[ExpenseFieldName.expenseId] = expenseId;
    if (openingBalance != null) data[ExpenseFieldName.openingBalance] = openingBalance;
    if (dateCreated != null) data[ExpenseFieldName.dateCreated] = dateCreated;

    return data;
  }


  /// Convert TransactionModel to a Map (alias for toJson)
  Map<String, dynamic> toMap() => toJson();

}

class ExpenseSummary {
  final String name;
  final int total;
  final double percent;

  ExpenseSummary({
    required this.name,
    required this.total,
    required this.percent,
  });
}
