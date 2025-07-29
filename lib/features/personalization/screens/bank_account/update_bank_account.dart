import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/data/state_iso_code_map.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/address_controller.dart';
import '../../controllers/bank_account_controller.dart';
import '../../models/address_model.dart';
import '../../models/bank_account.dart';

class UpdateBankAccount extends StatelessWidget {
  const UpdateBankAccount({
    super.key,
    required this.bankAccount,
    required this.userId,
    required this.userType,
  });

  final String userId;
  final UserType userType;
  final BankAccountModel bankAccount;

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(BankAccountController());
    controller.initializedInPutField(bankAccount: bankAccount);

    return Scaffold(
      appBar: AppAppBar(title: 'Update Bank Account'),
      bottomNavigationBar: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: ElevatedButton(
                onPressed: () => controller.updateBankAccount(userId: userId, userType: userType),
                child: const Text('Update Bank Account')
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: controller.bankAccountFormKey,
            child: Column(
              children: [

                // Bank Name
                const SizedBox(height: AppSizes.inputFieldSpace),
                TextFormField(
                    controller: controller.bankName,
                    validator: (value) => Validator.validateEmptyText(fieldName: 'Bank Name', value: value),
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Bank Name*')
                ),

                // Account Number
                const SizedBox(height: AppSizes.inputFieldSpace),
                TextFormField(
                    controller: controller.accountNumber,
                    validator: (value) => Validator.validateEmptyText(fieldName: 'Account Number', value: value),
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Account Number*')
                ),

                // IFSC Code
                const SizedBox(height: AppSizes.inputFieldSpace),
                TextFormField(
                    controller: controller.ifscCode,
                    validator: (value) => Validator.validateEmptyText(fieldName: 'IFSC Code', value: value),
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'IFSC Code*')
                ),

                // Swift Code
                const SizedBox(height: AppSizes.inputFieldSpace),
                TextFormField(
                    controller: controller.swiftCode,
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Swift Code')
                ),

                const SizedBox(height: AppSizes.spaceBtwItems),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
