import 'package:ara_finance/features/accounts/models/account_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
import '../../setup/models/ecommerce_platform.dart';
import 'address_model.dart';

class UserModel {
  String? id;
  String? userId;
  int? documentId;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? name;
  String? role;
  String? username;
  String? phone;
  String? companyName;
  String? gstNumber;
  AddressModel? billing;
  AddressModel? shipping;
  double? balance;
  double? openingBalance;
  bool? isPayingCustomer;
  String? avatarUrl;
  DateTime? dateCreated;
  DateTime? dateModified;
  DateTime? activeTime;
  bool? isPhoneVerified;
  String? fCMToken;
  bool? isCODBlocked;
  UserType userType;
  List<dynamic>? cartItems;
  List<dynamic>? wishlistItems;
  List<dynamic>? recentItems;
  List<dynamic>? customerOrders;
  EcommercePlatform? ecommercePlatform;
  AccountModel? selectedAccount;
  WooCommerceCredentials? wooCommerceCredentials;
  ShopifyCredentials? shopifyCredentials;
  AmazonCredentials? amazonCredentials;

  UserModel({
    this.id,
    this.userId,
    this.documentId,
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.name,
    this.role,
    this.username,
    this.phone,
    this.companyName,
    this.gstNumber,
    this.billing,
    this.shipping,
    this.balance,
    this.openingBalance,
    this.isPayingCustomer,
    this.avatarUrl,
    this.dateCreated,
    this.dateModified,
    this.isPhoneVerified,
    this.fCMToken,
    this.isCODBlocked,
    this.userType = UserType.customer,
    this.activeTime,
    this.cartItems,
    this.wishlistItems,
    this.recentItems,
    this.customerOrders,
    this.selectedAccount,
    this.ecommercePlatform,
    this.wooCommerceCredentials,
    this.shopifyCredentials,
    this.amazonCredentials,
  });

  static UserModel empty() => UserModel();

  double get closingBalance => (openingBalance ?? 0) + (balance ?? 0);

