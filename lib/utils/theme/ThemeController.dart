import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/local_storage_constants.dart';

class ThemeController extends GetxController {
  Rx<ThemeMode> themeMode = ThemeMode.system.obs; // Default to system theme
  final localStorage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadTheme(); // Load theme when controller is initialized
  }

  void loadTheme() {
    int? savedThemeIndex = localStorage.read<int>(LocalStorageName.themeMode);
    if (savedThemeIndex != null) {
      themeMode.value = ThemeMode.values[savedThemeIndex];
      Get.changeThemeMode(themeMode.value); // Apply stored theme
    }
  }

  void toggleTheme(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode); // Apply theme instantly
    localStorage.write(LocalStorageName.themeMode, mode.index); // Store theme in local storage
  }
}
