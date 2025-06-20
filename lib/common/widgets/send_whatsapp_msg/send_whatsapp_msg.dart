import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../features/settings/app_settings.dart';
import '../../../utils/constants/colors.dart';

class SendWhatsappScreen extends StatelessWidget {
  const SendWhatsappScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FloatingActionButton(
      shape: CircleBorder(),
      backgroundColor: AppColors.whatsAppColor,
      onPressed: SendMSG.sendWhatsAppMessage,
      tooltip: 'Send WhatsApp Message',
      child: Icon(LineIcons.whatSApp, size: 30, color: Colors.white,),
    );
  }
}

class SendMSG {
  static void sendWhatsAppMessage() {
    // The phone number to send the message to (include the country code)
    String phoneNumber = AppSettings.supportWhatsApp;

    // The message to send
    String message = 'Hello, ${AppSettings.appName}';

    // Create the WhatsApp message URL
    String url = 'https://wa.me/$phoneNumber?text=${Uri.encodeFull(message)}';

    // Launch the WhatsApp app with the pre-filled message
    launchUrlString(url);
  }

  static void call() {
    // The phone number to call (include the country code)
    String phoneNumber = AppSettings.supportMobile;

    // Create the phone call URL
    String url = 'tel:$phoneNumber';

    // Launch the phone app to make the call
    launchUrlString(url);
  }

  static void sendEmail() {
    // The email address to send the email to
    String email = AppSettings.supportEmail;

    // Create the email URL
    String url = 'mailto:$email';

    // Launch the email app with the pre-filled email
    launchUrlString(url);
  }

}