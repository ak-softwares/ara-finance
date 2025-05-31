import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/account/account_controller.dart';
import '../../controller/account/add_account_controller.dart';
import '../../models/account_model.dart';

class AddAccount extends StatelessWidget {
  const AddAccount({super.key, this.payment});

  final AccountModel? payment;

  @override
  Widget build(BuildContext context) {
    final AddAccountController controller = Get.put(AddAccountController());

    if( payment != null) {
      controller.resetValue(payment!);
    }

    return Scaffold(
      appBar: AppAppBar(title: payment != null ? 'Update Account' : 'Add Account'),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => payment != null ? controller.saveUpdatedPayment(previousPayment: payment!) : controller.savePaymentMethods(),
          child: Text(payment != null ? 'Update Account' : 'Add Account', style: TextStyle(fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: controller.accountsFormKey,
            child: Column(
              spacing: AppSizes.spaceBtwItems,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Accounts id'),
                    payment != null
                        ? Text('#${payment!.accountId}')
                        : Obx(() => Text('#${controller.accountId.value}')),
                  ],
                ),
                TextFormField(
                  controller: controller.accountsName,
                  decoration: InputDecoration(
                    labelText: 'Account Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.openingBalance,
                  decoration: InputDecoration(
                    labelText: 'Opening Balance',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}