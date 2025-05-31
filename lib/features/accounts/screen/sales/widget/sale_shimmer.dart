import 'package:flutter/material.dart';

import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/widgets/shimmers/shimmer_effect.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class SaleShimmer extends StatelessWidget {
  const SaleShimmer({super.key, this.itemCount = 1,});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final double saleTileHeight = AppSizes.saleTileHeight;
    final double saleTileWidth = AppSizes.saleTileWidth;
    final double saleTileRadius = AppSizes.saleTileRadius;
    final double saleImageHeight = AppSizes.saleImageHeight;
    final double saleImageWidth = AppSizes.saleImageWidth;

    return GridLayout(
        mainAxisExtent: saleTileHeight,
        itemCount: itemCount,
        itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              padding: AppSpacingStyle.defaultPagePadding,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(saleTileRadius),
              ),
              child: Column(
                spacing: AppSizes.xs,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Invoice Number'),
                      ShimmerEffect(width: 50, height: 17),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Number'),
                      ShimmerEffect(width: 100, height: 17),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Date'),
                      ShimmerEffect(width: 70, height: 17),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'),
                      ShimmerEffect(width: 60, height: 17),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status'),
                      ShimmerEffect(width: 60, height: 17),
                    ],
                  ),
                  Container(
                    height: 1,
                    color: AppColors.borderDark,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSizes.spaceBtwItems,
                    children: [
                      ShimmerEffect(width: 40, height: 40, radius: AppSizes.sm),
                      ShimmerEffect(width: 40, height: 40, radius: AppSizes.sm),
                      ShimmerEffect(width: 40, height: 40, radius: AppSizes.sm),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
