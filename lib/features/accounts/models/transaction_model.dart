import 'package:mongo_dart/mongo_dart.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
import '../../personalization/models/address_model.dart';
import 'account_voucher_model.dart';
import 'cart_item_model.dart';
import 'coupon_model.dart';
import 'order_model.dart';

class TransactionModel {
  String? id;
  String? userId;
  int? transactionId;
  DateTime? date;
  DateTime? dateShipped;
  DateTime? datePaid;
  DateTime? dateReturned;
  double? discount;
  double? shipping;
  double? amount;
  AccountVoucherModel? fromAccountVoucher;
  AccountVoucherModel? toAccountVoucher;
  AccountVoucherType? transactionType;
  List<CartModel>? products;
  List<int>? orderIds;
  OrderStatus? status;
  List<CouponModel>? couponLines;
  OrderAttributeModel? orderAttribute;
  String? paymentMethod;
  String? description;
  AddressModel? address;

  TransactionModel({
    this.id,
    this.userId,
    this.transactionId,
    this.date,
    this.dateShipped,
    this.datePaid,
    this.dateReturned,
    this.discount,
    this.shipping,
    this.amount,
    this.fromAccountVoucher,
    this.toAccountVoucher,
    this.transactionType,
    this.products,
    this.orderIds,
    this.status,
    this.couponLines,
    this.orderAttribute,
    this.paymentMethod,
    this.description,
    this.address,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json[TransactionFieldName.id] is ObjectId
          ? (json[TransactionFieldName.id] as ObjectId).toHexString()
          : json[TransactionFieldName.id]?.toString(),
      userId: json[TransactionFieldName.userId],
      transactionId: json[TransactionFieldName.transactionId] as int?,
      date: json[TransactionFieldName.date],
      dateShipped: json[TransactionFieldName.dateShipped],
      datePaid: json[TransactionFieldName.datePaid],
      dateReturned: json[TransactionFieldName.dateReturned],
      discount: (json[TransactionFieldName.discount] as num?)?.toDouble(),
      shipping: (json[TransactionFieldName.shipping] as num?)?.toDouble(),
      amount: (json[TransactionFieldName.amount] as num?)?.toDouble(),
      fromAccountVoucher: json[TransactionFieldName.fromAccountVoucher] != null
          ? AccountVoucherModel.fromJson(json[TransactionFieldName.fromAccountVoucher] as Map<String, dynamic>)
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
      orderIds: (json[TransactionFieldName.orderIds] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      status: json[TransactionFieldName.status] != null
          ?  OrderStatusExtension.fromString(json[TransactionFieldName.status]) : null,
      couponLines: json[TransactionFieldName.couponLines] != null
          ? List<CouponModel>.from(
              json[TransactionFieldName.couponLines].map((item) => CouponModel.fromJson(item)),
            )
          : null,
      orderAttribute: json[TransactionFieldName.couponLines] != null
          ? OrderAttributeModel.fromJson(json[TransactionFieldName.orderAttribute])
          : null,
      paymentMethod: json[TransactionFieldName.paymentMethod],
      address: json[TransactionFieldName.address] != null
          ? AddressModel.fromJson(json[TransactionFieldName.address])
          : null,
      description: json[TransactionFieldName.description],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) TransactionFieldName.id: id,
      if (userId != null) TransactionFieldName.userId: userId,
      if (transactionId != null) TransactionFieldName.transactionId: transactionId,
      if (discount != null) TransactionFieldName.discount: discount,
      if (shipping != null) TransactionFieldName.shipping: shipping,
      if (amount != null) TransactionFieldName.amount: amount,
      if (date != null) TransactionFieldName.date: date,
      if (dateShipped != null) TransactionFieldName.dateShipped: dateShipped,
      if (datePaid != null) TransactionFieldName.datePaid: datePaid,
      if (dateReturned != null) TransactionFieldName.dateReturned: dateReturned,
      if (transactionType != null) TransactionFieldName.transactionType: transactionType!.name,
      if (fromAccountVoucher != null) TransactionFieldName.fromAccountVoucher: fromAccountVoucher!.toJson(),
      if (toAccountVoucher != null) TransactionFieldName.toAccountVoucher: toAccountVoucher!.toJson(),
      if (products != null) TransactionFieldName.products: products!.map((item) => item.toMap()).toList(),
      if (orderIds != null) TransactionFieldName.orderIds: orderIds,
      if (status != null) TransactionFieldName.status: status!.name,
      if (couponLines != null) TransactionFieldName.couponLines: couponLines!.map((item) => item.toMap()).toList(),
      if (orderAttribute != null) TransactionFieldName.orderAttribute: orderAttribute!.toJson(),
      if (paymentMethod != null) TransactionFieldName.paymentMethod: paymentMethod,
      if (address != null) TransactionFieldName.address: address!.toMap(),
      if (description != null) TransactionFieldName.description: description,
    };
  }

  Map<String, dynamic> toMap() => toJson();
  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel.fromJson(map);
}
