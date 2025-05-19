import 'package:ara_finance/features/personalization/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/dialog_box_massages/full_screen_loader.dart';
import '../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../common/widgets/network_manager/network_manager.dart';
import '../../../data/repositories/mongodb/authentication/authentication_repositories.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/encryption_hepler.dart';
import '../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../models/ecommerce_platform.dart';


class SetupController extends GetxController {


  final Rx<EcommercePlatform> selectedPlatform = EcommercePlatform.none.obs;

  // WooCommerce
  final wooCommerceDomain = TextEditingController();
  final wooCommerceKey    = TextEditingController();
  final wooCommerceSecret = TextEditingController();
  GlobalKey<FormState> woocommercePlatformFormKey = GlobalKey<FormState>();

  // Shopify
  final shopifyStoreName = TextEditingController();
  final shopifyApiKey = TextEditingController();
  final shopifyPassword = TextEditingController();
  GlobalKey<FormState> shopifyPlatformFormKey = GlobalKey<FormState>();

  // Shopify
  final amazonSellerId = TextEditingController();
  final amazonAuthToken = TextEditingController();
  final amazonMarketplaceId = TextEditingController();
  GlobalKey<FormState> amazonPlatformFormKey = GlobalKey<FormState>();


  final auth = Get.put(AuthenticationController());
  final mongoAuthenticationRepository = Get.put(MongoAuthenticationRepository());

  @override
  void onInit() {
    super.onInit();
    _initialized();
  }

  void _initialized() async {
    final user = auth.admin.value;
    if(user.ecommercePlatform == EcommercePlatform.woocommerce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        wooCommerceDomain.text = user.wooCommerceCredentials?.domain ?? '';
        wooCommerceKey.text = user.wooCommerceCredentials?.key ?? '';
        wooCommerceSecret.text = user.wooCommerceCredentials?.secret ?? '';
      });
    }else if(user.ecommercePlatform == EcommercePlatform.shopify) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        shopifyStoreName.text = user.shopifyCredentials?.storeName ?? '';
        shopifyApiKey.text = user.shopifyCredentials?.apiKey ?? '';
        shopifyPassword.text = user.shopifyCredentials?.password ?? '';
      });
    }else if(user.ecommercePlatform == EcommercePlatform.amazon) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        amazonSellerId.text = user.amazonCredentials?.sellerId ?? '';
        amazonAuthToken.text = user.amazonCredentials?.authToken ?? '';
        amazonMarketplaceId.text = user.amazonCredentials?.marketplaceId ?? '';
      });
    }
  }

  void selectPlatform(EcommercePlatform platform) {
    selectedPlatform.value = platform;
    // Clear previous values when selecting a new platform
    _clearAllFields();
  }

  void _clearAllFields() {
    // Woocommerce
    wooCommerceDomain.text = '';
    wooCommerceKey.text = '';
    wooCommerceSecret.text = '';

    // Shopify
    shopifyStoreName.text = '';
    shopifyApiKey.text = '';
    shopifyPassword.text = '';

    // Amazon
    amazonSellerId.text = '';
    amazonAuthToken.text = '';
    amazonMarketplaceId.text = '';
  }

  Future<void> saveWooCommerceSettings() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your information..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!woocommercePlatformFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      final wooCommerceCredentials = WooCommerceCredentials(
        domain: wooCommerceDomain.text,
        key: wooCommerceKey.text.trim(),
        secret: wooCommerceSecret.text.trim(),
      );

      final userData = UserModel(
        userType: UserType.admin,
        ecommercePlatform: selectedPlatform.value,
        wooCommerceCredentials: wooCommerceCredentials,
      );

      await mongoAuthenticationRepository.updateUserById(id: auth.userId, user: userData);

      await auth.refreshAdmin();
      // remove Loader
      FullScreenLoader.stopLoading();

      // UserController.instance.fetchUserRecord();
      AppMassages.showToastMessage(message: 'Details updated successfully!');
      // move to next screen
      Get.close(1);
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  Future<void> saveShopifySettings() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your information..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!shopifyPlatformFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      final shopifyCredentials = ShopifyCredentials(
        storeName: shopifyStoreName.text,
        apiKey: shopifyApiKey.text.trim(),
        password: shopifyPassword.text.trim(),
      );

      final userData = UserModel(
        userType: UserType.admin,
        ecommercePlatform: selectedPlatform.value,
        shopifyCredentials: shopifyCredentials,
      );

      await mongoAuthenticationRepository.updateUserById(id: auth.userId, user: userData);

      await auth.refreshAdmin();
      // remove Loader
      FullScreenLoader.stopLoading();

      // UserController.instance.fetchUserRecord();
      AppMassages.showToastMessage(message: 'Details updated successfully!');
      // move to next screen
      Get.close(1);
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

  Future<void> saveAmazonSettings() async {
    try {
      //Start Loading
      FullScreenLoader.openLoadingDialog('We are updating your information..', Images.docerAnimation);
      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        FullScreenLoader.stopLoading();
        return;
      }
      // Form Validation
      if (!amazonPlatformFormKey.currentState!.validate()) {
        FullScreenLoader.stopLoading();
        return;
      }

      final amazonCredentials = AmazonCredentials(
        sellerId: amazonSellerId.text,
        authToken: amazonAuthToken.text.trim(),
        marketplaceId: amazonMarketplaceId.text.trim(),
      );

      final userData = UserModel(
        userType: UserType.admin,
        ecommercePlatform: selectedPlatform.value,
        amazonCredentials: amazonCredentials,
      );

      await mongoAuthenticationRepository.updateUserById(id: auth.userId, user: userData);

      await auth.refreshAdmin();
      // remove Loader
      FullScreenLoader.stopLoading();

      // UserController.instance.fetchUserRecord();
      AppMassages.showToastMessage(message: 'Details updated successfully!');
      // move to next screen
      Get.close(1);
    } catch (error) {
      //remove Loader
      FullScreenLoader.stopLoading();
      AppMassages.errorSnackBar(title: 'Error', message: error.toString());
    }
  }

}