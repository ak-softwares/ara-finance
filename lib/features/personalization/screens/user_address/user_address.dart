import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../models/address_model.dart';
import 'update_user_address.dart';
import 'address_widgets/single_address.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

@override
Widget build(BuildContext context) {

  final userController = Get.put(AuthenticationController());

  return Scaffold(
    appBar: const AppAppBar(title: "Address", showBackArrow: true),
    body: !userController.isAdminLogin.value
      ? const CheckLoginScreen()
      : Obx(() => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            children: [
              const SectionHeading(title: 'Billing Address'),
              SingleAddress(
                  address: userController.admin.value.billing ?? AddressModel.empty(),
                  onTap: () => Get.to(() => UpdateAddressScreen(
                      address: userController.admin.value.billing ?? AddressModel.empty()
                    )),
                // onTap: () => controller.selectAddress(addresses[index])
              ),
              // const SizedBox(height: TSizes.spaceBtwInputFields),
              // const TSectionHeading(title: 'Shipping Address'),
              // TSingleAddress(
              //     address: userController.customer.value.shipping ?? AddressModel.empty(),
              //     onTap: () => Get.to(() => UpdateAddressScreen(
              //         title: 'Update Shipping Address',
              //         isShippingAddress: true,
              //         address: userController.customer.value.shipping ?? AddressModel.empty(),
              //     )),
              //     hidePhone: true
              //   // onTap: () => controller.selectAddress(addresses[index])
              // )
            ],
          ),
        ),
      ),
    );
  }
}

