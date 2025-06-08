import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../../features/settings/app_settings.dart';
import '../constants/colors.dart';
import 'custom_theme/appbar_theme.dart';
import 'custom_theme/bottom_sheet_theme.dart';
import 'custom_theme/checkbox_theme.dart';
import 'custom_theme/chip_theme.dart';
import 'custom_theme/elevated_button_theme.dart';
import 'custom_theme/icon_theme.dart';
import 'custom_theme/list_tile_theme.dart';
import 'custom_theme/outlined_button_theme.dart';
import 'custom_theme/switch_theme.dart';
import 'custom_theme/tapbar_theme.dart';
import 'custom_theme/text_field_theme.dart';
import 'custom_theme/text_selection_theme.dart';
import 'custom_theme/text_theme.dart';

class AppAppTheme {
  AppAppTheme._();

  // Theme.of(context).colorScheme.surface
  static ThemeData lightTheme = FlexThemeData.light(
    scheme: FlexScheme.blueM3,
  ).copyWith(
    appBarTheme: AppAppBarTheme.lightAppBarTheme,
    // tabBarTheme: AppTabBarTheme.lightTabBarTheme,
    iconTheme: AppIconTheme.lightIconTheme,
    listTileTheme: AppListTileTheme.lightListTileTheme,
    bottomSheetTheme: AppBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.lightOutlinedButtonTheme,
    checkboxTheme: AppCheckBoxTheme.lightCheckBoxTheme,
    switchTheme: AppSwitchTheme.lightSwitchTheme,
    inputDecorationTheme: AppTextFormFieldTheme.lightInputDecorationTheme,
    textSelectionTheme: AppTextSelectionTheme.lightTextSelectionTheme,
    colorScheme: ThemeData.light().colorScheme.copyWith(
      surface: AppColors.backgroundLight, // Background for cards, dialogs, etc.
      onSurface: AppColors.textLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight, // Softer text color for better contrast
    ),
    // scaffoldBackgroundColor: AppSettings.lightBackground, // Ensures the scaffold uses the new background
  );

  static ThemeData darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.blueM3,
  ).copyWith(
    appBarTheme: AppAppBarTheme.darkAppBarTheme,
    // tabBarTheme: AppTabBarTheme.darkTabBarTheme,
    iconTheme: AppIconTheme.darkIconTheme,
    listTileTheme: AppListTileTheme.darkListTileTheme,
    bottomSheetTheme: AppBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AppOutlinedButtonTheme.darkOutlinedButtonTheme,
    checkboxTheme: AppCheckBoxTheme.darkCheckBoxTheme,
    switchTheme: AppSwitchTheme.darkSwitchTheme,
    inputDecorationTheme: AppTextFormFieldTheme.darkInputDecorationTheme,
    textSelectionTheme: AppTextSelectionTheme.darkTextSelectionTheme,
    colorScheme: ThemeData.dark().colorScheme.copyWith(
      surface: AppColors.backgroundDark, // Background for cards, dialogs, etc.
      onSurface: AppColors.textDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark, // Softer text color for better contrast
    ),
    scaffoldBackgroundColor: AppSettings.darkBackground, // Ensures the scaffold uses the new background
  );
}