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

    final bool isPrepaid = (product.prepaidQuantity ?? 0) > 0;
    final bool isBulk = (product.bulkQuantity ?? 0) > 0;
    final bool isDelay = product.isOlderThanTwoDays ?? false;

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
                    image: product.image ?? '',
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
                      Text(product.name ?? '',
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
                              Text('Orders', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)),
                              Text(product.totalQuantity.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Stock',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)
                              ),
                              Text(product.stock.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)
                              ),
                              Text(((product.totalQuantity ?? 0) - (product.stock ?? 0)).toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text('Bulk', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)),
                          //     Text(product.bulkQuantity.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w500,)),
                          //   ],
                          // ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Text('Total', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 12)),
                          //     Text(product.totalQuantity.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                          //   ],
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        if(isPrepaid)
          Positioned(
              top: 1,
              right: 40,
              child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0)
                    ),
                  ),
                  child: Center(
                      child: Text('P', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 12),)
                  )
              )
          ),
        if(isBulk)
          Positioned(
              top: 1,
              right: 20,
              child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                      bottomLeft: Radius.circular(0)
                    ),
                  ),
                  child: Center(
                      child: Text('B', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 12),)
                  )
              )
          ),
        if(isDelay)
          Positioned(
                top: 1,
                right: 1,
                child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(purchaseItemTileRadius),
                        bottomRight: Radius.circular(0),
                        bottomLeft: Radius.circular(0)
                      ),              ),
                    child: Center(
                        child: Text('D', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 12),)
                    )
                )
              ),
        if(isDeleted)
          Positioned(
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
      ],
    );
  }
}
