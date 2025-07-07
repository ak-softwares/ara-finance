import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
import '../../personalization/models/user_model.dart';
import 'account_voucher_model.dart';
import 'brand_model.dart';
import 'category_model.dart';
import 'product_attribute_model.dart';

class ProductModel {
  String? id;
  String? userId;
  int? productId;
  String? title;
  String? mainImage;
  String? permalink;
  String? slug;
  DateTime? dateCreated;
  DateTime? dateModified;
  DateTime? dateOnSaleFrom;
  DateTime? dateOnSaleTo;
  String? type;
  String? status;
  bool? featured;
  String? catalogVisibility;
  String? description;
  String? shortDescription;
  String? sku;
  double? price;
  double? regularPrice;
  double? salePrice;
  double? purchasePrice;
  bool? onSale;
  bool? purchasable;
  int? totalSales;
  bool? virtual;
  bool? downloadable;
  String? taxStatus;
  String? taxClass;
  bool? manageStock;
  int? stockQuantity;
  String? weight;
  Map<String, dynamic>? dimensions;
  bool? shippingRequired;
  bool? shippingTaxable;
  String? shippingClass;
  int? shippingClassId;
  bool? reviewsAllowed;
  double? averageRating;
  int? ratingCount;
  List<int>? upsellIds;
  List<int>? crossSellIds;
  int? parentId;
  String? purchaseNote;
  List<BrandModel>? brands;
  List<CategoryModel>? categories;
  List<Map<String, dynamic>>? tags;
  List<Map<String, dynamic>>? images;
  String? image;
  List<ProductAttributeModel>? attributes;
  List<ProductAttributeModel>? defaultAttributes;
  List<int>? variations;
  List<int>? groupedProducts;
  int? menuOrder;
  List<int>? relatedIds;
  String? stockStatus;
  AccountVoucherModel? vendor;
  bool? isCODBlocked;

  ProductModel({
    this.id,
    this.userId,
    this.productId,
    this.title,
    this.mainImage,
    this.permalink,
    this.slug,
    this.dateCreated,
    this.dateModified,
    this.dateOnSaleFrom,
    this.dateOnSaleTo,
    this.type,
    this.status,
    this.featured,
    this.catalogVisibility,
    this.description,
    this.shortDescription,
    this.sku,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.purchasePrice,
    this.onSale,
    this.purchasable,
    this.totalSales,
    this.virtual,
    this.downloadable,
    this.taxStatus,
    this.taxClass,
    this.manageStock,
    this.stockQuantity,
    this.weight,
    this.dimensions,
    this.shippingRequired,
    this.shippingTaxable,
    this.shippingClass,
    this.shippingClassId,
    this.reviewsAllowed,
    this.averageRating,
    this.ratingCount,
    this.upsellIds,
    this.crossSellIds,
    this.parentId,
    this.purchaseNote,
    this.categories,
    this.brands,
    this.tags,
    this.images,
    this.image,
    this.attributes,
    this.defaultAttributes,
    this.variations,
    this.groupedProducts,
    this.menuOrder,
    this.relatedIds,
    this.stockStatus,
    this.vendor,
    this.isCODBlocked,
  });

  // create product empty model
  static ProductModel empty() => ProductModel(productId: 0);

  bool isProductAvailable() {
    // Check if the coupon provides free shipping
    return stockStatus == 'instock' && getPrice() != 0;
  }

  double getPrice() {
    if (salePrice != null && salePrice! > 0) {
      return salePrice!;
    }
    return regularPrice ?? 0.0;
  }


  //-- Calculate Discount Percentage
  String? calculateSalePercentage() {
    if (salePrice == null || salePrice! <= 0.0 || regularPrice == null || regularPrice! <= 0.0) {
      return null;
    }

    double percentage = ((regularPrice! - salePrice!) / regularPrice!) * 100;
    return percentage.toStringAsFixed(0);
  }

