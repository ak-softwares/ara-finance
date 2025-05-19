import 'package:flutter/material.dart';

import '../../../../../common/styles/spacing_style.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/models/user_model.dart';


class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, this.onTap});

  final UserModel customer;
  final VoidCallback? onTap; // Function to handle tap events

  @override
  Widget build(BuildContext context) {
    const double customerVoucherTileHeight = AppSizes.customerVoucherTileHeight;
    const double customerVoucherTileWidth = AppSizes.customerVoucherTileWidth;
    const double customerVoucherTileRadius = AppSizes.customerVoucherTileRadius;
    const double customerVoucherImageHeight = AppSizes.customerVoucherImageHeight;
    const double customerVoucherImageWidth = AppSizes.customerVoucherImageWidth;

    return GestureDetector(
        onTap: onTap,
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            width: customerVoucherTileWidth,
            padding: AppSpacingStyle.defaultPagePadding,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customer Id'),
                    Text('#${customer.documentId}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Name'),
                    Text(customer.fullName),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Balance'),
                    // Text(customer.balance.toString()),
                  ],
                ),
              ],
            )
        )
    );
  }

}










