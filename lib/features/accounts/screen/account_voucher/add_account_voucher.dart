import 'package:ara_finance/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/account_voucher/add_account_voucher_controller.dart';
import '../../models/account_voucher_model.dart';

class AddAccountVoucher extends StatelessWidget {
  const AddAccountVoucher({super.key, this.accountVoucher, required this.voucherType});

  final AccountVoucherModel? accountVoucher;
  final AccountVoucherType voucherType;

  @override
  Widget build(BuildContext context) {
    final AddAccountVoucherController controller = Get.put(
      AddAccountVoucherController(voucherType: voucherType),
    );
    final String title = voucherType.name.capitalizeFirst ?? 'Account voucher';

    if (accountVoucher != null) {
      controller.resetValue(accountVoucher!);
    }

    return Scaffold(
      appBar: AppAppBar(title: accountVoucher != null ? 'Update $title' : 'Add $title'),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => accountVoucher != null
              ? controller.saveUpdatedAccountVoucher(previousAccountVoucher: accountVoucher!)
              : controller.saveAccountVoucher(),
          child: Text(
            accountVoucher != null ? 'Update $title' : 'Add $title',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: controller.accountVoucherFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$title ID'),
                    accountVoucher != null
                        ? Text('#${accountVoucher!.voucherId}')
                        : Obx(() => Text('#${controller.accountVoucherId.value}')),
                  ],
                ),
                SizedBox(height: AppSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.accountVoucherName,
                  validator: (value) => Validator.validateEmptyText(fieldName: '$title Name', value: value),
                  decoration: InputDecoration(
                    labelText: '$title Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSizes.spaceBtwItems),
                TextFormField(
                  controller: controller.openingBalance,
                  decoration: InputDecoration(
                    labelText: 'Opening Balance',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}