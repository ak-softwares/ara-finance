import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/personalization/models/user_model.dart';

class APIConstant {

  static late String wooBaseDomain;
  static late String wooConsumerKey;
  static late String wooConsumerSecret;

  static String get authorization => 'Basic ${base64Encode(utf8.encode('$wooConsumerKey:$wooConsumerSecret'))}';

  static void initializeWooCommerceCredentials({required UserModel user}) {
    wooBaseDomain     = user.wooCommerceCredentials?.domain ?? '';
    wooConsumerKey    = user.wooCommerceCredentials?.key ?? '';
    wooConsumerSecret = user.wooCommerceCredentials?.secret ?? '';
  }

  // WooCommerce API Constant
  // static final String wooBaseDomain         =  dotenv.get('WOO_API_URL', fallback: '');
  // static final String wooConsumerKey        =  dotenv.get('WOO_CONSUMER_KEY', fallback: '');
  // static final String wooConsumerSecret     =  dotenv.get('WOO_CONSUMER_SECRET', fallback: '');
  // static final String authorization         = 'Basic ${base64Encode(utf8.encode('$wooConsumerKey:$wooConsumerSecret'))}';

  static const String itemsPerPage          = '10';
  static const String itemsPerPageSync      = '50';
  static final String wooTrackingUrl        = 'https://$wooBaseDomain/tracking/?order-id=';

  // RazorPay credential
  static final String razorpayKey = dotenv.get('RAZORPAY_KEY', fallback: '');
  static final String razorpaySecret = dotenv.get('RAZORPAY_SECRET', fallback: '');

  static final String razorpayAuth = 'Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}';

  // Define urls
  static const String urlContainProduct         = '/product/';
  static const String urlContainProductCategory = '/product-category/';
  static const String urlProductBrand           = '/brand/';
  static const String urlContainOrders          = '/my-account/orders';
  static String allCategoryUrl                  = 'https://$wooBaseDomain$urlContainProductCategory';
  static String productBrandUrl                 = 'https://$wooBaseDomain$urlProductBrand';

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

  // fast2sms url
  static final String fast2smsUrl           = dotenv.get('FAST2SMS_API_URL', fallback: '');
  static final String fast2smsToken         = dotenv.get('FAST2SMS_API_TOKEN', fallback: '');

  // Image kit
  static final String imageKitUploadUrl     = 'https://upload.imagekit.io/api/v1/files/upload';
  static final String imageKitDeleteUrl     = 'https://api.imagekit.io/v1/files';
  static final String batchImageKitDeleteUrl     = 'https://api.imagekit.io/v1/files/batch';
  static final String imageKitPrivateKey    = dotenv.get('IMAGE_KIT_PRIVATE_KEY', fallback: '');
  static final String imageKitPublicKey    = dotenv.get('IMAGE_KIT_PUBLIC_KEY', fallback: '');

  // Facebook whatsapp api
  static final String whatsappPhoneNumberId     = dotenv.get('WHATSAPP_API_MOBILE_ID', fallback: '');
  static final String whatsappApiToken          = dotenv.get('WHATSAPP_API_TOKEN', fallback: '');
  static final String waApiTemplateOtp          = dotenv.get('WA_APT_TEMPLATE_OTP', fallback: '');
}