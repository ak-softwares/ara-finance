import 'db_constants.dart';

enum TextSizes { small, medium, large }

enum UserType { customer, vendor, admin, }

enum OrderType { purchase, sale, }

enum OrientationType {horizontal, vertical}

enum EcommercePlatform { none, woocommerce, shopify, amazon}

enum PurchaseListType { purchasable, purchased, notAvailable, vendors }

enum SyncType { add, update, check }

enum SyncStatus { idle, fetching, checking, pushing, completed, failed }

enum AccountVoucherType { payment, vendor, refund, transfer, purchase, delete, expense, sale, receipt, creditNote, bankAccount, customer, product}

extension VoucherEntityTypeExtension on AccountVoucherType {
  String get name {
    switch (this) {
      // VoucherType cases
      case AccountVoucherType.payment:
        return 'payment';
      case AccountVoucherType.vendor:
        return 'vendor';
      case AccountVoucherType.refund:
        return 'refund';
      case AccountVoucherType.transfer:
        return 'transfer';
      case AccountVoucherType.purchase:
        return 'purchase';
      case AccountVoucherType.delete:
        return 'delete';
      case AccountVoucherType.expense:
        return 'expense';
      case AccountVoucherType.sale:
        return 'sale';
      case AccountVoucherType.receipt:
        return 'receipt';
      case AccountVoucherType.creditNote:
        return 'creditNote';
      case AccountVoucherType.bankAccount:
        return 'bankAccount';
      case AccountVoucherType.customer:
        return 'customer';
      case AccountVoucherType.product:
        return 'product';
    }
  }

  String get dbName {
    switch (this) {
    // Cases where dbName was defined in EntityType
      case AccountVoucherType.vendor:
      case AccountVoucherType.customer:
        return DbCollections.users;
      case AccountVoucherType.bankAccount:
        return DbCollections.accounts;
      case AccountVoucherType.expense:
        return DbCollections.expenses;

      // Default case (if not defined in original EntityType)
      default:
        throw UnimplementedError('dbName not defined for ${this.name}');
    }
  }

  String get fieldName {
    switch (this) {
      // Cases where fieldName was defined in EntityType
      case AccountVoucherType.vendor:
        return VendorFieldName.vendorId;
      case AccountVoucherType.bankAccount:
        return AccountFieldName.accountId;
      case AccountVoucherType.customer:
        return UserFieldConstants.documentId;

      // Default case (if not defined in original EntityType)
      default:
        throw UnimplementedError('fieldName not defined for ${this.name}');
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