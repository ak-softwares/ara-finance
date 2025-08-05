import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../features/personalization/models/user_model.dart';

class APIConstant {

  static final int itemsPerPage = 10;

  // RazorPay credential
  static final String razorpayKey = dotenv.get('RAZORPAY_KEY', fallback: '');
  static final String razorpaySecret = dotenv.get('RAZORPAY_SECRET', fallback: '');

  static final String razorpayAuth = 'Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}';

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