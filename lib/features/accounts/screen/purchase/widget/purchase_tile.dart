import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../../common/layout_models/product_list_layout.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatters.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/order_model.dart';
import '../../orders/widgets/order_image_gallery.dart';
import '../../vendor/single_vendor.dart';
import '../single_purchase.dart';

class PurchaseTile extends StatelessWidget {
  const PurchaseTile({super.key, required this.purchase});

  final OrderModel purchase;

  @override
  Widget build(BuildContext context) {
    final double purchaseTileHeight = AppSizes.purchaseTileHeight;
    final double purchaseTileWidth = AppSizes.purchaseTileWidth;
    final double purchaseTileRadius = AppSizes.purchaseTileRadius;
    final double purchaseImageHeight = AppSizes.purchaseImageHeight;
    final double purchaseImageWidth = AppSizes.purchaseImageWidth;
    final List<CartModel> cartItems = purchase.lineItems ?? [];

    return InkWell(
      onTap: () => Get.to(() => SinglePurchase(purchase: purchase)),
      child: Container(
        padding: AppSpacingStyle.defaultPagePadding,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(purchaseTileRadius),
        ),
        child: Column(
          spacing: AppSizes.xs,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Number'),
                Text('#${purchase.invoiceNumber}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date'),
                Text(AppFormatter.formatDate(purchase.dateCreated)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vendor'),
                InkWell(
                  onTap: () => purchase.user != null ? Get.to(() => SingleVendor(vendor: purchase.user!)) : {},
                  child: Text(purchase.user?.companyName ?? '', style: TextStyle(color: Colors.blue),)
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total'),
                Text(purchase.total.toString()),
              ],
            ),
            Container(
              height: 1,
              color: AppColors.borderDark,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: OrderImageGallery(cartItems: cartItems, galleryImageHeight: 40)),
                SizedBox(width: AppSizes.sm),
                Container(height: 40, width: 1, color: AppColors.borderDark,),
                SizedBox(width: AppSizes.sm),
                purchase.purchaseInvoiceImages != null
                    ? Expanded(
                        child: ListLayout(
                            height: 40,
                            itemCount: purchase.purchaseInvoiceImages!.length,
                            itemBuilder: (_, index) => Padding(
                              padding: const EdgeInsets.only(right: AppSizes.sm),
                              child: RoundedImage(
                                height: 40,
                                width: 40,
                                borderRadius: AppSizes.sm,
                                backgroundColor: Colors.white,
                                padding: AppSizes.xs,
                                isNetworkImage: true,
                                isTapToEnlarge: true,
                                image: purchase.purchaseInvoiceImages?[index].imageUrl ?? '',
                              ),
                            )
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
