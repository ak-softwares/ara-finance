import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
import '../../personalization/models/address_model.dart';
import '../../personalization/models/user_model.dart';
import '../../settings/app_settings.dart';
import 'cart_item_model.dart';
import 'coupon_model.dart';
import 'image_model.dart';
import 'transaction_model.dart';

class OrderModel {
  String? id;
  int? orderId;
  int? invoiceNumber;
  OrderStatus? status;
  String? currency;
  bool? pricesIncludeTax;
  DateTime? dateCreated;
  DateTime? dateModified;
  DateTime? dateShipped;
  DateTime? datePaid;
  DateTime? dateReturned;
  String? discountTotal;
  String? discountTax;
  String? shippingTotal;
  String? shippingTax;
  String? cartTax;
  double? total;
  String? totalTax;
  int? customerId;
  String? userId;
  UserModel? user;
  AddressModel? billing;
  AddressModel? shipping;
  String? paymentMethod;
  String? paymentMethodTitle;
  String? transactionId;
  String? customerIpAddress;
  String? customerUserAgent;
  String? customerNote;
  List<OrderMedaDataModel>? metaData;
  OrderAttributeModel? orderAttribute;
  List<CartModel>? lineItems;
  List<CouponModel>? couponLines;
  String? paymentUrl;
  String? currencySymbol;
  bool? setPaid;
  List<ImageModel>? purchaseInvoiceImages;
  TransactionModel? transaction;
  OrderType? orderType;

  OrderModel({
    this.id,
    this.invoiceNumber,
    this.orderId,
    this.status,
    this.currency,
    this.pricesIncludeTax,
    this.dateCreated,
    this.dateModified,
    this.dateShipped,
    this.datePaid,
    this.dateReturned,
    this.discountTotal,
    this.discountTax,
    this.shippingTotal,
    this.shippingTax,
    this.cartTax,
    this.total,
    this.totalTax,
    this.customerId,
    this.userId,
    this.user,
    this.billing,
    this.shipping,
    this.paymentMethod,
    this.paymentMethodTitle,
    this.transactionId,
    this.customerIpAddress,
    this.customerUserAgent,
    this.customerNote,
    this.metaData,
    this.orderAttribute,
    this.lineItems,
    this.couponLines,
    this.paymentUrl,
    this.currencySymbol,
    this.setPaid,
    this.purchaseInvoiceImages,
    this.transaction,
    this.orderType,
  });

  int get getDaysDelayed {
    final now = DateTime.now();
    return now.difference(dateCreated ?? DateTime.now()).inDays;
  }

