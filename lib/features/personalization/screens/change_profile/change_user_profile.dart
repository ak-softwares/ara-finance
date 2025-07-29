import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/change_profile_controller.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';


class ChangeUserProfile extends StatelessWidget {
  const ChangeUserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangeProfileController());
    return Scaffold(
      appBar: const AppAppBar(title: "Update Profile", showBackArrow: true),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ElevatedButton(
          child: const Text('Update'),
          onPressed: () => controller.mongoChangeProfileDetails(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.defaultPagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                  key: controller.changeProfileFormKey,
                  child: Column(
                      spacing: AppSizes.inputFieldSpace,
                      children: [
                        // Name
                        TextFormField(
                          controller: controller.name,
                          validator: (value) => Validator.validateEmptyText(fieldName: 'Full Name',value: value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: 'Full Name*'),
                        ),

                        // email
                        TextFormField(
                            controller: controller.email,
                            validator: (value) => Validator.validateEmail(value),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Iconsax.direct_right),
                              labelText: AppTexts.tEmail,
                            )
                        ),

                        // phone
                        TextFormField(
                            controller: controller.phone,
                            validator: (value) => Validator.validatePhoneNumber(value),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Iconsax.call),
                              labelText: AppTexts.tPhone,
                            )
                        ),

                        // Company
                        TextFormField(
                          controller: controller.companyName,
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.shop), labelText: 'Company'),
                        ),

                        // Gst
                        TextFormField(
                          controller: controller.gstNumber,
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.direct_right), labelText: 'GST Number'),
                        ),

                        // Pan
                        TextFormField(
                          controller: controller.panNumber,
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.card), labelText: 'PAN Number'),
                        ),
                      ]
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

