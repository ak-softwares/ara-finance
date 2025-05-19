import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/validators/validation.dart';
import '../../controllers/create_account_controller/signup_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const AppAppBar(title: "Signup", showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWidthAppbarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //SignUp , Title, Subtitle
              Text("Let's Create Your Account", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSizes.spaceBtwSection),
              //Form Field
              Form(
                  key: controller.signupFormKey,
                  child: Column(
                      children: [
                        //Name
                        TextFormField(
                          controller: controller.fullName,
                          validator: (value) => Validator.validateEmptyText(fieldName: AppTexts.firstName, value: value),
                          decoration: const InputDecoration(prefixIcon: Icon(Iconsax.user), labelText: AppTexts.firstName),
                        ),
                        const SizedBox(height: AppSizes.inputFieldSpace),
                        //Email
                        TextFormField(
                            controller: controller.email,
                            validator: (value) => Validator.validateEmail(value),
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.direct_right),
                                labelText: AppTexts.email
                            )
                        ),
                        //Password
                        const SizedBox(height: AppSizes.inputFieldSpace),
                        Obx(
                            () => TextFormField(
                              controller: controller.password,
                              validator: (value) => Validator.validatePassword(value),
                              obscureText: controller.hidePassword.value,
                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Iconsax.password_check),
                                  labelText: AppTexts.password,
                                  suffixIcon: IconButton(
                                    onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                                    icon: controller.hidePassword.value ? const Icon(Iconsax.eye_slash) : const Icon(Iconsax.eye),
                                  )
                              )
                        )),
                        // phone
                        const SizedBox(height: AppSizes.inputFieldSpace),
                        TextFormField(
                            controller: controller.phone,
                            validator: (value) => Validator.validatePhoneNumber(value),
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.call),
                                labelText: AppTexts.phone
                            )
                        ),

                        //terms and conditions
                        const SizedBox(height: AppSizes.spaceBtwSection),

                        // signup button
                        const SizedBox(height: AppSizes.inputFieldSpace),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            child: const Text('Create Account'),
                            onPressed: () => controller.signupWithEmailPassword(),
                          ),
                        ),
                      ]
                  )
              ),

              // //already a Member? Divider
              // const SizedBox(height: TSizes.spaceBtwSection),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
              //   child: Row(
              //     children: [
              //       Expanded(child: Divider(
              //         thickness: 0.5,
              //         color: dark ? Colors.grey[300] : Colors.grey[700],
              //       )),
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //         child: Text(TTexts.orSignUpWith.capitalize!, style: Theme.of(context).textTheme.labelMedium),
              //       ),
              //       Expanded(child: Divider(
              //         thickness: 0.5,
              //         color: dark ? Colors.grey[300] : Colors.grey[700],
              //       )),
              //     ],
              //   ),
              // ),
              //
              // //Social Login
              // const SizedBox(height: TSizes.spaceBtwSection),
              // const TSocialButtons(),
              //
              //
              // const SizedBox(height: TSizes.spaceBtwSection),

              // already a Member? Login
              // Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text('Already a member?', style: TextStyle(color: Colors.grey[700])),
              //       TextButton(
              //           onPressed: () => Get.to(const LoginScreen()),
              //           child: Text('Login', style: Theme.of(context).textTheme.displayMedium)
              //       )
              //     ]
              // )
            ],
          ),
        ),
      ),
    );
  }
}
