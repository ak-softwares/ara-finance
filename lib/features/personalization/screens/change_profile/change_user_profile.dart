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

    final changeProfileController = Get.put(ChangeProfileController());
    final userController = Get.put(AuthenticationController());
    changeProfileController.fullName.text = userController.admin.value.name ?? '';
    changeProfileController.email.text = userController.admin.value.email ?? '';
    changeProfileController.phone.text = Validator.getFormattedTenDigitNumber(userController.admin.value.phone ?? '') ?? '';

    return Scaffold(
      appBar: const AppAppBar(title: "Update Profile", showBackArrow: true),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => userController.refreshAdmin(),
        child: SingleChildScrollView(
          child: Padding(
            padding: AppSpacingStyle.paddingWidthAppbarHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Form(
                    key: changeProfileController.changeProfileFormKey,
                    child: Column(
                        children: [
                          const SizedBox(height: AppSizes.spaceBtwSection),
                          //Name
                          TextFormField(
                            controller: changeProfileController.fullName,
                            validator: (value) => Validator.validateEmptyText(fieldName: 'Full Name',value: value),
                            decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: 'First Name*'),
                          ),
                          const SizedBox(height: AppSizes.inputFieldSpace),
                          //email
                          TextFormField(
                              controller: changeProfileController.email,
                              validator: (value) => Validator.validateEmail(value),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.direct_right),
                                labelText: AppTexts.tEmail,
                              )
                          ),
                          const SizedBox(height: AppSizes.inputFieldSpace),
                          // phone
                          TextFormField(
                              controller: changeProfileController.phone,
                              validator: (value) => Validator.validatePhoneNumber(value),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.call),
                                labelText: AppTexts.tPhone,
                              )
                          ),
                          const SizedBox(height: AppSizes.spaceBtwSection),
                          // save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: const Text('Update'),
                              onPressed: () => changeProfileController.mongoChangeProfileDetails(),
                            ),
                          ),
                        ]
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

