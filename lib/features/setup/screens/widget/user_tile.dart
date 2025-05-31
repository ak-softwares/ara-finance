import 'package:ara_finance/utils/formatters/formatters.dart';
import 'package:flutter/material.dart';

import '../../../../../common/styles/spacing_style.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../personalization/models/user_model.dart';


class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final UserModel user;

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
                Text(user.name ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email'),
                Text(user.email ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phone'),
                Text(user.phone ?? ''),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date creation:'),
                Text(AppFormatter.formatDate(user.dateCreated)),
              ],
            ),
          ],
        )
    );
  }

}










