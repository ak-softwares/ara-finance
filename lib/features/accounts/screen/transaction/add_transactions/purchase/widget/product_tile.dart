import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../../../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../../../utils/constants/enums.dart';
import '../../../../../../../utils/constants/sizes.dart';
import '../../../../../../settings/app_settings.dart';
import '../../../../../models/cart_item_model.dart';
import '../../../../products/widget/product_title.dart';


class PurchaseProductCard extends StatelessWidget {
  const PurchaseProductCard({super.key, required this.cartItem, required this.controller, required this.orderType});

  final CartModel cartItem;
  final OrderType orderType;
  final dynamic controller;

  @override
  Widget build(BuildContext context) {
    const double purchaseProductTileHeight = AppSizes.purchaseProductTileHeight;
    const double purchaseProductTileWidth = AppSizes.purchaseProductTileWidth;
    const double purchaseProductTileRadius = AppSizes.purchaseProductTileRadius;
    const double purchaseProductImageHeight = AppSizes.purchaseProductImageHeight;
    const double purchaseProductImageWidth = AppSizes.purchaseProductImageWidth;

    // Reactive variables for quantity and total
    final RxInt quantity = cartItem.quantity.obs;
    final RxDouble price = orderType == OrderType.purchase ? (cartItem.purchasePrice ?? 0.0).obs : (cartItem.price?.toDouble() ?? 0.0).obs;

    return Obx(() {
      return Stack(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                // Main Image
                Padding(
                  padding: const EdgeInsets.only(left: AppSizes.xs),
                  child: RoundedImage(
                    image: cartItem.image ?? '',
                    height: purchaseProductImageHeight,
                    width: purchaseProductImageWidth,
                    borderRadius: purchaseProductTileRadius,
                    isNetworkImage: true,
                  ),
                ),

                // Title, Rating, and Price
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top:AppSizes.xs, left: AppSizes.sm, right: AppSizes.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        ProductTitle(title: cartItem.name ?? '', maxLines: 1),

                        // Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              spacing: AppSizes.sm,
                              children: [
                                Text(AppSettings.currencySymbol, style: TextStyle(fontSize: 16),),
                                SizedBox(
                                  // height: 30,
                                  width: 70,
                                  child: TextFormField(
                                    initialValue: price.value.toStringAsFixed(0),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final double newPrice = double.tryParse(value) ?? price.value;
                                      price.value = newPrice;
                                      controller.updatePrice(item: cartItem, purchasePrice: newPrice);
                                    },
                                    decoration: const InputDecoration(
                                      // border: InputBorder.none,
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue, // Blue color
                                          style: BorderStyle.solid, // Solid line (you can use `BorderStyle.none` to remove the default border)
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text('x', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),),
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                initialValue: quantity.value.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final int newQuantity = int.tryParse(value) ?? quantity.value;
                                  quantity.value = newQuantity;
                                  controller.updateQuantity(item: cartItem, quantity: newQuantity);
                                },
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blue, // Blue color
                                      style: BorderStyle.solid, // Solid line (you can use `BorderStyle.none` to remove the default border)
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text('=', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            Obx(() => Text(
                                '${AppSettings.currencySymbol}${(quantity.value * price.value).toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 3,
            left: 3,
            child: RoundedContainer(
              width: 25,
              height: 25,
              radius: 25,
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.grey.withOpacity(0.2),
              child: IconButton(
                color: Colors.grey,
                padding: EdgeInsets.zero,
                onPressed: () => controller.removeProducts(cartItem),
                icon: const Icon(Icons.close, size: 15),
              ),
            ),
          ),
          if(cartItem.stockQuantity != null && cartItem.stockQuantity != 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8), // adjust the radius as needed
                  ),
                ),
                child: Text(cartItem.stockQuantity.toString(), style: TextStyle(color: Colors.white, fontSize: 12),),
              ),
            ),
        ],
      );
    });
  }
}