  int calculateTotalSum() {
    return lineItems?.fold<int>(
      0,
          (previousValue, currentItem) => previousValue + (int.tryParse(currentItem.subtotal ?? '') ?? 0),
    ) ?? 0;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final OrderType orderType = OrderType.values.firstWhere(
          (e) => e.name == json[OrderFieldName.orderType],
      orElse: () => OrderType.sale,
    );
    final List<OrderMedaDataModel> metaData = json[OrderFieldName.metaData] != null
        ? List<OrderMedaDataModel>.from(
            json[OrderFieldName.metaData].map((item) => OrderMedaDataModel.fromJson(item)),
          )
        : [];
    return OrderModel(
      id: json[OrderFieldName.id] is ObjectId
          ? (json[OrderFieldName.id] as ObjectId).toHexString()
          : json[OrderFieldName.id]?.toString(),
      orderId: json[OrderFieldName.orderId],
      invoiceNumber: json[OrderFieldName.invoiceNumber] ?? 0,
      status: OrderStatusExtension.fromString(json[OrderFieldName.status] ?? ''),
      currency: json[OrderFieldName.currency] ?? '',
      pricesIncludeTax: json[OrderFieldName.pricesIncludeTax] ?? false,
      dateCreated: json[OrderFieldName.dateCreated],
      dateModified: json[OrderFieldName.dateModified],
      dateShipped: json[OrderFieldName.dateCompleted],
      datePaid: json[OrderFieldName.datePaid],
      dateReturned: json[OrderFieldName.dateReturned],
      discountTotal: json[OrderFieldName.discountTotal] ?? '',
      discountTax: json[OrderFieldName.discountTax] ?? '',
      shippingTotal: json[OrderFieldName.shippingTotal] ?? '',
      shippingTax: json[OrderFieldName.shippingTax] ?? '',
      cartTax: json[OrderFieldName.cartTax] ?? '',
      totalTax: json[OrderFieldName.totalTax] ?? '',
      total: json[OrderFieldName.total] ?? 0,
      customerId: json[OrderFieldName.customerId] ?? 0,
      userId: json[OrderFieldName.userId] ?? '',
      user: json[OrderFieldName.user] != null
          ? UserModel.fromJson(json[OrderFieldName.user])
          : UserModel(),
      billing: json[OrderFieldName.billing] != null
          ? AddressModel.fromJson(json[OrderFieldName.billing])
          : AddressModel(),
      shipping: json[OrderFieldName.shipping] != null
          ? AddressModel.fromJson(json[OrderFieldName.shipping])
          : AddressModel(),
      paymentMethod: json[OrderFieldName.paymentMethod] ?? '',
      paymentMethodTitle: json[OrderFieldName.paymentMethodTitle] ?? '',
      transactionId: json[OrderFieldName.transactionId] ?? '',
      customerIpAddress: json[OrderFieldName.customerIpAddress] ?? '',
      customerUserAgent: json[OrderFieldName.customerUserAgent] ?? '',
      customerNote: json[OrderFieldName.customerNote] ?? '',
      lineItems: List<CartModel>.from(
        json[OrderFieldName.lineItems].map((item) => CartModel.fromJson(item)),
      ),
      paymentUrl: json[OrderFieldName.paymentUrl] ?? '',
      currencySymbol: json[OrderFieldName.currencySymbol] ?? '',
      purchaseInvoiceImages: List<ImageModel>.from(
        json[OrderFieldName.purchaseInvoiceImages]?.map((item) => ImageModel.fromJson(item)) ?? [],
      ),
      couponLines: json[OrderFieldName.couponLines] != null
          ? List<CouponModel>.from(
              json[OrderFieldName.couponLines].map((item) => CouponModel.fromJson(item)),
            )
          : [],
      metaData: metaData,
      orderAttribute: OrderAttributeModel.fromMetaData(metaData),
      transaction: json[OrderFieldName.transaction] != null
          ? TransactionModel.fromJson(json[OrderFieldName.transaction])
          : TransactionModel(),
      orderType: orderType,
    );
  }

