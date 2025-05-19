import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/navigation_bar/appbar.dart';
import '../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../controllers/setup_controller.dart';
import 'platform_form_screen.dart';


class PlatformSelectionScreen extends StatelessWidget {

  const PlatformSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppAppBar(title: 'Connect Your Store'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                'Select your e-commerce platform',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: AppSizes.md),
            _PlatformCard(
              platform: EcommercePlatform.woocommerce,
              name: 'WooCommerce',
              image: 'assets/images/ecommerce_platform/woocommerce_logo.png',
              color: Colors.blue,
            ),
            SizedBox(height: AppSizes.md),
            _PlatformCard(
              platform: EcommercePlatform.shopify,
              name: 'Shopify',
              image: 'assets/images/ecommerce_platform/shopify_logo.png',
              color: Colors.green,
            ),
            SizedBox(height: AppSizes.md),
            _PlatformCard(
              platform: EcommercePlatform.amazon,
              name: 'Amazon',
              image: 'assets/images/ecommerce_platform/amazon_logo.png',
              color: Colors.orange,
            ),
            SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  final EcommercePlatform platform;
  final String name;
  final String image;
  final Color color;

  const _PlatformCard({
    required this.platform,
    required this.name,
    required this.image,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Get.put(AuthenticationController());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Get.put(SetupController()).selectPlatform(platform);
                Get.to(() => PlatformFormScreen());
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundedImage(
                    width: 200,
                    image: image,
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if(auth.admin.value.ecommercePlatform == platform)
            Positioned(
            top: 15,
            right: 20,
            child: Icon(Icons.check_circle, color: Colors.green, size: 25,),
          )
        ],
      ),
    );
  }
}