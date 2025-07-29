import 'package:flutter/material.dart';

import '../../../../../common/styles/spacing_style.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/address_model.dart';

class SingleAddress extends StatelessWidget {

  const SingleAddress({
    super.key,
    required this.address,
    required this.onTap,
    this.hidePhone = false,
    this.hideEdit = false,
  });

  final AddressModel address;
  final bool hidePhone;
  final bool hideEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        padding: AppSpacingStyle.defaultPagePadding,
        child: Stack(
          children: [
            !hideEdit
                ? const Positioned(
                      right: 5,
                      top: 0,
                      child: Row(
                        spacing: AppSizes.sm,
                        children: [
                          Text('Edit', style: TextStyle(color: AppColors.linkColor),),
                          Icon(Icons.edit, size: 20, color: AppColors.linkColor),
                        ],
                      )
                  )
                : SizedBox.shrink(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(address.companyName != null && address.companyName!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.companyName!, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                      Text(address.gstNumber ?? '', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                Text(address.name, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                hidePhone
                    ? const SizedBox.shrink()
                    : Text(address.formattedPhoneNo, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                hidePhone
                    ? const SizedBox.shrink()
                    : Text(address.email ?? '', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 15), overflow: TextOverflow.ellipsis),
                Text(address.toString(), style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis, maxLines: 4,
                ),
                const SizedBox(height: AppSizes.sm),
              ],
            )
          ],
        ),
      ),
    );
  }
}

