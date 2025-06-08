import 'package:ara_finance/common/widgets/shimmers/shimmer_effect.dart';
import 'package:flutter/material.dart';

import '../../../../../common/styles/spacing_style.dart';
import '../../../../../utils/constants/sizes.dart';


class UserShimmer extends StatelessWidget {
  const UserShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    const double userTileHeight = AppSizes.userTileHeight;
    const double userTileWidth = AppSizes.userTileWidth;
    const double userTileRadius = AppSizes.userTileRadius;
    const double userImageHeight = AppSizes.userImageHeight;
    const double userImageWidth = AppSizes.userImageWidth;

    return Container(
        color: Theme.of(context).colorScheme.surface,
        width: userTileWidth,
        padding: AppSpacingStyle.defaultPagePadding,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Name'),
                ShimmerEffect(width: 50, height: 20, radius: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email'),
                ShimmerEffect(width: 50, height: 20, radius: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phone'),
                ShimmerEffect(width: 50, height: 20, radius: 20),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date creation:'),
                ShimmerEffect(width: 50, height: 20, radius: 20),
              ],
            ),
          ],
        )
    );
  }

}










