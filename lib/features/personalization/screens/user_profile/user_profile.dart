import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../setup/screens/platform_selection_screen.dart';
import '../../models/address_model.dart';
import '../../models/bank_account.dart';
import '../bank_account/bank_account_card.dart';
import '../bank_account/update_bank_account.dart';
import '../change_profile/change_user_profile.dart';
import '../user_address/address_widgets/single_address.dart';
import '../user_address/update_user_address.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AuthenticationController());

    return Scaffold(
      appBar: AppAppBar(
        title: 'Profile Setting',
        widgetInActions: TextButton(
            onPressed: () => Get.to(() => ChangeUserProfile()),
            child: const Row(
              spacing: AppSizes.sm,
              children: [
                Text('Edit', style: TextStyle(color: AppColors.linkColor),),
                Icon(Icons.edit, size: 18, color: AppColors.linkColor,)
              ],
            ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => controller.refreshAdmin(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              spacing: AppSizes.spaceBtwSection,
              children: [
                // Image
                Stack(
                  children: [
                    RoundedImage(
                        height: 100,
                        width: 100,
                        isNetworkImage: controller.admin.value.avatarUrl != null ? true : false,
                        image: controller.admin.value.avatarUrl ?? Images.tProfileImage
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                            borderRadius : BorderRadius.circular(100),
                            color: Colors.yellow// tAccentColor.withOpacity(0.1)
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Iconsax.edit_2, size: 16, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),

                // Profile Info
                Column(
                  children: [
                    const Divider(),
                    const SectionHeading(title: 'Profile Information', seeActionButton: false),
                    TProfileMenu(
                      title: 'Name',
                      value: controller.admin.value.name ?? 'Name',
                    ),
                    Divider(color: Colors.grey[200]),
                    TProfileMenu(
                      title: 'Email',
                      value: controller.admin.value.email ?? "Email",
                    ),
                    Divider(color: Colors.grey[200]),
                    TProfileMenu(
                      title: 'Phone',
                      value: controller.admin.value.phone ?? 'Phone',
                    ),
                    Divider(color: Colors.grey[200]),
                    TProfileMenu(
                      title: 'Company',
                      value: controller.admin.value.companyName ?? 'Company',
                    ),
                    Divider(color: Colors.grey[200]),
                    TProfileMenu(
                      title: 'GST Number',
                      value: controller.admin.value.gstNumber ?? 'GST',
                    ),
                    Divider(color: Colors.grey[200]),
                    TProfileMenu(
                      title: 'PAN Number',
                      value: controller.admin.value.panNumber ?? 'PAN Number',
                    ),
                    const Divider(),
                  ],
                ),

                // Address
                Column(
                  children: [
                    const SectionHeading(title: 'Address', seeActionButton: false),
                    SingleAddress(
                      address: controller.admin.value.billing ?? AddressModel(),
                      onTap: () => Get.to(() => UpdateAddressScreen(
                          userId: controller.admin.value.id ?? '',
                          userType: UserType.admin,
                          address: controller.admin.value.billing ?? AddressModel()
                      )),
                      // onTap: () => controller.selectAddress(addresses[index])
                    ),
                  ],
                ),

                // Bank Account
                Column(
                  children: [
                    const SectionHeading(title: 'Bank Account', seeActionButton: false),
                    BankAccountCard(
                      bankAccount: controller.admin.value.bankAccount ?? BankAccountModel(),
                      onTap: () => Get.to(() => UpdateBankAccount(
                          userId: controller.admin.value.id ?? '',
                          userType: UserType.admin,
                          bankAccount: controller.admin.value.bankAccount ?? BankAccountModel()
                      )),
                      // onTap: () => controller.selectAddress(addresses[index])
                    ),
                  ],
                ),

                // Select Platform
                Column(
                  children: [
                    const SectionHeading(title: 'Selected Platform', seeActionButton: false),
                    InkWell(
                      onTap: () => Get.to(() => PlatformSelectionScreen()),
                      child: Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.surface,
                        padding: AppSpacingStyle.defaultPagePadding,
                        child: Text(controller.admin.value.ecommercePlatform?.name ?? 'Platform', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis)
                      ),
                    ),
                  ],
                ),

                // // Select Account
                // Column(
                //   children: [
                //     const SectionHeading(title: 'Selected Account', seeActionButton: false),
                //     InkWell(
                //       onTap: () => Get.to(() => Accounts()),
                //       child: Container(
                //           width: double.infinity,
                //           color: Theme.of(context).colorScheme.surface,
                //           padding: AppSpacingStyle.defaultPagePadding,
                //           child: Text(controller.admin.value.selectedAccount?.accountName ?? 'Select Account for payment received', style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis)
                //       ),
                //     ),
                //   ],
                // ),

                // Delete
                Center(
                    child: TextButton(
                        child: const Text('Delete Account', style: TextStyle(color: Colors.red),),
                        onPressed: () => controller.showDialogDeleteAccount(context: context)
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TProfileMenu extends StatelessWidget {
  const TProfileMenu({super.key, required this.title, required this.value,});
  final String title, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceBtwItems),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(title, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 5, child: Text(value, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
