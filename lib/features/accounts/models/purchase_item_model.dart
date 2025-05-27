import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';

class PurchaseItemModel {
  int? id;
  String? image;
  String? name;
  int? prepaidQuantity;
  int? bulkQuantity;
  int? totalQuantity;
  bool? isOlderThanTwoDays;
  int? stock;
  String? vendor;

  PurchaseItemModel({
    this.id,
    this.image,
    this.name = '',
    this.prepaidQuantity = 0,
    this.bulkQuantity = 0,
    this.totalQuantity = 0,
    this.stock,
    this.vendor,
    this.isOlderThanTwoDays = false,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      prepaidQuantity: json['prepaidQuantity'],
      bulkQuantity: json['bulkQuantity'],
      totalQuantity: json['totalQuantity'],
      isOlderThanTwoDays: json['isOlderThanTwoDays'],
      stock: json['stock'],
      vendor: json['vendor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'prepaidQuantity': prepaidQuantity,
      'bulkQuantity': bulkQuantity,
      'totalQuantity': totalQuantity,
      'isOlderThanTwoDays': isOlderThanTwoDays,
      'stock': stock,
      'vendor': vendor,
    };
  }

}

class PurchaseListMetaModel {
  String? id;
  String? metaName;
  String? extraNote;
  DateTime? lastSyncDate;
  List<int>? purchasedProductIds;
  List<int>? notAvailableProductIds;
  List<OrderStatus>? orderStatus;

  PurchaseListMetaModel({
    this.id,
    this.metaName,
    this.extraNote,
    this.lastSyncDate,
    this.purchasedProductIds,
    this.notAvailableProductIds,
    this.orderStatus,
  });

  factory PurchaseListMetaModel.fromJson(Map<String, dynamic> json) {
    return PurchaseListMetaModel(
      id: json[PurchaseListFieldName.id] is ObjectId
          ? (json[PurchaseListFieldName.id] as ObjectId).toHexString() // Convert ObjectId to string
          : json[PurchaseListFieldName.id]?.toString(), // Fallback to string if not ObjectId
      extraNote: json[PurchaseListFieldName.extraNote]?.toString() ?? '',
      lastSyncDate: json[PurchaseListFieldName.lastSyncDate],
      purchasedProductIds: (json[PurchaseListFieldName.purchasedProductIds] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ??
          [],
      notAvailableProductIds: (json[PurchaseListFieldName.notAvailableProductIds] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ??
          [],
      orderStatus: (json[PurchaseListFieldName.orderStatus] as List<dynamic>?)
          ?.map((e) => OrderStatusExtension.fromString(e.toString())!)
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    if (id != null) data[PurchaseListFieldName.id] = id;
    if (extraNote != null) data[PurchaseListFieldName.extraNote] = extraNote;
    if (lastSyncDate != null) data[PurchaseListFieldName.lastSyncDate] = lastSyncDate;
    if (purchasedProductIds != null) data[PurchaseListFieldName.purchasedProductIds] = purchasedProductIds;
    if (notAvailableProductIds != null) data[PurchaseListFieldName.notAvailableProductIds] = notAvailableProductIds;
    if (orderStatus != null) {
      data[PurchaseListFieldName.orderStatus] = orderStatus!.map((e) => e.name).toList();
    }

    return data;
  }


  PurchaseListMetaModel copyWith({
    String? id,
    String? metaName,
    String? extraNote,
    DateTime? lastSyncDate,
    List<int>? purchasedProductIds,
    List<int>? notAvailableProductIds,
    List<OrderStatus>? orderStatus,
  }) {
    return PurchaseListMetaModel(
      id: id ?? this.id,
      metaName: metaName ?? this.metaName,
      extraNote: extraNote ?? this.metaName,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      purchasedProductIds: purchasedProductIds ?? this.purchasedProductIds,
      notAvailableProductIds: notAvailableProductIds ?? this.notAvailableProductIds,
      orderStatus: orderStatus ?? this.orderStatus,
    );
  }
}