  factory OrderModel.fromJsonWoo(Map<String, dynamic> json) {
    final List<OrderMedaDataModel>? metaData = json[OrderFieldName.metaData] != null
        ? List<OrderMedaDataModel>.from(
            json[OrderFieldName.metaData].map((item) => OrderMedaDataModel.fromJson(item)),
          )
        : null;

    return OrderModel(
      orderId: json[OrderFieldName.wooId],
      status: OrderStatusExtension.fromString(json[OrderFieldName.status] ?? ''),
      currency: json[OrderFieldName.currency] ?? '',
      pricesIncludeTax: json[OrderFieldName.pricesIncludeTax] ?? false,
      dateCreated: json[OrderFieldName.dateCreated] != null && json[OrderFieldName.dateCreated] != ''
          ? DateTime.parse(json[OrderFieldName.dateCreated])
          : null,

      dateModified: json[OrderFieldName.dateModified] != null && json[OrderFieldName.dateModified] != ''
          ? DateTime.parse(json[OrderFieldName.dateModified])
          : null,

      datePaid: json[OrderFieldName.datePaid] != null && json[OrderFieldName.datePaid] != ''
          ? DateTime.parse(json[OrderFieldName.datePaid])
          : null,

      discountTotal: json[OrderFieldName.discountTotal]?.toString() ?? '',
      discountTax: json[OrderFieldName.discountTax]?.toString() ?? '',
      shippingTotal: json[OrderFieldName.shippingTotal]?.toString() ?? '',
      shippingTax: json[OrderFieldName.shippingTax]?.toString() ?? '',
      cartTax: json[OrderFieldName.cartTax]?.toString() ?? '',
      totalTax: json[OrderFieldName.totalTax]?.toString() ?? '',
      total: double.tryParse(json[OrderFieldName.total]?.toString() ?? '0') ?? 0.0,
      customerId: json[OrderFieldName.customerId] ?? 0,
      billing: json[OrderFieldName.billing] != null
          ? AddressModel.fromJson(json[OrderFieldName.billing])
          : AddressModel(),
      shipping: json[OrderFieldName.shipping] != null
          ? AddressModel.fromJson(json[OrderFieldName.shipping])
          : AddressModel(),
      paymentMethod: json[OrderFieldName.paymentMethod] ?? '',
      paymentMethodTitle: json[OrderFieldName.paymentMethodTitle] ?? '',
      transactionId: json[OrderFieldName.transactionId] ?? '',
      customerIpAddress: json[OrderFieldName.customerIpAddress] ?? '',
      customerUserAgent: json[OrderFieldName.customerUserAgent] ?? '',
      customerNote: json[OrderFieldName.customerNote] ?? '',
      lineItems: List<CartModel>.from(
        json[OrderFieldName.lineItems].map((item) => CartModel.fromJson(item)),
      ),
      paymentUrl: json[OrderFieldName.paymentUrl] ?? '',
      currencySymbol: json[OrderFieldName.currencySymbol] ?? '',
      couponLines: json[OrderFieldName.couponLines] != null
          ? List<CouponModel>.from(
              json[OrderFieldName.couponLines].map((item) => CouponModel.fromJson(item)),
            )
          : null,
      metaData: metaData,
      orderAttribute: OrderAttributeModel.fromMetaData(metaData),

    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (orderId != null) OrderFieldName.orderId: orderId,
      if (invoiceNumber != null) OrderFieldName.invoiceNumber: invoiceNumber,
      if (status != null) OrderFieldName.status: status?.name,
      if (currency != null) OrderFieldName.currency: currency,
      if (pricesIncludeTax != null) OrderFieldName.pricesIncludeTax: pricesIncludeTax,
      if (dateCreated != null) OrderFieldName.dateCreated: dateCreated,
      if (dateModified != null) OrderFieldName.dateModified: dateModified,
      if (dateShipped != null) OrderFieldName.dateCompleted: dateShipped,
      if (datePaid != null) OrderFieldName.datePaid: datePaid,
      if (dateReturned != null) OrderFieldName.dateReturned: dateReturned,
      if (discountTotal != null) OrderFieldName.discountTotal: discountTotal,
      if (discountTax != null) OrderFieldName.discountTax: discountTax,
      if (shippingTotal != null) OrderFieldName.shippingTotal: shippingTotal,
      if (shippingTax != null) OrderFieldName.shippingTax: shippingTax,
      if (cartTax != null) OrderFieldName.cartTax: cartTax,
      if (total != null) OrderFieldName.total: total,
      if (totalTax != null) OrderFieldName.totalTax: totalTax,
      if (customerId != null) OrderFieldName.customerId: customerId,
      if (userId != null) OrderFieldName.userId: userId,
      if (user != null) OrderFieldName.user: user?.toMap(),
      if (billing != null) OrderFieldName.billing: billing?.toMap(),
      if (shipping != null) OrderFieldName.shipping: shipping?.toMap(),
      if (paymentMethod != null) OrderFieldName.paymentMethod: paymentMethod,
      if (paymentMethodTitle != null) OrderFieldName.paymentMethodTitle: paymentMethodTitle,
      if (transactionId != null) OrderFieldName.transactionId: transactionId,
      if (customerIpAddress != null) OrderFieldName.customerIpAddress: customerIpAddress,
      if (customerUserAgent != null) OrderFieldName.customerUserAgent: customerUserAgent,
      if (customerNote != null) OrderFieldName.customerNote: customerNote,
      if (dateShipped != null) OrderFieldName.dateCompleted: dateShipped,
      if (datePaid != null) OrderFieldName.datePaid: datePaid,
      if (setPaid != null) OrderFieldName.setPaid: setPaid,
      if (lineItems != null) OrderFieldName.lineItems: lineItems?.map((item) => item.toMap()).toList(),
      if (paymentUrl != null) OrderFieldName.paymentUrl: paymentUrl,
      if (currencySymbol != null) OrderFieldName.currencySymbol: currencySymbol,
      if (couponLines != null) OrderFieldName.couponLines: couponLines?.map((item) => item.toMap()).toList(),
      if (purchaseInvoiceImages != null)
        OrderFieldName.purchaseInvoiceImages: purchaseInvoiceImages?.map((img) => img.toJson()).toList(),
      if (metaData != null) OrderFieldName.metaData: metaData?.map((item) => item.toMap()).toList(),
      if (transaction != null) OrderFieldName.transaction: transaction?.toMap(),
      if (orderType != null) OrderFieldName.orderType: orderType?.name,
    };
  }


