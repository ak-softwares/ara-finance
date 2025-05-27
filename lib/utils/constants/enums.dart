import 'db_constants.dart';

enum TextSizes { small, medium, large }

enum UserType { customer, vendor, admin, }
enum OrderType { purchase, sale, }

enum OrientationType {horizontal, vertical}

enum EcommercePlatform { none, woocommerce, shopify, amazon}

// Enum to specify search type
enum SearchType { products, customers, orders, vendor, paymentMethod}

enum TransactionType { payment, refund, transfer, purchase, delete, expense, sale}

enum PurchaseListType { purchasable, purchased, notAvailable, vendors }

enum EntityType { vendor, account, customer, expense }
extension EntityTypeExtension on EntityType {

  String get name {
    switch (this) {
      case EntityType.vendor:
        return 'vendor';
      case EntityType.account:
        return 'account';
      case EntityType.customer:
        return 'customer';
      case EntityType.expense:
        return 'expense';
    }
  }

  String get dbName {
    switch (this) {
      case EntityType.vendor:
        return DbCollections.users;
      case EntityType.account:
        return DbCollections.accounts;
      case EntityType.customer:
        return DbCollections.users;
      case EntityType.expense:
        return DbCollections.expenses;
    }
  }

  String get fieldName {
    switch (this) {
      case EntityType.vendor:
        return VendorFieldName.vendorId;
      case EntityType.account:
        return AccountFieldName.accountId;
      case EntityType.customer:
        return UserFieldConstants.documentId;
      case EntityType.expense:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}


enum PaymentMethods { cod, prepaid, paytm, razorpay }
extension PaymentMethodsExtension on PaymentMethods {
  String get name {
    switch (this) {
      case PaymentMethods.cod:
        return PaymentMethodName.cod;
      case PaymentMethods.prepaid:
        return PaymentMethodName.prepaid;
      case PaymentMethods.paytm:
        return PaymentMethodName.paytm;
      case PaymentMethods.razorpay:
        return PaymentMethodName.razorpay;
    }
  }

  String get title {
    switch (this) {
      case PaymentMethods.cod:
        return PaymentMethodTitle.cod;
      case PaymentMethods.prepaid:
        return PaymentMethodTitle.prepaid;
      case PaymentMethods.paytm:
        return PaymentMethodTitle.paytm;
      case PaymentMethods.razorpay:
        return PaymentMethodTitle.razorpay;
    }
  }

  static PaymentMethods fromString(String method) {
    return PaymentMethods.values.firstWhere(
          (e) => e.name == method,
      orElse: () => PaymentMethods.cod, // Default to COD if unknown
    );
  }
}

enum OrderStatus {
  cancelled,
  processing,
  readyToShip,
  pendingPickup,
  pendingPayment,
  inTransit,
  completed,
  returnInTransit,
  returnPending,
  returned,
  unknown
}

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
      case OrderStatus.cancelled:
        return OrderStatusName.cancelled;
      case OrderStatus.processing:
        return OrderStatusName.processing;
      case OrderStatus.readyToShip:
        return OrderStatusName.readyToShip;
      case OrderStatus.pendingPickup:
        return OrderStatusName.pendingPickup;
      case OrderStatus.pendingPayment:
        return OrderStatusName.pendingPayment;
      case OrderStatus.inTransit:
        return OrderStatusName.inTransit;
      case OrderStatus.completed:
        return OrderStatusName.completed;
      case OrderStatus.returnInTransit:
        return OrderStatusName.returnInTransit;
      case OrderStatus.returnPending:
        return OrderStatusName.returnPending;
      case OrderStatus.returned:
        return OrderStatusName.returned;
      case OrderStatus.unknown:
        return OrderStatusName.unknown;
    }
  }

  String get prettyName {
    switch (this) {
      case OrderStatus.cancelled:
        return OrderStatusPritiName.cancelled;
      case OrderStatus.processing:
        return OrderStatusPritiName.processing;
      case OrderStatus.readyToShip:
        return OrderStatusPritiName.readyToShip;
      case OrderStatus.pendingPickup:
        return OrderStatusPritiName.pendingPickup;
      case OrderStatus.pendingPayment:
        return OrderStatusPritiName.pendingPayment;
      case OrderStatus.inTransit:
        return OrderStatusPritiName.inTransit;
      case OrderStatus.completed:
        return OrderStatusPritiName.completed;
      case OrderStatus.returnInTransit:
        return OrderStatusPritiName.returnInTransit;
      case OrderStatus.returnPending:
        return OrderStatusPritiName.returnPending;
      case OrderStatus.returned:
        return OrderStatusPritiName.returned;
      case OrderStatus.unknown:
        return OrderStatusName.unknown;
    }
  }

  static OrderStatus? fromString(String status) {
    return OrderStatus.values.firstWhere(
          (e) => e.name == status,
      orElse: () => OrderStatus.unknown, // Handle unknown statuses
    );
  }
}

enum ExpenseType {
  shipping,
  facebookAds,
  googleAds,
  rent,
  salary,
  transport,
  other
}

extension ExpenseTypeExtension on ExpenseType {
  String get name {
    switch (this) {
      case ExpenseType.shipping:
        return ExpenseTypeName.shipping;
      case ExpenseType.facebookAds:
        return ExpenseTypeName.facebookAds;
      case ExpenseType.googleAds:
        return ExpenseTypeName.googleAds;
      case ExpenseType.rent:
        return ExpenseTypeName.rent;
      case ExpenseType.salary:
        return ExpenseTypeName.salary;
      case ExpenseType.transport:
        return ExpenseTypeName.transport;
      case ExpenseType.other:
        return ExpenseTypeName.others;
    }
  }

  static ExpenseType? fromString(String status) {
    return ExpenseType.values.firstWhere(
          (e) => e.name == status,
      orElse: () => ExpenseType.other, // Handle unknown statuses
    );
  }
}