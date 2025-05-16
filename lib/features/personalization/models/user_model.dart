import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';
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
  String? dateCreated;
  String? dateModified;
  bool? isPhoneVerified;
  String? fCMToken;
  bool? isCODBlocked;
  UserType userType;
  DateTime? activeTime;
  List<dynamic>? cartItems;
  List<dynamic>? wishlistItems;
  List<dynamic>? recentItems;
  List<dynamic>? customerOrders;

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
  });

  static UserModel empty() => UserModel();

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
      companyName: json[UserFieldConstants.company] ?? '',
      gstNumber: json[UserFieldConstants.gstNumber] ?? '',
      billing: AddressModel.fromJson(json[UserFieldConstants.billing] ?? {}),
      shipping: AddressModel.fromJson(json[UserFieldConstants.shipping] ?? {}),
      isPayingCustomer: json[UserFieldConstants.isPayingCustomer] ?? false,
      avatarUrl: json[UserFieldConstants.avatarUrl] ?? '',
      dateCreated: json[UserFieldConstants.dateCreated] ?? '',
      dateModified: json[UserFieldConstants.dateModified] ?? '',
      isPhoneVerified: (json[UserFieldConstants.metaData] as List?)?.any((meta) =>
      meta['key'] == UserFieldConstants.verifyPhone && meta['value'] == true) ?? false,
      fCMToken: (json[UserFieldConstants.metaData] as List?)?.firstWhere(
              (meta) => meta['key'] == UserFieldConstants.fCMToken,
          orElse: () => {'value': ''})['value'] ?? '',
      isCODBlocked: (json[UserFieldConstants.metaData] as List?)?.any((meta) =>
      meta['key'] == UserFieldConstants.isCODBlocked && meta['value'] == "1") ?? false,
      balance: json[UserFieldConstants.balance]?.toDouble() ?? 0.0,
      openingBalance: json[UserFieldConstants.openingBalance]?.toDouble(),
      userType: userType,
      activeTime: json[UserFieldConstants.activeTime] != null
          ? DateTime.parse(json[UserFieldConstants.activeTime])
          : null,
      cartItems: json[UserFieldConstants.cartItems] as List<dynamic>?,
      wishlistItems: json[UserFieldConstants.wishlistItems] as List<dynamic>?,
      recentItems: json[UserFieldConstants.recentItems] as List<dynamic>?,
      customerOrders: json[UserFieldConstants.customerOrders] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    void addIfNotNull(String key, dynamic value) {
      if (value != null) map[key] = value;
    }
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
    addIfNotNull(UserFieldConstants.balance, balance);
    addIfNotNull(UserFieldConstants.openingBalance, openingBalance);
    addIfNotNull(UserFieldConstants.userType, userType.name);
    addIfNotNull(UserFieldConstants.activeTime, activeTime?.toIso8601String());
    addIfNotNull(UserFieldConstants.cartItems, cartItems);
    addIfNotNull(UserFieldConstants.wishlistItems, wishlistItems);
    addIfNotNull(UserFieldConstants.recentItems, recentItems);
    addIfNotNull(UserFieldConstants.customerOrders, customerOrders);

    final metaDataList = <Map<String, dynamic>>[];

    if (isPhoneVerified != null) {
      metaDataList.add({
        'key': UserFieldConstants.verifyPhone,
        'value': isPhoneVerified,
      });
    }

    if (fCMToken != null) {
      metaDataList.add({
        'key': UserFieldConstants.fCMToken,
        'value': fCMToken,
      });
    }

    if (isCODBlocked != null) {
      metaDataList.add({
        'key': UserFieldConstants.isCODBlocked,
        'value': isCODBlocked! ? "1" : "0",
      });
    }

    if (metaDataList.isNotEmpty) {
      map[UserFieldConstants.metaData] = metaDataList;
    }

    return map;
  }

  Map<String, dynamic> toJsonForSignUp() {
    return {
      UserFieldConstants.firstName: firstName,
      UserFieldConstants.username: username,
      UserFieldConstants.email: email,
      UserFieldConstants.password: password,
      UserFieldConstants.billing: billing?.toJsonForWoo(),
      UserFieldConstants.shipping: shipping?.toJsonForWoo(),
      UserFieldConstants.userType: userType.toString().split('.').last,
    };
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
