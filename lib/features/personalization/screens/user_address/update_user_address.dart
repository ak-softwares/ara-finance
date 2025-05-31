import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/data/state_iso_code_map.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/address_controller.dart';
import '../../models/address_model.dart';
import '../change_profile/change_user_profile.dart';

class UpdateAddressScreen extends StatelessWidget {
  const UpdateAddressScreen({super.key,required this.address, required this.userId, required this.userType,});

  final String userId;
  final UserType userType;
  final AddressModel address;

  @override
  Widget build(BuildContext context) {

    final addressController = Get.put(AddressController());
    addressController.initializedInPutField(address: address);

    return Scaffold(
      appBar: AppAppBar(title: 'Update Address'),
      bottomNavigationBar: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: ElevatedButton(
                onPressed: () => addressController.updateAddress(userId: userId, userType: userType),
                child: const Text('Update Address')
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: addressController.addressFormKey,
            child: Column(
              children: [

                // Name
                const SizedBox(height: AppSizes.inputFieldSpace),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                          controller: addressController.firstName,
                          validator: (value) => Validator.validateEmptyText(fieldName: 'First Name',value: value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: 'First Name*'),
                        )
                    ),
                    const SizedBox(width: AppSizes.inputFieldSpace),
                    // Last Name
                    Expanded(
                        child: TextFormField(
                            controller: addressController.lastName,
                            decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user4), labelText: 'Last name')
                        )
                    ),
                  ],
                ),

                // Address1
                const SizedBox(height: AppSizes.inputFieldSpace),
                TextFormField(
                    controller: addressController.address1,
                    validator: (value) => Validator.validateEmptyText(fieldName: 'Street address', value: value),
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'Street Address*')
                ),

                // Address2
                const SizedBox(height: AppSizes.inputFieldSpace),
                TextFormField(
                    controller: addressController.address2,
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.buildings), labelText: 'Land Mark')
                ),

                // City
                const SizedBox(height: AppSizes.inputFieldSpace),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                          controller: addressController.city,
                          validator: (value) => Validator.validateEmptyText(fieldName: 'City', value: value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.building), labelText: 'City*'),
                        )
                    ),
                    const SizedBox(width: AppSizes.inputFieldSpace),
                    // Pincode
                    Expanded(
                        child: TextFormField(
                          controller: addressController.pincode,
                          validator: (value) => Validator.validatePinCode(value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.code), labelText: 'Pincode*')
                        )
                    ),
                  ],
                ),

                // State
                const SizedBox(height: AppSizes.inputFieldSpace),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  items: StateData.indianStates.map((state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  value: addressController.state.text.isNotEmpty ? addressController.state.text : null,
                  onChanged: (value) {addressController.state.text = value!;},
                  validator: (value) => Validator.validateEmptyText(fieldName: 'State', value: value),
                  decoration: const InputDecoration(prefixIcon: Icon(Iconsax.activity), labelText: 'State*'),
                ),

                // Country
                const SizedBox(height: AppSizes.inputFieldSpace),
                TextFormField(
                    enabled: false,
                    controller: addressController.country,
                    decoration: const InputDecoration(prefixIcon: Icon(Iconsax.buildings), labelText: 'Country*')
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
