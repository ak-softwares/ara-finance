import 'package:flutter/material.dart';

import '../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../settings/app_settings.dart';
import '../../../models/product_model.dart';
import '../single_product.dart';
import 'product_title.dart';


class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    this.onTap,

  });

  final ProductModel product;
  final VoidCallback? onTap; // Make it nullable


  @override
  Widget build(BuildContext context) {
    const double productVoucherTileHeight = AppSizes.productVoucherTileHeight;
    const double productVoucherTileWidth = AppSizes.productVoucherTileWidth;
    const double productVoucherTileRadius = AppSizes.productVoucherTileRadius;
    const double productVoucherImageHeight = AppSizes.productVoucherImageHeight;
    const double productVoucherImageWidth = AppSizes.productVoucherImageWidth;

    return GestureDetector(
        onTap: onTap ?? () {
          // Default navigation when onTap is not provided
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleProduct(product: product)));
        },
        child: Container(
          width: productVoucherTileWidth,
          padding: const EdgeInsets.all(AppSizes.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(productVoucherTileRadius),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              // Main Image
              RoundedImage(
                  image: product.mainImage ?? '',
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
                      ProductTitle(title: product.title ?? '', size: 13, maxLines: 2,),
                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Stock ${product.stockQuantity}',
                            style: TextStyle(
                              fontSize: 14,
                              color: product.stockQuantity == null || product.stockQuantity == 0
                                  ? null
                                  : product.stockQuantity! < 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          // Price
                          Text('Price ${AppSettings.currencySymbol + product.purchasePrice.toString()}'),
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










