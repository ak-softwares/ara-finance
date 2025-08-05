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
    final auth = Get.put(AuthenticationController());
    return Scaffold(
        appBar: const AppAppBar(title: 'Profile Setting', seeLogoutButton: true, seeSettingButton: true,),
        body: RefreshIndicator(
                color: AppColors.refreshIndicator,
                onRefresh: () async => await auth.refreshAdmin(),
                child: ListView(
                  children: [
                    // User profile
                    const CustomerProfileCard(),

                    // Menu
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
      );
  }
}

class CustomerProfileCard extends StatelessWidget {
  const CustomerProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.put(AuthenticationController());
    return Obx(() => ListTile(
      onTap: () => Get.to(() => const UserProfileInfo()),
      leading: RoundedImage(
        padding: 0,
        height: 40,
        width: 40,
        borderRadius: 100,
        isNetworkImage: auth.admin.value.avatarUrl != null ? true : false,
        image: auth.admin.value.avatarUrl ?? Images.tProfileImage
      ),
      title: Text(auth.admin.value.name ?? 'User'),
      subtitle: Text(auth.admin.value.email ?? 'Email',),
      trailing: Icon(Icons.arrow_forward_ios, size: 20),
    ),
    );
  }

}






