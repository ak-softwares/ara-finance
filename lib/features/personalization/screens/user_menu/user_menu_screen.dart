import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../common/widgets/shimmers/user_shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/screens/check_login_screen/check_login_screen.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../settings/app_settings.dart';
import '../user_profile/user_profile.dart';
import 'widgets/contact_widget.dart';
import 'widgets/menu.dart';

class UserMenuScreen extends StatelessWidget {
  const UserMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final userController = Get.put(AuthenticationController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.refreshAdmin();
    });

    return  Obx(() => Scaffold(
        appBar: const AppAppBar(title: 'Profile Setting', seeLogoutButton: true, seeSettingButton: true,),
        body: !userController.isAdminLogin.value
            ? const CheckLoginScreen()
            : RefreshIndicator(
                color: AppColors.refreshIndicator,
                onRefresh: () async => userController.refreshAdmin(),
                child: SingleChildScrollView(
                  padding: AppSpacingStyle.defaultPageVertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //User profile
                      Heading(title: 'Your profile', paddingLeft: AppSizes.defaultSpace),
                      CustomerProfileCard(userController: userController, showHeading: true),

                      //Menu
                      Heading(title: 'Menu', paddingLeft: AppSizes.defaultSpace),
                      const Menu(),

                      // Contacts
                      SupportWidget(),

                      // Version
                      Center(
                        child: Column(
                          children: [
                            Text('Accounts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                            Text('v${AppSettings.appVersion}', style: TextStyle(fontSize: 12),)
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                  ),
                ),
            ),
      ),
    );
  }
}

class CustomerProfileCard extends StatelessWidget {
  const CustomerProfileCard({
    super.key,
    required this.userController, this.showHeading = false,
  });

  final bool showHeading;
  final AuthenticationController userController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if(userController.isLoading.value) {
            return const UserTileShimmer();
          } else {
             return ListTile(
               onTap: () => Get.to(() => const UserProfileScreen()),
                leading: RoundedImage(
                  padding: 0,
                  height: 40,
                  width: 40,
                  borderRadius: 100,
                  isNetworkImage: userController.admin.value.avatarUrl != null ? true : false,
                  image: userController.admin.value.avatarUrl ?? Images.tProfileImage
                ),
                title: Text((userController.admin.value.name?.isNotEmpty ?? false) ? userController.admin.value.name! : "User",),
                subtitle: Text(userController.admin.value.email?.isNotEmpty ?? false ? userController.admin.value.email! : 'Email',),
                trailing: Icon(Icons.arrow_forward_ios, size: 20,),
             );
          }
        }),
      ],
    );
  }

}