  String get fullName {
    if (name != null && name!.isNotEmpty) return name!;
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  bool get isVendor => userType == UserType.vendor;
  bool get isCustomer => userType == UserType.customer;
  bool get isAdmin => userType == UserType.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final UserType userType = UserType.values.firstWhere(
          (e) => e.name == json[UserFieldConstants.userType],
      orElse: () => UserType.customer, // or a default fallback
    );

    final EcommercePlatform platform = EcommercePlatform.values.firstWhere(
          (e) => e.name == json[UserFieldConstants.ecommercePlatform],
      orElse: () => EcommercePlatform.none,
    );
    return UserModel(
      id: json[UserFieldConstants.id] is ObjectId
          ? (json[UserFieldConstants.id] as ObjectId).toHexString() // Convert ObjectId to string
          : json[UserFieldConstants.id]?.toString(), // Fallback to string if not ObjectId
      userId: json[UserFieldConstants.userId] ?? '',
      firstName: json[UserFieldConstants.firstName] ?? '',
      lastName: json[UserFieldConstants.lastName] ?? '',
      documentId: json[UserFieldConstants.documentId] ?? 0,
      email: json[UserFieldConstants.email] ?? '',
      password: json[UserFieldConstants.password] ?? '',
      name: json[UserFieldConstants.name] ?? '',
      role: json[UserFieldConstants.role] ?? '',
      username: json[UserFieldConstants.username] ?? '',
      phone: json[UserFieldConstants.phone] ?? (json[UserFieldConstants.billing]?[UserFieldConstants.phone] ?? ''),
      companyName: json[UserFieldConstants.company],
      gstNumber: json[UserFieldConstants.gstNumber],
      billing: AddressModel.fromJson(json[UserFieldConstants.billing] ?? {}),
      shipping: AddressModel.fromJson(json[UserFieldConstants.shipping] ?? {}),
      isPayingCustomer: json[UserFieldConstants.isPayingCustomer] ?? false,
      avatarUrl: json[UserFieldConstants.avatarUrl] ?? '',
      dateCreated: parseDate(json[UserFieldConstants.dateCreated]),
      dateModified: parseDate(json[UserFieldConstants.dateModified]),
      activeTime: parseDate(json[UserFieldConstants.activeTime]),
      isPhoneVerified: (json[UserFieldConstants.metaData] as List?)?.any((meta) =>
      meta['key'] == UserFieldConstants.verifyPhone && meta['value'] == true) ?? false,
      fCMToken: (json[UserFieldConstants.metaData] as List?)?.firstWhere(
              (meta) => meta['key'] == UserFieldConstants.fCMToken,
          orElse: () => {'value': ''})['value'] ?? '',
      isCODBlocked: (json[UserFieldConstants.metaData] as List?)?.any((meta) =>
      meta['key'] == UserFieldConstants.isCODBlocked && meta['value'] == "1") ?? false,
      balance: json[UserFieldConstants.balance]?.toDouble() ?? 0.0,
      openingBalance: json[UserFieldConstants.openingBalance]?.toDouble() ?? 0.0,
      userType: userType,
      cartItems: json[UserFieldConstants.cartItems] as List<dynamic>?,
      wishlistItems: json[UserFieldConstants.wishlistItems] as List<dynamic>?,
      recentItems: json[UserFieldConstants.recentItems] as List<dynamic>?,
      customerOrders: json[UserFieldConstants.customerOrders] as List<dynamic>?,
      ecommercePlatform: platform,
      wooCommerceCredentials: json[UserFieldConstants.wooCommerceCredentials] != null
          ? WooCommerceCredentials.fromJson(json[UserFieldConstants.wooCommerceCredentials])
          : null,
      shopifyCredentials: json[UserFieldConstants.shopifyCredentials] != null
          ? ShopifyCredentials.fromJson(json[UserFieldConstants.shopifyCredentials])
          : null,
      amazonCredentials: json[UserFieldConstants.amazonCredentials] != null
          ? AmazonCredentials.fromJson(json[UserFieldConstants.amazonCredentials])
          : null,
      selectedAccount: json[UserFieldConstants.selectedAccount] != null
          ? AccountModel.fromJson(json[UserFieldConstants.selectedAccount])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) map[key] = value;
    }
    addIfNotNull(UserFieldConstants.id, id);
    addIfNotNull(UserFieldConstants.documentId, documentId);
    addIfNotNull(UserFieldConstants.userId, userId);
    addIfNotNull(UserFieldConstants.email, email);
    addIfNotNull(UserFieldConstants.name, name);
    addIfNotNull(UserFieldConstants.role, role);
    addIfNotNull(UserFieldConstants.username, username);
    addIfNotNull(UserFieldConstants.password, password);
    addIfNotNull(UserFieldConstants.phone, phone);
    addIfNotNull(UserFieldConstants.company, companyName);
    addIfNotNull(UserFieldConstants.gstNumber, gstNumber);
    addIfNotNull(UserFieldConstants.billing, billing?.toMap());
    addIfNotNull(UserFieldConstants.shipping, shipping?.toMap());
    addIfNotNull(UserFieldConstants.isPayingCustomer, isPayingCustomer);
    addIfNotNull(UserFieldConstants.avatarUrl, avatarUrl);
    addIfNotNull(UserFieldConstants.dateCreated, dateCreated);
    addIfNotNull(UserFieldConstants.dateModified, dateModified);
    addIfNotNull(UserFieldConstants.activeTime, activeTime);
    addIfNotNull(UserFieldConstants.balance, balance);
    addIfNotNull(UserFieldConstants.openingBalance, openingBalance);
    addIfNotNull(UserFieldConstants.userType, userType.name);
    addIfNotNull(UserFieldConstants.cartItems, cartItems);
    addIfNotNull(UserFieldConstants.wishlistItems, wishlistItems);
    addIfNotNull(UserFieldConstants.recentItems, recentItems);
    addIfNotNull(UserFieldConstants.customerOrders, customerOrders);
    addIfNotNull(UserFieldConstants.ecommercePlatform, ecommercePlatform?.name);
    addIfNotNull(UserFieldConstants.wooCommerceCredentials, wooCommerceCredentials?.toJson());
    addIfNotNull(UserFieldConstants.shopifyCredentials, shopifyCredentials?.toJson());
    addIfNotNull(UserFieldConstants.amazonCredentials, amazonCredentials?.toJson());
    addIfNotNull(UserFieldConstants.selectedAccount, selectedAccount?.toMap());

    final metaDataList = <Map<String, dynamic>>[];

    if (metaDataList.isNotEmpty) {
      map[UserFieldConstants.metaData] = metaDataList;
    }

    return map;
  }
}

class UserMetaDataModel {
  final int? id;
  final String? key;
  final String? value;

  UserMetaDataModel({
    this.id,
    this.key,
    this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key ?? '',
      'value': value ?? '',
    };
  }
}

DateTime? parseDate(dynamic value) {
  if (value == null) return null;

  if (value is DateTime) {
    return value;
  } else if (value is String) {
    try {
      return DateTime.tryParse(value);
    } catch (e) {
      return null;
    }
  }
  return null;
}