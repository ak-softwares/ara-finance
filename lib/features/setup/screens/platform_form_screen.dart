import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/navigation_bar/appbar.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/setup_controller.dart';
import '../models/ecommerce_platform.dart';

class PlatformFormScreen extends StatelessWidget {
  const PlatformFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SetupController controller = Get.find();

    return Scaffold(
      appBar: AppAppBar(
        title: controller.selectedPlatform.value == EcommercePlatform.woocommerce
              ? 'WooCommerce Setup'
              : controller.selectedPlatform.value == EcommercePlatform.shopify
                  ? 'Shopify Setup'
                  : 'Amazon Setup',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Obx(() {
          switch (controller.selectedPlatform.value) {
            case EcommercePlatform.woocommerce:
              return _WooCommerceForm();
            case EcommercePlatform.shopify:
              return _ShopifyForm();
            case EcommercePlatform.amazon:
              return _AmazonForm();
            case EcommercePlatform.none:
              return SizedBox();
          }
        }),
      ),
    );
  }
}

class _WooCommerceForm extends StatelessWidget {
  final SetupController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _controller.woocommercePlatformFormKey,
      child: Column(
        spacing: AppSizes.spaceBtwItems,
        children: [
          Text('Enter your WooCommerce credentials', style: TextStyle(fontSize: 16)),
          TextFormField(
              controller: _controller.wooCommerceDomain,
              validator: (value) => Validator.validateDomain(value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.public),
                  labelText: 'Store Domain (e.g., mystore.com)'
              )
          ),
          TextFormField(
              controller: _controller.wooCommerceKey,
              validator: (value) => Validator.validateEmptyText(fieldName: 'Consumer Key', value: value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  labelText: 'Consumer Key'
              )
          ),
          TextFormField(
              controller: _controller.wooCommerceSecret,
              validator: (value) => Validator.validateEmptyText(fieldName: 'Consumer Secret', value: value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.security),
                  labelText: 'Consumer Secret'
              )
          ),
          ElevatedButton(
            onPressed: () => _controller.saveWooCommerceSettings(),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text('Connect Store'),
          ),
        ],
      ),
    );
  }}

class _ShopifyForm extends StatelessWidget {
  final SetupController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _controller.shopifyPlatformFormKey,
      child: Column(
        spacing: AppSizes.spaceBtwItems,
        children: [
          Text(
            'Enter your Shopify credentials',
            style: TextStyle(fontSize: 16),
          ),
          TextFormField(
              controller: _controller.shopifyStoreName,
              validator: (value) => Validator.validateDomain(value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.store),
                  labelText: 'Store Name (e.g., mystore.myshopify.com)'
              )
          ),
          TextFormField(
              controller: _controller.shopifyApiKey,
              validator: (value) => Validator.validateEmptyText(fieldName: 'API Key', value: value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.vpn_key),
                  labelText: 'API Key'
              )
          ),
          TextFormField(
              controller: _controller.shopifyPassword,
              validator: (value) => Validator.validateEmptyText(fieldName: 'Password', value: value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.security),
                  labelText: 'Password'
              )
          ),

          ElevatedButton(
            onPressed: () => _controller.saveShopifySettings(),
            style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            child: Text('Connect Store'),
          ),
        ],
      ),
    );
  }
}

class _AmazonForm extends StatelessWidget {
  final SetupController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _controller.amazonPlatformFormKey,
      child: Column(
        spacing: AppSizes.spaceBtwItems,
        children: [
          Text(
            'Enter your Amazon Seller credentials',
            style: TextStyle(fontSize: 16),
          ),
          TextFormField(
              controller: _controller.amazonSellerId,
              validator: (value) => Validator.validateEmptyText(fieldName: 'Seller ID', value: value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.store),
                  labelText: 'Seller ID'
              )
          ),
          TextFormField(
              controller: _controller.amazonAuthToken,
              validator: (value) => Validator.validateEmptyText(fieldName: 'Auth Token', value: value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.security),
                  labelText: 'Auth Token'
              )
          ),
          TextFormField(
              controller: _controller.amazonMarketplaceId,
              validator: (value) => Validator.validateEmptyText(fieldName: 'Marketplace ID', value: value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.public),
                  labelText: 'Marketplace ID'
              )
          ),

          ElevatedButton(
            onPressed: () => _controller.saveAmazonSettings(),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text('Connect Store'),
          ),
        ],
      ),
    );
  }
}