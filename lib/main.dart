import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/general_bindings.dart';
import 'features/settings/app_settings.dart';
import 'features/settings/screen/splash_loader_screen.dart';
import 'firebase_options.dart';
import 'utils/theme/ThemeController.dart';
import 'utils/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize only Firebase here (required before runApp if used)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppSettings.appName,
      theme: AppAppTheme.lightTheme,
      darkTheme: AppAppTheme.darkTheme,
      themeMode: themeController.themeMode.value,
      initialBinding: GeneralBindings(),
      home: const SplashLoaderScreen(), // Splash/Initializer screen
    );
  }
}
