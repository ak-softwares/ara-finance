import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';
import '../../../personalization/models/user_model.dart';
import '../../controller/vendor/add_vendor_controller.dart';

class AddVendorPage extends StatelessWidget {

  const AddVendorPage({super.key, this.vendor});

  final UserModel? vendor;

  @override
  Widget build(BuildContext context) {
    final AddVendorController controller = Get.put(AddVendorController());

    if( vendor != null) {
      controller.resetValue(vendor!);
    }

    return Scaffold(
      appBar: AppAppBar(title: vendor != null ? 'Update Vendor' : 'Add Vendor'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () => vendor != null ? controller.saveUpdatedVendor(previousVendor: vendor!) : controller.saveVendor(),
          child: Text(vendor != null ? 'Update Vendor' : 'Add Vendor', style: TextStyle(fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: controller.vendorFormKey,
            child: Column(
              spacing: AppSizes.spaceBtwItems,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vendor id'),
                    vendor != null
                        ? Text('#${vendor!.documentId}')
                        : Obx(() => Text('#${controller.vendorId.value}')),
                  ],
                ),
                TextFormField(
                  controller: controller.companyController,
                  validator: (value) => Validator.validateEmptyText(fieldName: 'Company Name',value: value),
                  decoration: InputDecoration(
                    labelText: 'Company Name*',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Representative Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.gstNumberController,
                  decoration: InputDecoration(
                    labelText: 'GST Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: controller.balanceController,
                  decoration: InputDecoration(
                    labelText: 'Balance',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: controller.phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.address1Controller,
                  decoration: InputDecoration(
                    labelText: 'Address 1',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.address2Controller,
                  decoration: InputDecoration(
                    labelText: 'Address 2',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.pincodeController,
                  decoration: InputDecoration(
                    labelText: 'Pincode',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: controller.countryController,
                  decoration: InputDecoration(
                    labelText: 'Country',
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
