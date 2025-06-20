import 'package:flutter/material.dart';
import '../../../../../common/widgets/send_whatsapp_msg/send_whatsapp_msg.dart';
import '../../../../../utils/constants/icons.dart';
import '../../../../settings/app_settings.dart';
class SupportWidget extends StatelessWidget {
  const SupportWidget({super.key,});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          onTap: SendMSG.sendWhatsAppMessage,
          leading: Icon(Icons.chat, size: 20),
          title: Text('Whatsapp us'),
          subtitle: Text(AppSettings.supportWhatsApp),
          trailing: Icon(AppIcons.whatsapp, size: 20, color: Colors.blue),
        ),
        // ListTile(
        //   onTap: SendMSG.sendEmail,
        //   leading: Icon(Icons.email, size: 20),
        //   title: Text('Email us'),
        //   subtitle: Text(AppSettings.supportEmail),
        //   trailing: Icon(Icons.email_outlined, size: 20, color: Colors.blue),
        // ),
        // ListTile(
        //   onTap: SendMSG.call,
        //   leading: Icon(Icons.call_end_sharp, size: 20),
        //   title: Text('Call us'),
        //   subtitle: Text(AppSettings.supportMobile),
        //   trailing: Icon(Icons.phone, size: 20, color: Colors.blue),
        // ),
      ],
    );
  }
}
