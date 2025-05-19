import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../change_profile/change_user_profile.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AuthenticationController());

    return Scaffold(
      appBar: const AppAppBar(title: 'Profile Setting', showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          ///- user image
          child: Column(
            children: [
              const SizedBox(height: AppSizes.spaceBtwSection),
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
              const SizedBox(height: AppSizes.spaceBtwSection),
              const Divider(),
              const SizedBox(height: AppSizes.spaceBtwItems),
              const TSectionHeading(title: 'Profile Information', seeActionButton: false),
              const SizedBox(height: AppSizes.spaceBtwItems),
              Obx(() {
                if(controller.isLoading.value){
                  return const Center(child: CircularProgressIndicator(color: AppColors.linkColor),);
                } else {
                  return Column(
                    children: [
                      TProfileMenu(
                          title: 'Name',
                          value: controller.admin.value.name ?? 'Name',
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeUserProfile()));}
                      ),
                      Divider(color: Colors.grey[200]),
                      TProfileMenu(
                          title: 'Email',
                          value: controller.admin.value.email ?? "Email",
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeUserProfile()));}),
                      Divider(color: Colors.grey[200]),
                      TProfileMenu(
                          title: 'Phone',
                          value: controller.admin.value.phone ?? 'Phone',
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeUserProfile()));}),
                      const Divider(),
                      Center(
                        child: TextButton(
                            child: const Text('Delete Account', style: TextStyle(color: Colors.red),),
                            onPressed: () => controller.showDialogDeleteAccount(context: context)
                        )
                      )
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class TProfileMenu extends StatelessWidget {
  const TProfileMenu({
    super.key, required this.title, required this.value, required this.onTap, this.icon = Iconsax.arrow_right_34,
  });
  final String title, value;
  final void Function() onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceBtwItems),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(title, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
            Expanded(flex: 5, child: Text(value, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
            Expanded(child: Icon(icon, size: 18,)),
          ],
        ),
      ),
    );
  }
}