  String getAllRelatedProductsIdsAsString() {
    List<String> mergedIds = [];

    if (relatedIds != null) {
      mergedIds.addAll(relatedIds!.map((id) => id.toString()));
    }

    if (upsellIds != null) {
      mergedIds.addAll(upsellIds!.map((id) => id.toString()));
    }

    if (crossSellIds != null) {
      mergedIds.addAll(crossSellIds!.map((id) => id.toString()));
    }

    return mergedIds.join(',');
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {

    final String type = json[ProductFieldName.type] ?? '';

    // Extracting category data from the JSON
    List<CategoryModel>? categories = [CategoryModel.empty()];
    if (json.containsKey(ProductFieldName.categories) && json[ProductFieldName.categories] is List) {
      categories = (json[ProductFieldName.categories] as List).map((category) => CategoryModel.fromJson(category)).toList();
    }

    // Extracting brands data from the JSON
    List<BrandModel>? brands = [];
    if (json.containsKey(ProductFieldName.brands) && json[ProductFieldName.brands] is List) {
      brands = (json[ProductFieldName.brands] as List).map((brand) => BrandModel.fromJson(brand)).toList();
    }

    // Extracting Attribute data from the JSON
    List<ProductAttributeModel>? attributes = [];
    if (json.containsKey(ProductFieldName.attributes) && json[ProductFieldName.attributes] is List) {
      attributes = (json[ProductFieldName.attributes] as List).map((attribute) =>
        ProductAttributeModel.fromJson(attribute)).toList();
    }

    // Extracting Attribute data from the JSON
    List<ProductAttributeModel>? defaultAttributes = [];
    if (json.containsKey(ProductFieldName.defaultAttributes) && json[ProductFieldName.defaultAttributes] is List) {
      defaultAttributes = (json[ProductFieldName.defaultAttributes] as List).map((attribute) =>
          ProductAttributeModel.fromJson(attribute)).toList();
    }

    return ProductModel(
      id: json[PurchaseFieldName.id] is ObjectId
          ? (json[PurchaseFieldName.id] as ObjectId).toHexString() // Convert ObjectId to string
          : json[PurchaseFieldName.id]?.toString(),
      userId: json[ProductFieldName.userId],
      productId: json[ProductFieldName.productId] ?? 0,
      title: json[ProductFieldName.name].replaceAll('&amp;', '&'),
      mainImage: json[ProductFieldName.images] != null && json[ProductFieldName.images].isNotEmpty
          ? json[ProductFieldName.images][0]['src'] : '',
      permalink: json[ProductFieldName.permalink] ?? '',
      slug: json[ProductFieldName.slug] ?? '',
      dateCreated: json[ProductFieldName.dateCreated],
      dateModified: json[ProductFieldName.dateModified],
      dateOnSaleFrom: json[ProductFieldName.dateOnSaleFrom],
      dateOnSaleTo: json[ProductFieldName.dateOnSaleTo],
      type: type,
      status: json[ProductFieldName.status] ?? '',
      featured: json[ProductFieldName.featured] ?? false,
      catalogVisibility: json[ProductFieldName.catalogVisibility] ?? '',
      description: json[ProductFieldName.description] ?? '',
      shortDescription: json[ProductFieldName.shortDescription] ?? '',
      sku: json[ProductFieldName.sku] ?? '',
      price: double.tryParse(json[ProductFieldName.price] ?? '0.0'),
      salePrice: double.tryParse(json[ProductFieldName.salePrice] ?? '0.0'),
      regularPrice: double.tryParse(json[ProductFieldName.regularPrice] ?? '0.0'),
      purchasePrice: json[ProductFieldName.purchasePrice] ?? 0,
      onSale: json[ProductFieldName.onSale] ?? false,
      purchasable: json[ProductFieldName.purchasable] ?? false,
      totalSales: int.tryParse(json[ProductFieldName.totalSales]?.toString() ?? '0') ?? 0,
      virtual: json[ProductFieldName.virtual] ?? false,
      downloadable: json[ProductFieldName.downloadable] ?? false,
      taxStatus: json[ProductFieldName.taxStatus] ?? '',
      taxClass: json[ProductFieldName.taxClass] ?? '',
      manageStock: json[ProductFieldName.manageStock] ?? false,
      stockQuantity: json[ProductFieldName.stockQuantity] ?? 0,
      weight: json[ProductFieldName.weight] ?? '',
      dimensions: json[ProductFieldName.dimensions] != null
          ? Map<String, dynamic>.from(json[ProductFieldName.dimensions])
          : null,
      shippingRequired: json[ProductFieldName.shippingRequired] ?? false,
      shippingTaxable: json[ProductFieldName.shippingTaxable] ?? false,
      shippingClass: json[ProductFieldName.shippingClass] ?? '',
      shippingClassId: json[ProductFieldName.shippingClassId] ?? 0,
      reviewsAllowed: json[ProductFieldName.reviewsAllowed] ?? false,
      averageRating: double.tryParse(json[ProductFieldName.averageRating] ?? '0.0'),
      ratingCount: json[ProductFieldName.ratingCount] ?? 0,
      upsellIds: List<int>.from(json[ProductFieldName.upsellIds] ?? []),
      crossSellIds: List<int>.from(json[ProductFieldName.crossSellIds] ?? []),
      parentId: json[ProductFieldName.parentId] ?? 0,
      purchaseNote: json[ProductFieldName.purchaseNote] ?? '',
      tags: List<Map<String, dynamic>>.from(json[ProductFieldName.tags] ?? []),
      images: json[ProductFieldName.images] != null
          ? List<Map<String, dynamic>>.from(json[ProductFieldName.images])
          : [],
      image: json[ProductFieldName.image] != null && json[ProductFieldName.image].isNotEmpty
          ? json[ProductFieldName.image]['src'] : '',
      categories: categories,
      brands: brands,
      attributes: attributes,
      defaultAttributes: defaultAttributes,
      variations: List<int>.from(json[ProductFieldName.variations] ?? []),
      groupedProducts: List<int>.from(json[ProductFieldName.groupedProducts] ?? []),
      menuOrder: json[ProductFieldName.menuOrder] ?? 0,
      relatedIds: List<int>.from(json[ProductFieldName.relatedIds] ?? []),
      stockStatus: json[ProductFieldName.stockStatus] ?? '',
      isCODBlocked: (json[ProductFieldName.metaData] as List?)?.any((meta) => meta['key'] == ProductFieldName.isCODBlocked && meta['value'] == "1") ?? false,
      vendor: json[ProductFieldName.vendor] != null
          ? AccountVoucherModel.fromJson(json[ProductFieldName.vendor])
          : AccountVoucherModel(),
    );
  }

  factory ProductModel.fromJsonWoo(Map<String, dynamic> json) {

    final String type = json[ProductFieldName.type] ?? '';

    // Extracting category data from the JSON
    List<CategoryModel>? categories = [CategoryModel.empty()];
    if (json.containsKey(ProductFieldName.categories) && json[ProductFieldName.categories] is List) {
      categories = (json[ProductFieldName.categories] as List).map((category) => CategoryModel.fromJson(category)).toList();
    }

    // Extracting brands data from the JSON
    List<BrandModel>? brands = [];
    if (json.containsKey(ProductFieldName.brands) && json[ProductFieldName.brands] is List) {
      brands = (json[ProductFieldName.brands] as List).map((brand) => BrandModel.fromJson(brand)).toList();
    }

    // Extracting Attribute data from the JSON
    List<ProductAttributeModel>? attributes = [];
    if (json.containsKey(ProductFieldName.attributes) && json[ProductFieldName.attributes] is List) {
      attributes = (json[ProductFieldName.attributes] as List).map((attribute) =>
          ProductAttributeModel.fromJson(attribute)).toList();
    }

    // Extracting Attribute data from the JSON
    List<ProductAttributeModel>? defaultAttributes = [];
    if (json.containsKey(ProductFieldName.defaultAttributes) && json[ProductFieldName.defaultAttributes] is List) {
      defaultAttributes = (json[ProductFieldName.defaultAttributes] as List).map((attribute) =>
          ProductAttributeModel.fromJson(attribute)).toList();
    }

    return ProductModel(
      userId: json[ProductFieldName.userId],
      productId: json[ProductFieldName.productId] ?? 0,
      title: json[ProductFieldName.name].replaceAll('&amp;', '&'),
      mainImage: json[ProductFieldName.images] != null && json[ProductFieldName.images].isNotEmpty
          ? json[ProductFieldName.images][0]['src'] : '',
      permalink: json[ProductFieldName.permalink] ?? '',
      slug: json[ProductFieldName.slug] ?? '',
      dateCreated: json[ProductFieldName.dateCreated] != null && json[ProductFieldName.dateCreated] != ''
          ? DateTime.parse(json[ProductFieldName.dateCreated])
          : null,
      dateOnSaleFrom: json[ProductFieldName.dateOnSaleFrom] != null && json[ProductFieldName.dateOnSaleFrom] != ''
          ? DateTime.parse(json[ProductFieldName.dateOnSaleFrom])
          : null,
      dateOnSaleTo: json[ProductFieldName.dateOnSaleTo] != null && json[ProductFieldName.dateOnSaleTo] != ''
          ? DateTime.parse(json[ProductFieldName.dateOnSaleTo])
          : null,
      type: type,
      status: json[ProductFieldName.status] ?? '',
      featured: json[ProductFieldName.featured] ?? false,
      catalogVisibility: json[ProductFieldName.catalogVisibility] ?? '',
      description: json[ProductFieldName.description] ?? '',
      shortDescription: json[ProductFieldName.shortDescription] ?? '',
      sku: json[ProductFieldName.sku] ?? '',
      price: double.tryParse(json[ProductFieldName.price] ?? '0.0'),
      salePrice: double.tryParse(json[ProductFieldName.salePrice] ?? '0.0'),
      regularPrice: double.tryParse(json[ProductFieldName.regularPrice] ?? '0.0'),
      onSale: json[ProductFieldName.onSale] ?? false,
      purchasable: json[ProductFieldName.purchasable] ?? false,
      totalSales: int.tryParse(json[ProductFieldName.totalSales]?.toString() ?? '0') ?? 0,
      virtual: json[ProductFieldName.virtual] ?? false,
      downloadable: json[ProductFieldName.downloadable] ?? false,
      taxStatus: json[ProductFieldName.taxStatus] ?? '',
      taxClass: json[ProductFieldName.taxClass] ?? '',
      manageStock: json[ProductFieldName.manageStock] ?? false,
      stockQuantity: json[ProductFieldName.stockQuantity] ?? 0,
      weight: json[ProductFieldName.weight] ?? '',
      dimensions: json[ProductFieldName.dimensions] != null
          ? Map<String, dynamic>.from(json[ProductFieldName.dimensions])
          : null,
      shippingRequired: json[ProductFieldName.shippingRequired] ?? false,
      shippingTaxable: json[ProductFieldName.shippingTaxable] ?? false,
      shippingClass: json[ProductFieldName.shippingClass] ?? '',
      shippingClassId: json[ProductFieldName.shippingClassId] ?? 0,
      reviewsAllowed: json[ProductFieldName.reviewsAllowed] ?? false,
      averageRating: double.tryParse(json[ProductFieldName.averageRating] ?? '0.0'),
      ratingCount: json[ProductFieldName.ratingCount] ?? 0,
      upsellIds: List<int>.from(json[ProductFieldName.upsellIds] ?? []),
      crossSellIds: List<int>.from(json[ProductFieldName.crossSellIds] ?? []),
      parentId: json[ProductFieldName.parentId] ?? 0,
      purchaseNote: json[ProductFieldName.purchaseNote] ?? '',
      tags: List<Map<String, dynamic>>.from(json[ProductFieldName.tags] ?? []),
      images: json[ProductFieldName.images] != null
          ? List<Map<String, dynamic>>.from(json[ProductFieldName.images])
          : [],
      image: json[ProductFieldName.image] != null && json[ProductFieldName.image].isNotEmpty
          ? json[ProductFieldName.image]['src'] : '',
      categories: categories,
      brands: brands,
      attributes: attributes,
      defaultAttributes: defaultAttributes,
      variations: List<int>.from(json[ProductFieldName.variations] ?? []),
      groupedProducts: List<int>.from(json[ProductFieldName.groupedProducts] ?? []),
      menuOrder: json[ProductFieldName.menuOrder] ?? 0,
      relatedIds: List<int>.from(json[ProductFieldName.relatedIds] ?? []),
      stockStatus: json[ProductFieldName.stockStatus] ?? '',
      purchasePrice: double.tryParse(
        (json[ProductFieldName.metaData] as List?)?.firstWhere(
              (meta) => meta['key'] == ProductFieldName.cogs,
          orElse: () => {'value': '0'},
        )['value'].toString() ?? '0',
      ) ?? 0.0,
      isCODBlocked: (json[ProductFieldName.metaData] as List?)?.any((meta) => meta['key'] == ProductFieldName.isCODBlocked && meta['value'] == "1") ?? false,
    );
  }

  // Method to extract only the 'src' values from the images list
  List<String> get imageUrlList {
    return images?.map<String>((image) => image['src']).toList() ?? [];
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    final map = <String, dynamic>{};

    void add(String key, dynamic value) {
      if (value != null) map[key] = value;
    }

    add(ProductFieldName.userId, userId);
    add(ProductFieldName.productId, productId);
    add(ProductFieldName.name, title);
    add(ProductFieldName.mainImage, mainImage);
    add(ProductFieldName.permalink, permalink);
    add(ProductFieldName.slug, slug);
    add(ProductFieldName.dateCreated, dateCreated);
    add(ProductFieldName.dateModified, dateModified);
    add(ProductFieldName.dateOnSaleFrom, dateOnSaleFrom);
    add(ProductFieldName.dateOnSaleTo, dateOnSaleTo);
    add(ProductFieldName.type, type);
    add(ProductFieldName.status, status);
    add(ProductFieldName.featured, featured);
    add(ProductFieldName.catalogVisibility, catalogVisibility);
    add(ProductFieldName.description, description);
    add(ProductFieldName.shortDescription, shortDescription);
    add(ProductFieldName.sku, sku);
    add(ProductFieldName.price, price?.toString());
    add(ProductFieldName.regularPrice, regularPrice?.toString());
    add(ProductFieldName.salePrice, salePrice?.toString());
    add(ProductFieldName.onSale, onSale);
    add(ProductFieldName.purchasable, purchasable);
    add(ProductFieldName.totalSales, totalSales);
    add(ProductFieldName.virtual, virtual);
    add(ProductFieldName.downloadable, downloadable);
    add(ProductFieldName.taxStatus, taxStatus);
    add(ProductFieldName.taxClass, taxClass);
    add(ProductFieldName.manageStock, manageStock);
    add(ProductFieldName.weight, weight);
    add(ProductFieldName.dimensions, dimensions);
    add(ProductFieldName.shippingRequired, shippingRequired);
    add(ProductFieldName.shippingTaxable, shippingTaxable);
    add(ProductFieldName.shippingClass, shippingClass);
    add(ProductFieldName.shippingClassId, shippingClassId);
    add(ProductFieldName.reviewsAllowed, reviewsAllowed);
    add(ProductFieldName.averageRating, averageRating?.toString());
    add(ProductFieldName.ratingCount, ratingCount);
    add(ProductFieldName.upsellIds, upsellIds);
    add(ProductFieldName.crossSellIds, crossSellIds);
    add(ProductFieldName.parentId, parentId);
    add(ProductFieldName.purchaseNote, purchaseNote);

    add(ProductFieldName.brands, brands?.map((b) => b.toMap()).toList());
    add(ProductFieldName.categories, categories?.map((c) => c.toMap()).toList());
    add(ProductFieldName.tags, tags);
    add(ProductFieldName.images, images);
    add(ProductFieldName.image, image);
    add(ProductFieldName.attributes, attributes?.map((a) => a.toMap()).toList());
    add(ProductFieldName.defaultAttributes, defaultAttributes?.map((a) => a.toMap()).toList());

    add(ProductFieldName.variations, variations);
    add(ProductFieldName.groupedProducts, groupedProducts);
    add(ProductFieldName.menuOrder, menuOrder);
    add(ProductFieldName.relatedIds, relatedIds);
    add(ProductFieldName.stockStatus, stockStatus);
    add(ProductFieldName.isCODBlocked, isCODBlocked);
    add(ProductFieldName.vendor, vendor?.toMap());

    if (!isUpdate) {
      add(ProductFieldName.purchasePrice, purchasePrice);
      add(ProductFieldName.stockQuantity, stockQuantity);
    }

    return map;
  }

}

int parseDoubleToInt(dynamic value) {
  if (value == null) return 0;
  try {
    double parsedValue = double.parse(value.toString());
    return parsedValue.toInt();
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing value: $e');
    }
    return 0;
  }
}

