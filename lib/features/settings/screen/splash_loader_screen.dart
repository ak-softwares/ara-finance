import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../common/navigation_bar/bottom_navigation_bar.dart';
import '../../../data/database/mongodb/mongo_base.dart';
import '../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../authentication/screens/phone_otp_login/mobile_login_screen.dart';
import '../app_settings.dart';

class SplashLoaderScreen extends StatelessWidget {
  const SplashLoaderScreen({super.key});

  Future<Widget> _initializeApp() async {
    try {
      await dotenv.load(fileName: ".env");
      await GetStorage.init();
      await MongoDatabase.connect();
      await AppSettings.init();

      // Initialize your auth controller
      final auth = Get.put(AuthenticationController());
      final isAdmin = auth.isAdminLogin.value;
      await auth.initializeEcommercePlatformCredentials();
      return isAdmin ? const BottomNavigation() : const MobileLoginScreen();
    } catch (e) {
      return const ErrorScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data!;
        } else {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2,)),
                  SizedBox(height: 10),
                  Text("Loading, please wait..."),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Oops! Something went wrong during startup."),
      ),
    );
  }
}
