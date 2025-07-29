import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/data/state_iso_code_map.dart';
import '../../../../utils/validators/validation.dart';
import '../../../accounts/models/transaction_model.dart';
import '../../controllers/address_controller.dart';
import '../../models/address_model.dart';
import '../change_profile/change_user_profile.dart';

class UpdateTransactionAddress extends StatelessWidget {
  const UpdateTransactionAddress({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AddressController());
    controller.initializedInPutField(address: transaction.address ?? AddressModel());

    return Scaffold(
      appBar: AppAppBar(title: 'Update Address'),
      bottomNavigationBar: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: ElevatedButton(
              onPressed: () => controller.saveUpdateTransactionAddress(transactionId: transaction.id ?? ''),
              child: const Text('Update Address')
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: controller.addressFormKey,
            child: Column(
              spacing: AppSizes.inputFieldSpace,
              children: [
                // Name
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                          controller: controller.firstName,
                          validator: (value) => Validator.validateEmptyText(fieldName: 'First Name',value: value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: 'First Name*'),
                        )
                    ),
                    const SizedBox(width: AppSizes.inputFieldSpace),
                    // Last Name
                    Expanded(
                        child: TextFormField(
                            controller: controller.lastName,
                            decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user4), labelText: 'Last name')
                        )
                    ),
                  ],
                ),

                // Phone
                TextFormField(
                    controller: controller.phone,
                    validator: (value) => Validator.validateEmptyText(fieldName: 'Phone Number', value: value),
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Phone Number')
                ),

                // Email
                TextFormField(
                    controller: controller.email,
                    validator: (value) => Validator.validateEmptyText(fieldName: 'Email address', value: value),
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Email Address')
                ),

                // Address1
                TextFormField(
                    controller: controller.address1,
                    validator: (value) => Validator.validateEmptyText(fieldName: 'Street address', value: value),
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Street Address*')
                ),

                // Address2
                TextFormField(
                    controller: controller.address2,
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.buildings), labelText: 'Land Mark')
                ),

                // City
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                          controller: controller.city,
                          validator: (value) => Validator.validateEmptyText(fieldName: 'City', value: value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'City*'),
                        )
                    ),
                    const SizedBox(width: AppSizes.inputFieldSpace),
                    // Pincode
                    Expanded(
                        child: TextFormField(
                          controller: controller.pincode,
                          validator: (value) => Validator.validatePinCode(value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.code), labelText: 'Pincode*')
                        )
                    ),
                  ],
                ),

                // State
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  items: StateData.indianStates.map((state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  value: StateData.indianStates.contains(controller.state.text) ? controller.state.text : null,
                  onChanged: (value) => controller.state.text = value!,
                  validator: (value) => Validator.validateEmptyText(fieldName: 'State', value: value),
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.activity), labelText: 'State*'),
                ),

                // Country
                TextFormField(
                    enabled: false,
                    controller: controller.country,
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.buildings), labelText: 'Country*')
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Is this company'),
                    Obx(() => Checkbox(
                        value: controller.isCompany.value,
                        onChanged: (value) {
                          controller.isCompany.value = value!;
                        },
                      ),
                    )
                  ],
                ),

                Obx(() {
                  if(controller.isCompany.value) {
                    return Column(
                      children: [
                        // Company Name
                        const SizedBox(height: AppSizes.inputFieldSpace),
                        TextFormField(
                            controller: controller.companyName,
                            validator: (value) => Validator.validateEmptyText(fieldName: 'Company Name', value: value),
                            decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Company Name*')
                        ),

                        // Gst Number
                        const SizedBox(height: AppSizes.inputFieldSpace),
                        TextFormField(
                            controller: controller.gstNumber,
                            validator: (value) => Validator.validateEmptyText(fieldName: 'GST Number', value: value),
                            decoration: const InputDecoration(prefixIcon: Icon(Iconsax.buildings), labelText: 'GST Number*')
                        ),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
