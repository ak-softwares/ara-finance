import '../../../utils/constants/db_constants.dart';
import '../../personalization/models/user_model.dart';
import 'account_voucher_model.dart';

class CartModel {
  String? id;
  String? name;
  int productId;
  int? variationId;
  int quantity;
  int? stockQuantity;
  String? category;
  String? subtotal;
  String? subtotalTax;
  String? totalTax;
  String? total;
  String? sku;
  int? price;
  int? hsnCode;
  double? purchasePrice;
  String? image;
  AccountVoucherModel? vendor;

  //constructor
  CartModel({
    this.id,
    this.name,
    required this.productId,
    this.variationId,
    required this.quantity,
    this.stockQuantity,
    this.category,
    this.subtotal,
    this.subtotalTax,
    this.totalTax,
    this.total,
    this.sku,
    this.price,
    this.hsnCode,
    this.purchasePrice,
    this.image,
    this.vendor,
  });

  // Create a cartItem from a json map
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json[CartFieldName.id].toString(),
      name: json[CartFieldName.name] ?? '',
      productId: int.tryParse(json[CartFieldName.productId]?.toString() ?? '') ?? 0,
      variationId: int.tryParse(json[CartFieldName.variationId]?.toString() ?? '') ?? 0,
      stockQuantity: json[CartFieldName.stockQuantity] ?? 0,
      quantity: int.tryParse(json[CartFieldName.quantity]?.toString() ?? '') ?? 0,
      category: json[CartFieldName.category] ?? '',
      subtotal: json[CartFieldName.subtotal] ?? '',
      subtotalTax: json[CartFieldName.subtotalTax] ?? '',
      totalTax: json[CartFieldName.totalTax] ?? '',
      total: json[CartFieldName.total] ?? '',
      sku: json[CartFieldName.sku] ?? '',
      price: json[CartFieldName.price].toInt() ?? 0,
      hsnCode: json[CartFieldName.hsnCode] ?? 0,
      purchasePrice: json[CartFieldName.purchasePrice] ?? 0,
      image: json[CartFieldName.image] != null && json[CartFieldName.image] is Map
          ? json[CartFieldName.image][CartFieldName.src]
          : '',
      vendor: json[CartFieldName.vendor] != null
          ? AccountVoucherModel.fromJson(json[CartFieldName.vendor])
          : AccountVoucherModel(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CartFieldName.id: id,
      CartFieldName.name: name,
      CartFieldName.productId: productId,
      CartFieldName.variationId: variationId,
      CartFieldName.quantity: quantity,
      CartFieldName.stockQuantity: stockQuantity,
      CartFieldName.category: category,
      CartFieldName.subtotal: subtotal,
      CartFieldName.subtotalTax: subtotalTax,
      CartFieldName.totalTax: totalTax,
      CartFieldName.total: total,
      CartFieldName.sku: sku,
      CartFieldName.price: price,
      CartFieldName.hsnCode: hsnCode,
      CartFieldName.purchasePrice: purchasePrice,
      CartFieldName.image: image != null && image!.isNotEmpty ? {CartFieldName.src: image} : '',
      CartFieldName.vendor: vendor?.toMap(),
    };
  }

  CartModel copyWith({
    String? id,
    String? name,
    String? userId,
    String? product_id,
    int? productId,
    int? variationId,
    int? quantity,
    int? stockQuantity,
    String? category,
    String? subtotal,
    String? subtotalTax,
    String? totalTax,
    String? total,
    String? sku,
    int? price,
    int? hsnCode,
    double? purchasePrice,
    String? image,
    String? parentName,
    bool? isCODBlocked,
    String? pageSource,
    AccountVoucherModel? vendor,
  }) {
    return CartModel(
      id: id ?? this.id,
      name: name ?? this.name,
      productId: productId ?? this.productId,
      variationId: variationId ?? this.variationId,
      quantity: quantity ?? this.quantity,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      subtotal: subtotal ?? this.subtotal,
      subtotalTax: subtotalTax ?? this.subtotalTax,
      totalTax: totalTax ?? this.totalTax,
      total: total ?? this.total,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      hsnCode: hsnCode ?? this.hsnCode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      image: image ?? this.image,
      vendor: vendor ?? this.vendor,
    );
  }

}