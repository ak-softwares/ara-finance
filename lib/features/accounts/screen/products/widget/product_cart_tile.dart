import 'package:flutter/material.dart';

import '../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../settings/app_settings.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/product_model.dart';
import '../single_product.dart';
import 'product_title.dart';


class ProductCartTile extends StatelessWidget {
  const ProductCartTile({
    super.key,
    required this.cartItem, this.orderType,
  });

  final CartModel cartItem;
  final OrderType? orderType;

  @override
  Widget build(BuildContext context) {
    const double productVoucherTileHeight = AppSizes.productVoucherTileHeight;
    const double productVoucherTileWidth = AppSizes.productVoucherTileWidth;
    const double productVoucherTileRadius = AppSizes.productVoucherTileRadius;
    const double productVoucherImageHeight = AppSizes.productVoucherImageHeight;
    const double productVoucherImageWidth = AppSizes.productVoucherImageWidth;

    return InkWell(
        child: Container(
          // width: productVoucherTileWidth,
          padding: const EdgeInsets.all(AppSizes.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(productVoucherTileRadius),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              // Main Image
              RoundedImage(
                  image: cartItem.image ?? '',
                  height: productVoucherImageHeight,
                  width: productVoucherImageWidth,
                  borderRadius: productVoucherTileRadius,
                  isNetworkImage: true,
                  padding: 0
              ),

              // Title, Rating and price
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSizes.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductTitle(title: cartItem.name ?? '', size: 13, maxLines: 2,),
                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Price '
                                '${AppSettings.currencySymbol}${orderType == OrderType.purchase ? (cartItem.purchasePrice?.toString() ?? '0') : (cartItem.price?.toString() ?? '0')}',
                          ),
                          Text('Quantity ${cartItem.quantity.toString()}'),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}










