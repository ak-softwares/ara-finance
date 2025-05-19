import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';
import '../../../personalization/models/user_model.dart';
import '../../controller/customer/add_customer_controller.dart';

class AddCustomer extends StatelessWidget {
  const AddCustomer({super.key, this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final AddCustomerController controller = Get.put(AddCustomerController());

    if (user != null) {
      controller.resetValue(user!);
    }

    return Scaffold(
      appBar: AppAppBar(
        title: user != null ? 'Update Customer' : 'Add Customer'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () => user != null
              ? controller.saveUpdatedCustomer(previousCustomer: user!)
              : controller.saveCustomer(),
          child: Text(user != null ? 'Update Customer' : 'Add Customer', style: TextStyle(fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: controller.customerFormKey,
            child: Column(
              spacing: AppSizes.spaceBtwItems,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customer ID'),
                    user != null
                        ? Text('#${user!.documentId}')
                        : Obx(() => Text('#${controller.customerId.value}')),
                  ],
                ),
                TextFormField(
                  controller: controller.nameController,
                  validator: (value) => Validator.validateEmptyText(fieldName: 'Customer Name', value: value),
                  decoration: InputDecoration(
                    labelText: 'Customer Name*',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
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
