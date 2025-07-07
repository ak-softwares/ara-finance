import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../features/accounts/screen/search/search/search.dart';
import '../../features/authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../features/settings/app_settings.dart';
import '../../features/settings/screen/setting_screen.dart';
import '../../utils/constants/enums.dart';
import '../../utils/constants/icons.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/device/device_utility.dart';
import '../../utils/helpers/navigation_helper.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget{
  const AppAppBar({
    super.key,
    this.title = '',
    this.isShowLogo = false,
    this.showBackArrow = false,
    this.seeLogoutButton = false,
    this.seeSettingButton = false,
    this.widgetInActions,
    this.bottom,
    this.toolbarHeight,
    this.showSearchIcon = false,
    this.searchType,
    this.voucherType,
  });

  final String title;
  final bool showBackArrow;
  final bool isShowLogo;
  final bool seeLogoutButton;
  final bool seeSettingButton;
  final Widget? widgetInActions; // Nullable search type
  final PreferredSizeWidget? bottom; // Nullable search type
  final double? toolbarHeight; // Nullable search type
  final bool showSearchIcon;
  final SearchType? searchType;
  final AccountVoucherType? voucherType; // Nullable search type

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      title: isShowLogo
          ? Image(image: AssetImage(isDark ? AppSettings.darkAppLogo : AppSettings.lightAppLogo), height: 34)
          : Text(title),
      actions: [
        if(showSearchIcon)
        IconButton(
            icon: Icon(AppIcons.search),
            onPressed: () => showSearch(context: context,
                delegate: SearchVoucher(searchType: searchType!, voucherType: voucherType)
            )
        ),
        if(seeLogoutButton) ...[
          Obx(() => AuthenticationController.instance.isAdminLogin.value
              ? InkWell(
                    onTap: () => AuthenticationController.instance.logout(),
                    child: Row(
                      children: [
                        Text('Logout'),
                        const SizedBox(width: AppSizes.sm),
                        Icon(AppIcons.logout, size: 20,),
                        const SizedBox(width: AppSizes.sm),
                      ],
                    )
                )
              : InkWell(
                    onTap: () => NavigationHelper.navigateToLoginScreen(),
                    child: Row(
                      children: [
                        Icon(Iconsax.user),
                        const SizedBox(width: AppSizes.sm),
                        Text('Login', style: TextStyle(fontSize: 15),),
                        const SizedBox(width: AppSizes.md),
                      ],
                    )
                )
          ),
        ],
        seeSettingButton ? IconButton( icon: Icon(Icons.settings), onPressed: () => Get.to(() => SettingScreen())) : const SizedBox.shrink(),
        widgetInActions != null
            ? widgetInActions!
            : SizedBox.shrink()
      ],
      leading: showBackArrow ? IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Iconsax.arrow_left)) :  null,
      bottom: bottom,
      // toolbarHeight: toolbarHeight,
    );
  }
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight() + (toolbarHeight ?? 0));
}