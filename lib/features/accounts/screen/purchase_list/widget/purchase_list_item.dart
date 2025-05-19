import 'package:flutter/material.dart';

import '../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/purchase_item_model.dart';


class PurchaseListItem extends StatelessWidget {
  const PurchaseListItem({super.key, required this.product, this.isDeleted = false});

  final PurchaseItemModel product;
  final bool isDeleted;

  @override
  Widget build(BuildContext context) {
    final double purchaseItemTileHeight = AppSizes.purchaseItemTileHeight;
    final double purchaseItemTileWidth = AppSizes.purchaseItemTileWidth;
    final double purchaseItemTileRadius = AppSizes.purchaseItemTileRadius;
    final double purchaseItemImageHeight = AppSizes.purchaseItemImageHeight;
    final double purchaseItemImageWidth = AppSizes.purchaseItemImageWidth;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(purchaseItemTileRadius),
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.outline
            ),          ),
          child: Row(
            spacing: AppSizes.sm,
            children: [
              InkWell(
                child: RoundedImage(
                    height: purchaseItemImageHeight,
                    width: purchaseItemImageWidth,
                    padding: 0,
                    isNetworkImage: true,
                    borderRadius: purchaseItemTileRadius,
                    image: product.image,
                    isTapToEnlarge: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace, vertical: AppSizes.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 13,
                              // color: Theme.of(context).colorScheme.onSurface
                          )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Prepaid',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)
                              ),
                              Text(product.prepaidQuantity.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bulk', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)),
                              Text(product.bulkQuantity.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500,)),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)),
                              Text(product.totalQuantity.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        product.isOlderThanTwoDays
            ? Positioned(
                top: 1,
                right: 1,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(purchaseItemTileRadius),
                        bottomRight: Radius.circular(0),
                        bottomLeft: Radius.circular(purchaseItemTileRadius * 3), // Making bottom-left bigger
                      ),              ),
                    child: Center(
                        child: Text('D', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 12),)
                    )
                )
              )
            : SizedBox.shrink(),
        isDeleted
            ? Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(purchaseItemTileRadius),
                    ),
                    child: Center(
                        child: Divider(color: Colors.grey)
                    )
                )
              )
            : SizedBox.shrink()
      ],
    );
  }
}
