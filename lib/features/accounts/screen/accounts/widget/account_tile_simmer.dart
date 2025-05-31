import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/widgets/shimmers/shimmer_effect.dart';
import '../../../../../utils/constants/sizes.dart';


class AccountTileSimmer extends StatelessWidget {
  const AccountTileSimmer({
    super.key,
    this.itemCount = 1,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    const double paymentTileHeight = AppSizes.accountTileHeight;
    const double paymentTileWidth = AppSizes.accountTileWidth;
    const double paymentTileRadius = AppSizes.accountTileRadius;
    const double paymentImageHeight = AppSizes.accountImageHeight;
    const double paymentImageWidth = AppSizes.accountImageWidth;

    return GridLayout(
        itemCount: itemCount,
        crossAxisCount: 1,
        mainAxisExtent: paymentTileHeight,
        itemBuilder: (context, index) {
          return Container(
              width: paymentTileWidth,
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(paymentTileRadius),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Accounts  Method'),
                      ShimmerEffect(width: 150, height: 10),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Opening Balance'),
                      ShimmerEffect(width: 100, height: 10),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Balance'),
                      ShimmerEffect(width: 50, height: 10),
                    ],
                  ),
                ],
              )
          );
        }
    );
  }
}
