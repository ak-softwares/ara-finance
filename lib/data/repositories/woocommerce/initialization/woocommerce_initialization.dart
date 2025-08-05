import 'dart:convert';

import 'package:get/get.dart';

import '../../../../features/authentication/controllers/authentication_controller/authentication_controller.dart';

class Woocommerce {
  // late String wooBaseDomain, wooConsumerKey, wooConsumerSecret;
  String get wooBaseDomain      => auth.admin.value.wooCommerceCredentials?.domain ?? '';
  String get wooConsumerKey     => auth.admin.value.wooCommerceCredentials?.key ?? '';
  String get wooConsumerSecret  => auth.admin.value.wooCommerceCredentials?.secret ?? '';
  String get authorization      => 'Basic ${base64Encode(utf8.encode('$wooConsumerKey:$wooConsumerSecret'))}';
  String get wooTrackingUrl     => 'https://$wooBaseDomain/tracking/?order-id=';
  String get allCategoryUrl     => 'https://$wooBaseDomain$urlContainProductCategory';
  String get productBrandUrl    => 'https://$wooBaseDomain$urlProductBrand';

  static const String wooItemsPerPage          = '10';
  static const String wooItemsPerPageSync      = '50';

  final auth = Get.put(AuthenticationController());

  // Define urls
  static const String urlContainProduct         = '/product/';
  static const String urlContainProductCategory = '/product-category/';
  static const String urlProductBrand           = '/brand/';
  static const String urlContainOrders          = '/my-account/orders';


  static const String wooProductsApiPath    = '/wp-json/wc/v3/products/';
  static const String wooProductBrandsApiPath    = '/wp-json/wc/v3/products/brands/';
  static const String wooCategoriesApiPath  = '/wp-json/wc/v3/products/categories/';
  static const String wooCouponsApiPath     = '/wp-json/wc/v3/coupons/';
  static const String wooOrdersApiPath      = '/wp-json/wc/v3/orders/';
  static const String wooCustomersApiPath   = '/wp-json/wc/v3/customers/';
  static const String wooProductsReview     = '/wp-json/wc/v3/products/reviews/';

  static const String wooSettings           = '/wp-json/flutter-app/v1/app-settings/';
  static const String wooBanners            = '/wp-json/flutter-app/v1/home-banners/';
  static const String wooCustomersPhonePath = '/wp-json/flutter-app/v1/customer-by-phone/';
  static const String wooAuthenticatePath   = '/wp-json/flutter-app/v1/authenticate/';
  static const String wooResetPassword      = '/wp-json/flutter-app/v1/reset-password/';
  static const String wooFBT                = '/wp-json/flutter-app/v1/products-sold-together/';
  static const String wooProductsReviewImage= '/wp-json/flutter-app/v1/product-reviews/';

  // Initialize the database connection
  Future<void> initialize() async {
    if (wooBaseDomain.isEmpty || wooConsumerKey.isEmpty || wooConsumerSecret.isEmpty) {
      throw Exception('WooCommerce credentials are not initialized.');
    }
  }
}

// WooCommerce API Constant
// static final String wooBaseDomain         =  dotenv.get('WOO_API_URL', fallback: '');
// static final String wooConsumerKey        =  dotenv.get('WOO_CONSUMER_KEY', fallback: '');
// static final String wooConsumerSecret     =  dotenv.get('WOO_CONSUMER_SECRET', fallback: '');
// static final String authorization         = 'Basic ${base64Encode(utf8.encode('$wooConsumerKey:$wooConsumerSecret'))}';
