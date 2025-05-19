import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../data/repositories/mongodb/authentication/authentication_repositories.dart';
import '../../../../data/repositories/woocommerce/customers/woo_customer_repository.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/local_storage_constants.dart';
import '../../../../utils/exceptions/firebase_auth_exceptions.dart';
import '../../../../utils/exceptions/format_exceptions.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import '../../../personalization/models/user_model.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController get instance => Get.find();

  RxBool isLoading = false.obs;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  RxBool isAdminLogin = false.obs;
  final int loginExpiryInDays = 30;

  final localStorage = GetStorage();
  Rx<UserModel> admin = UserModel.empty().obs;
  final _auth = FirebaseAuth.instance;


  final hidePassword = true.obs; //Observable for hiding/showing password
  final imageUploading = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  final mongoAuthenticationRepository = Get.put(MongoAuthenticationRepository());

  @override
  void onInit() {
    super.onInit();
    checkIsAdminLogin();
  }

  Future<void> initializeEcommercePlatformCredentials() async {
    try {
      if (admin.value.email == null || admin.value.email!.isEmpty) {
        final String localAuthUserToken = await fetchLocalAuthToken();
        final userData = await mongoAuthenticationRepository.fetchUserById(userId: localAuthUserToken);
        admin(userData);
      }

      if (admin.value.ecommercePlatform == EcommercePlatform.woocommerce) {
        APIConstant.initializeWooCommerceCredentials(user: admin.value);
      }
    } catch (e) {
      debugPrint('Failed to initialize platform credentials: $e');
    }
  }


  // Check if the user is logged in
  Future<void> checkIsAdminLogin() async {
    final String localAuthUserToken = await fetchLocalAuthToken();
    if (localAuthUserToken.isNotEmpty) {
      isAdminLogin.value = true;
      admin.value = UserModel(id: localAuthUserToken);
    }
  }

  Future<String> getUserId() async {
    final String localAuthUserToken = await fetchLocalAuthToken();
    if (localAuthUserToken.isNotEmpty) {
      return localAuthUserToken;
    } else{
      throw 'User not found';
    }
  }

  String get userId {
    if (!isAdminLogin.value || admin.value.id == null || admin.value.id!.isEmpty) {
      throw Exception("User not authenticated. Call `checkIsAdminLogin()` first.");
    }
    return admin.value.id!;
  }

  Future<String> fetchLocalAuthToken() async {
    final String? authToken = await secureStorage.read(key: LocalStorage.authUserID);
    final String? expiryString = await secureStorage.read(key: LocalStorage.loginExpiry);

    // Check if both values exist
    if (authToken == null || authToken.isEmpty || expiryString == null || expiryString.isEmpty) {
      return '';
    }

    // Parse expiry date
    final DateTime expiry = DateTime.tryParse(expiryString) ?? DateTime.fromMillisecondsSinceEpoch(0);

    // Check if current time is before expiry
    if (DateTime.now().isBefore(expiry)) {
      return authToken;
    } else {
      // Expired – clean up stored data
      await deleteLocalAuthToken();
      return '';
    }
  }

  Future<void> saveLocalAuthToken(String token) async {
    // Store user ID and login expiry
    final String expiry = DateTime.now().add(Duration(days: loginExpiryInDays)).toIso8601String();
    await secureStorage.write(key: LocalStorage.authUserID, value: token);
    await secureStorage.write(key: LocalStorage.loginExpiry, value: expiry);
  }

  Future<void> deleteLocalAuthToken() async {
    await secureStorage.delete(key: LocalStorage.authUserID);
    await secureStorage.delete(key: LocalStorage.loginExpiry);
  }

  // Fetch user record
  Future<void> fetchAdmin() async {
    try {
      final String localAuthUserToken = await fetchLocalAuthToken();
      if (localAuthUserToken.isNotEmpty) { // Check if token is valid
        final userData = await mongoAuthenticationRepository.fetchUserById(userId: localAuthUserToken);
        admin(userData);
      } else{
        throw 'User not found';
      }
    } catch (error) {
      rethrow;
    }
  }

  // Refresh Customer data
  Future<void> refreshAdmin() async {
    try {
      isLoading(true);
      admin(UserModel());
      await fetchAdmin();
    } catch (error) {
      AppMassages.warningSnackBar(title: 'Error', message: error.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> showDialogDeleteAccount({required BuildContext context}) async {
    try {
      DialogHelper.showDialog(
        context: context,
        title: 'Delete Account',
        message: 'Are you sure you want to delete your account permanently? This Action is not reversible and all of your data will be removed permanently',
        toastMessage: 'Your Account Deleted successfully!',
        onSubmit: () async => await mongoDeleteAccount(),
        actionButtonText: 'Delete Account'
      );
    } catch (error) {
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  Future<void> mongoDeleteAccount() async {
    try {
      await mongoAuthenticationRepository.deleteUser(id: admin.value.id.toString());
      logout();
    } catch (error) {
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  // this function run after successfully login
  Future<void> login({required UserModel user}) async {
    admin.value = user; //update user value
    isAdminLogin.value = true; //make user login
    saveLocalAuthToken(user.id!);
    AppMassages.showToastMessage(message: 'Login successfully!'); //show massage for successful login
    await initializeEcommercePlatformCredentials();
    await Future.delayed(Duration(milliseconds: 300)); // Add delay
    NavigationHelper.navigateToBottomNavigation(); //navigate to other screen
  }

  //this function for logout
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      deleteLocalAuthToken();
      isAdminLogin.value = false;
      admin.value = UserModel.empty();
      NavigationHelper.navigateToLoginScreen();
    }
    on FirebaseAuthException catch (error) {
      throw TFirebaseAuthException(error.code).message;
    } on FirebaseException catch (error) {
      throw TFirebaseAuthException(error.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (error) {
      throw TFirebaseAuthException(error.code).message;
    }
    catch (error) {
      throw 'Something went wrong. Please try again $error';
    }
  }

}