  final List<Map<String, dynamic>> shippingLines = [
    {
      "method_id": "flat_rate",
      "method_title": "Shipping",
      "total": '${AppSettings.shippingCharge}'
    }
  ];

  OrderModel copyWith({
    String? id,
    int? orderId,
    int? invoiceNumber,
    OrderStatus? status,
    String? currency,
    bool? pricesIncludeTax,
    DateTime? dateCreated,
    DateTime? dateModified,
    DateTime? dateCompleted,
    DateTime? datePaid,
    DateTime? dateReturned,
    String? discountTotal,
    String? discountTax,
    String? shippingTotal,
    String? shippingTax,
    String? cartTax,
    double? total,
    String? totalTax,
    int? userId,
    UserModel? user,
    AddressModel? billing,
    AddressModel? shipping,
    String? paymentMethod,
    String? paymentMethodTitle,
    String? transactionId,
    String? customerIpAddress,
    String? customerUserAgent,
    String? customerNote,
    List<OrderMedaDataModel>? metaData,
    List<CartModel>? lineItems,
    List<CouponModel>? couponLines,
    String? paymentUrl,
    String? currencySymbol,
    bool? setPaid,
    List<ImageModel>? purchaseInvoiceImages,
    OrderType? orderType,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      pricesIncludeTax: pricesIncludeTax ?? this.pricesIncludeTax,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      dateShipped: dateCompleted ?? this.dateShipped,
      datePaid: datePaid ?? this.datePaid,
      dateReturned: dateReturned ?? this.dateReturned,
      discountTotal: discountTotal ?? this.discountTotal,
      discountTax: discountTax ?? this.discountTax,
      shippingTotal: shippingTotal ?? this.shippingTotal,
      shippingTax: shippingTax ?? this.shippingTax,
      cartTax: cartTax ?? this.cartTax,
      total: total ?? this.total,
      totalTax: totalTax ?? this.totalTax,
      customerId: userId ?? this.customerId,
      user: user ?? this.user,
      billing: billing ?? this.billing,
      shipping: shipping ?? this.shipping,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentMethodTitle: paymentMethodTitle ?? this.paymentMethodTitle,
      transactionId: transactionId ?? this.transactionId,
      customerIpAddress: customerIpAddress ?? this.customerIpAddress,
      customerUserAgent: customerUserAgent ?? this.customerUserAgent,
      customerNote: customerNote ?? this.customerNote,
      metaData: metaData ?? this.metaData,
      lineItems: lineItems ?? this.lineItems,
      couponLines: couponLines ?? this.couponLines,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      setPaid: setPaid ?? this.setPaid,
      purchaseInvoiceImages: purchaseInvoiceImages ?? this.purchaseInvoiceImages,
      orderType: orderType ?? this.orderType,
    );
  }
}

