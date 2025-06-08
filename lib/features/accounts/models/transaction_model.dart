import 'package:mongo_dart/mongo_dart.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
import 'account_voucher_model.dart';
import 'cart_item_model.dart';

class TransactionModel {
  String? id;
  String? userId;
  int? transactionId;
  DateTime? date;
  double? amount;
  AccountVoucherModel? formAccountVoucher;
  AccountVoucherModel? toAccountVoucher;
  AccountVoucherType? transactionType;
  List<CartModel>? products;

  TransactionModel({
    this.id,
    this.userId,
    this.transactionId,
    this.date,
    this.amount,
    this.formAccountVoucher,
    this.toAccountVoucher,
    this.transactionType,
    this.products,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json[TransactionFieldName.id] is ObjectId
          ? (json[TransactionFieldName.id] as ObjectId).toHexString()
          : json[TransactionFieldName.id]?.toString(),
      userId: json[TransactionFieldName.userId],
      transactionId: json[TransactionFieldName.transactionId] as int?,
      date: json[TransactionFieldName.date],
      amount: (json[TransactionFieldName.amount] as num?)?.toDouble(),
      formAccountVoucher: json[TransactionFieldName.formAccountVoucher] != null
          ? AccountVoucherModel.fromJson(json[TransactionFieldName.formAccountVoucher] as Map<String, dynamic>)
          : null,
      toAccountVoucher: json[TransactionFieldName.toAccountVoucher] != null
          ? AccountVoucherModel.fromJson(json[TransactionFieldName.toAccountVoucher] as Map<String, dynamic>)
          : null,
      transactionType: json[TransactionFieldName.transactionType] != null
          ? AccountVoucherType.values.byName(json[TransactionFieldName.transactionType])
          : null,
      products: (json[TransactionFieldName.products] as List<dynamic>?)
          ?.map((item) => CartModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) TransactionFieldName.id: id,
      if (userId != null) TransactionFieldName.userId: userId,
      if (transactionId != null) TransactionFieldName.transactionId: transactionId,
      if (amount != null) TransactionFieldName.amount: amount,
      if (date != null) TransactionFieldName.date: date,
      if (transactionType != null) TransactionFieldName.transactionType: transactionType!.name,
      if (formAccountVoucher != null) TransactionFieldName.formAccountVoucher: formAccountVoucher!.toJson(),
      if (toAccountVoucher != null) TransactionFieldName.toAccountVoucher: toAccountVoucher!.toJson(),
      if (products != null) TransactionFieldName.products: products!.map((item) => item.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() => toJson();
  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel.fromJson(map);
}
