import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/general_bindings.dart';
import 'common/navigation_bar/bottom_navigation_bar.dart';
import 'data/database/mongodb/mongo_base.dart';
import 'features/authentication/controllers/authentication_controller/authentication_controller.dart';
import 'features/authentication/screens/phone_otp_login/mobile_login_screen.dart';
import 'features/settings/app_settings.dart';
import 'firebase_options.dart';
import 'utils/theme/ThemeController.dart';
import 'utils/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize only Firebase here (required before runApp if used)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await MongoDatabase.connect();
  await AppSettings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());
    // Initialize your auth controller
    final auth = Get.put(AuthenticationController());
    final isAdmin = auth.isAdminLogin.value;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppSettings.appName,
      theme: AppAppTheme.lightTheme,
      darkTheme: AppAppTheme.darkTheme,
      themeMode: themeController.themeMode.value,
      initialBinding: GeneralBindings(),
      home: isAdmin ? const BottomNavigation() : const MobileLoginScreen(), // Splash/Initializer screen
    );
  }
}