class OrderMedaDataModel {
  final int? id;
  final String? key;
  final String? value;

  OrderMedaDataModel({
    this.id,
    this.key,
    this.value,
  });

  factory OrderMedaDataModel.fromJson(Map<String, dynamic> json) {
    return OrderMedaDataModel(
      id: json[OrderMetaDataName.id] is String ? int.tryParse(json[OrderMetaDataName.id]) : json[OrderMetaDataName.id],
      key: json[OrderMetaDataName.key],
      value: json[OrderMetaDataName.value]?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      OrderMetaDataName.id: id,
      OrderMetaDataName.key: key,
      OrderMetaDataName.value: value,
    };
  }

  Map<String, dynamic> toJsonForWoo() {
    return {
      OrderMetaDataName.key: key ?? '',
      OrderMetaDataName.value: value ?? '',
    };
  }
}

class OrderAttributeModel {
  String? source;
  String? sourceType; // e.g., referral, organic, unknown, utm, Web Admin, typein (Direct)
  String? medium; // e.g., cart page source
  String? campaign; // e.g., google_cpc
  String? referrer; // e.g., referral URL
  DateTime? date;

  OrderAttributeModel({
    this.source,
    this.sourceType,
    this.medium,
    this.campaign,
    this.referrer,
    this.date,
  });

  Map<String, dynamic> toJson({bool isLocal = false}) {
    final Map<String, dynamic> data = {};

    if (source != null) data[OrderMetaKeyName.source] = source;
    if (sourceType != null) data[OrderMetaKeyName.sourceType] = sourceType;
    if (medium != null) data[OrderMetaKeyName.medium] = medium;
    if (campaign != null) data[OrderMetaKeyName.campaign] = campaign;
    if (referrer != null) data[OrderMetaKeyName.referrer] = referrer;
    if(isLocal){
      if (date != null) data[OrderMetaKeyName.date] = date!.toIso8601String();
    }
    return data;
  }

  factory OrderAttributeModel.fromJson(Map<String, dynamic> json) {
    return OrderAttributeModel(
      source: json[OrderMetaKeyName.source],
      sourceType: json[OrderMetaKeyName.sourceType],
      medium: json[OrderMetaKeyName.medium],
      campaign: json[OrderMetaKeyName.campaign],
      referrer: json[OrderMetaKeyName.referrer],
      date: json[OrderMetaKeyName.date] != null ? DateTime.parse(json[OrderMetaKeyName.date]) : null,
    );
  }

  factory OrderAttributeModel.fromMetaData(List<OrderMedaDataModel>? metaData) {
    if (metaData == null) {
      return OrderAttributeModel(); // or use default values
    }

    String? getValue(String key) => metaData.firstWhere(
          (m) => m.key == key,
      orElse: () => OrderMedaDataModel(key: key, value: null),
    ).value;

    return OrderAttributeModel(
      source: getValue(OrderMetaKeyName.source),
      sourceType: getValue(OrderMetaKeyName.sourceType),
      medium: getValue(OrderMetaKeyName.medium),
      campaign: getValue(OrderMetaKeyName.campaign),
      referrer: getValue(OrderMetaKeyName.referrer),
    );
  }
}

class RevenueSummary {
  final String type;
  final int totalRevenue;
  final int orderCount;
  final double percent;
  final List<SourceBreakdown> sourceBreakdown;

  RevenueSummary({
    required this.type,
    required this.totalRevenue,
    required this.orderCount,
    required this.percent,
    required this.sourceBreakdown,
  });
}

class SourceBreakdown {
  final String source;
  final int revenue;
  final int orderCount;
  final double percent;

  SourceBreakdown({
    required this.source,
    required this.revenue,
    required this.orderCount,
    required this.percent,
  });
}
