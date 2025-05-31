import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/constants/db_constants.dart';

class AccountModel {
  String? id;
  String? userId;
  int? accountId;
  double? openingBalance;
  double? balance;
  DateTime? dateCreated;
  String? accountName;

  AccountModel({
    this.id,
    this.userId,
    this.accountId,
    this.openingBalance,
    this.balance,
    this.dateCreated,
    this.accountName,
  });

  double get closingBalance => (openingBalance ?? 0) + (balance ?? 0);

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json[AccountFieldName.id] is ObjectId
          ? (json[AccountFieldName.id] as ObjectId).toHexString() // Convert ObjectId to string
          : json[AccountFieldName.id]?.toString(), // Fallback to string if not ObjectId
      userId: json[AccountFieldName.userId],
      accountId: json[AccountFieldName.accountId],
      openingBalance: json[AccountFieldName.openingBalance] ?? 0,
      balance: json[AccountFieldName.balance] ?? 0,
      dateCreated: json[AccountFieldName.dateCreated] != null
          ? DateTime.parse(json[AccountFieldName.dateCreated])
          : null,
      accountName: json[AccountFieldName.accountName] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) AccountFieldName.id: id,
      if (userId != null) AccountFieldName.userId: userId,
      if (accountId != null) AccountFieldName.accountId: accountId,
      if (openingBalance != null) AccountFieldName.openingBalance: openingBalance,
      if (balance != null) AccountFieldName.balance: balance,
      if (dateCreated != null) AccountFieldName.dateCreated: dateCreated!.toIso8601String(),
      if (accountName != null) AccountFieldName.accountName: accountName,
    };
  }

}

