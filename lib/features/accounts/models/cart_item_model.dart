import '../../../utils/constants/db_constants.dart';
import '../../personalization/models/user_model.dart';
import 'account_voucher_model.dart';

class CartModel {
  int? id;
  String? name;
  String? userId;
  String? product_id;
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
  double? purchasePrice;
  String? image;
  String? parentName;
  bool? isCODBlocked;
  String? pageSource;
  AccountVoucherModel? vendor;

  //constructor
  CartModel({
    this.id,
    this.name,
    this.product_id,
    this.userId,
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
    this.purchasePrice,
    this.image,
    this.parentName,
    this.isCODBlocked,
    this.pageSource,
    this.vendor,
  });

  // Empty cart
  static CartModel empty() => CartModel(id: 0, name: '', productId: 0, quantity: 0, price: 0);

  // Convert a cartItem to a Json map
  Map<String, dynamic> toJson() {
    return {
      CartFieldName.id: id,
      CartFieldName.name: name,
      CartFieldName.userId: userId,
      CartFieldName.product_id: product_id,
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
      CartFieldName.purchasePrice: purchasePrice,
      CartFieldName.image: (image ?? '').isNotEmpty
          ? {CartFieldName.src: image}
          : null, // Keep the structure same as the input JSON
      CartFieldName.parentName: parentName,
      CartFieldName.isCODBlocked: isCODBlocked,
      CartFieldName.vendor: vendor?.toMap(),
    };
  }

  //Convert a cartItem to a Json map
  Map<String, dynamic> toJsonForWoo() {
    return {
      CartFieldName.productId: productId.toString(),
      CartFieldName.variationId: variationId?.toString() ?? '',
      CartFieldName.quantity: quantity.toString(),
    };
  }

  // Create a cartItem from a json map
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json[CartFieldName.id] ?? 0,
      userId: json[CartFieldName.userId] ?? '',
      name: json[CartFieldName.name] ?? '',
      product_id: json[CartFieldName.product_id] ?? '',
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
      purchasePrice: json[CartFieldName.purchasePrice] ?? 0,
      image: json[CartFieldName.image] != null && json[CartFieldName.image] is Map
          ? json[CartFieldName.image][CartFieldName.src]
          : '',
      parentName: json[CartFieldName.parentName] ?? '',
      isCODBlocked: json[CartFieldName.isCODBlocked] ?? false,
      vendor: json[CartFieldName.vendor] != null
          ? AccountVoucherModel.fromJson(json[CartFieldName.vendor])
          : AccountVoucherModel(),
    );
  }

  // create a cartItem from a json map
  factory CartModel.fromJsonLocalStorage(Map<String, dynamic> json) {
    return CartModel(
      id: json[CartFieldName.id] ?? 0,
      name: json[CartFieldName.name] ?? '',
      userId: json[CartFieldName.userId] ?? '',
      product_id: json[CartFieldName.product_id] ?? '',
      productId: json[CartFieldName.productId] ?? 0, // Changed to product_id
      variationId: json[CartFieldName.variationId] ?? 0, // Changed to variation_id
      stockQuantity: json[CartFieldName.stockQuantity] ?? 0,
      quantity: json[CartFieldName.quantity] ?? 0,
      category: json[CartFieldName.category] ?? '',
      subtotal: json[CartFieldName.subtotal] ?? '',
      subtotalTax: json[CartFieldName.subtotalTax] ?? '',
      totalTax: json[CartFieldName.totalTax] ?? '',
      total: json[CartFieldName.total] ?? '',
      sku: json[CartFieldName.sku] ?? '',
      price: json[CartFieldName.price] ?? 0,
      purchasePrice: json[CartFieldName.purchasePrice] ?? 0,
      image: json[CartFieldName.image] != null && json[CartFieldName.image] is Map
          ? json[CartFieldName.image][CartFieldName.src]
          : '',
      // image: json[CartFieldName.image],
      parentName: json[CartFieldName.parentName] ?? '',
      isCODBlocked: json[CartFieldName.isCODBlocked] ?? false,
      pageSource: json[CartFieldName.pageSource] ?? '',
      vendor: json[CartFieldName.vendor] != null
          ? AccountVoucherModel.fromJson(json[CartFieldName.vendor])
          : AccountVoucherModel(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CartFieldName.id: id,
      CartFieldName.name: name,
      CartFieldName.userId: userId,
      CartFieldName.product_id: product_id,
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
      CartFieldName.purchasePrice: purchasePrice,
      CartFieldName.image: image != null && image!.isNotEmpty ? {CartFieldName.src: image} : '',
      CartFieldName.parentName: parentName,
      CartFieldName.isCODBlocked: isCODBlocked,
      CartFieldName.vendor: vendor?.toMap(),
    };
  }

  CartModel copyWith({
    int? id,
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
      userId: userId ?? this.userId,
      product_id: product_id ?? this.product_id,
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
      purchasePrice: purchasePrice ?? this.purchasePrice,
      image: image ?? this.image,
      parentName: parentName ?? this.parentName,
      isCODBlocked: isCODBlocked ?? this.isCODBlocked,
      pageSource: pageSource ?? this.pageSource,
      vendor: vendor ?? this.vendor,
    );
  }

}