import 'package:mongo_dart/mongo_dart.dart';
import '../../../data/repositories/mongodb/account_voucher/account_voucher_repo.dart';
import '../../../utils/constants/db_constants.dart';
import '../../../utils/constants/enums.dart';

class AccountVoucherModel {
  String? id;
  int? voucherId;
  String? userId;
  String? title;
  double? openingBalance;
  double? currentBalance;
  DateTime? dateCreated;
  AccountVoucherType? voucherType;

  AccountVoucherModel({
    this.id,
    this.userId,
    this.voucherId,
    this.title,
    this.openingBalance,
    this.currentBalance,
    this.dateCreated,
    this.voucherType,
  });

  Future<double> get getCurrentBalance async {
    return await MongoAccountVoucherRepo.instance.fetchVoucherBalance(voucherId: id ?? '');
  }

  double get closingBalance => (openingBalance ?? 0) + (currentBalance ?? 0);

  // From JSON
  factory AccountVoucherModel.fromJson(Map<String, dynamic> json) {
    return AccountVoucherModel(
      id: json[AccountVoucherFieldName.id] is ObjectId
          ? (json[AccountVoucherFieldName.id] as ObjectId).toHexString()
          : json[AccountVoucherFieldName.id]?.toString(),
      userId: json[AccountVoucherFieldName.userId] as String?,
      voucherId: json[AccountVoucherFieldName.voucherId] as int?,
      title: json[AccountVoucherFieldName.title] as String?,
      openingBalance: json[AccountVoucherFieldName.openingBalance] != null
          ? double.tryParse(json[AccountVoucherFieldName.openingBalance].toString())
          : null,
      currentBalance: json[AccountVoucherFieldName.currentBalance],
      dateCreated: json[AccountVoucherFieldName.dateCreated],
      voucherType: json[AccountVoucherFieldName.voucherType] != null
          ? AccountVoucherType.values.firstWhere((type) => type.name == json[AccountVoucherFieldName.voucherType])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data[AccountVoucherFieldName.id] = id;
    if (userId != null) data[AccountVoucherFieldName.userId] = userId;
    if (voucherId != null) data[AccountVoucherFieldName.voucherId] = voucherId;
    if (title != null) data[AccountVoucherFieldName.title] = title;
    if (openingBalance != null) data[AccountVoucherFieldName.openingBalance] = openingBalance;
    if (dateCreated != null) data[AccountVoucherFieldName.dateCreated] = dateCreated;
    if (voucherType != null) data[AccountVoucherFieldName.voucherType] = voucherType?.name;
    return data;
  }

  Map<String, dynamic> toMap() => toJson();
}
