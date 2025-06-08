import 'package:flutter/material.dart';

import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/widgets/shimmers/shimmer_effect.dart';
import '../../../../../utils/constants/sizes.dart';

class AccountVoucherTileShimmer extends StatelessWidget {
  const AccountVoucherTileShimmer({
    super.key,
    this.itemCount = 1,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    const double tileHeight = AppSizes.accountTileHeight;
    const double tileWidth = AppSizes.accountTileWidth;
    const double tileRadius = AppSizes.accountTileRadius;

    return GridLayout(
      itemCount: itemCount,
      crossAxisCount: 1,
      mainAxisExtent: tileHeight,
      itemBuilder: (context, index) {
        return Container(
          width: tileWidth,
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tileRadius),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('AccountVoucher Title'),
                  ShimmerEffect(width: 150, height: 10),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Amount'),
                  ShimmerEffect(width: 100, height: 10),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('AccountVoucher Type'),
                  ShimmerEffect(width: 80, height: 10),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Account Used'),
                  ShimmerEffect(width: 120, height: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}