import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../controllers/login_controller/login_controller.dart';
import '../create_account/signup.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/validators/validation.dart';
import '../social_login/social_buttons.dart';
import 'forget_password.dart';

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(LoginController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const AppAppBar(title: "Login", showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWidthAppbarHeight,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //login, Title, Subtitle
                Column(
                  children: [
                    Text(AppTexts.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: AppSizes.sm),
                    Text(AppTexts.loginSubTitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center)
                  ],
                ),
                const SizedBox(height: AppSizes.spaceBtwSection),
                //Form Field
                Form(
                  key: controller.loginFormKey,
                    child: Column(
                        children: [
                          //Email
                          TextFormField(
                            controller: controller.email,
                            validator: (value) => Validator.validateEmail(value),
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Iconsax.direct_right),
                                labelText: AppTexts.email,
                            )
                          ),
                          //Password
                          const SizedBox(height: AppSizes.inputFieldSpace),
                          Obx(
                                () => TextFormField(
                                  controller: controller.password,
                                  validator: (value) => Validator.validateEmptyText(fieldName: 'Password',value: value),
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
                          const SizedBox(height: AppSizes.inputFieldSpace / 2),
                          //forget password and remember me
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Obx(() => Checkbox(
                                          value: controller.rememberMe.value,
                                          onChanged: (value) => controller.rememberMe.value = !controller.rememberMe.value,
                                      ),
                                    ),
                                    const Text(AppTexts.rememberMe),
                                  ],
                                ),
                                TextButton(
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ForgetPasswordScreen(email: controller.email.text.trim(),))
                                      );},
                                    child: Text(AppTexts.forgotPassword, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: AppColors.linkColor))
                                )
                              ]
                          ),

                          //Login button
                          const SizedBox(height: AppSizes.spaceBtwSection),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: const Text(AppTexts.login),
                              onPressed: () => controller.mongoLogin(),
                            ),
                          ),
                        ]
                    )
                ),

                //Not a Member?  Divider
                const SizedBox(height: AppSizes.spaceBtwSection),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(
                        thickness: 0.5,
                        color: dark ? Colors.grey[300] : Colors.grey[700],
                      )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(AppTexts.orSignInWith.capitalize!, style: Theme.of(context).textTheme.labelMedium),
                      ),
                      Expanded(child: Divider(
                        thickness: 0.5,
                        color: dark ? Colors.grey[300] : Colors.grey[700],
                      )),
                    ],
                  ),
                ),

                //Social Login
                const SizedBox(height: AppSizes.spaceBtwSection),
                const TSocialButtons(),
              ],
            ),
        ),
      ),
    );
  }
}

