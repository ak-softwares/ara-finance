import '../../../utils/constants/db_constants.dart';

class BankAccountModel {
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  String? swiftCode;

  BankAccountModel({
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.swiftCode,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      bankName: json[BankAccountFieldName.bankName] ?? '',
      accountNumber: json[BankAccountFieldName.accountNumber] ?? '',
      ifscCode: json[BankAccountFieldName.ifscCode] ?? '',
      swiftCode: json[BankAccountFieldName.swiftCode],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (bankName != null) data[BankAccountFieldName.bankName] = bankName;
    if (accountNumber != null) data[BankAccountFieldName.accountNumber] = accountNumber;
    if (ifscCode != null) data[BankAccountFieldName.ifscCode] = ifscCode;
    if (swiftCode != null) data[BankAccountFieldName.swiftCode] = swiftCode;

    return data;
  }

  @override
  String toString() {
    return 'BankAccountModel(bankName: $bankName, accountNumber: $accountNumber, ifscCode: $ifscCode, swiftCode: $swiftCode)';
  }
}
