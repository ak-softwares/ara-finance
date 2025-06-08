import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


import '../../../../../common/styles/spacing_style.dart';
import '../../../../../utils/constants/api_constants.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatters.dart';
import '../../../../../utils/helpers/order_helper.dart';
import '../../../../settings/app_settings.dart';
import '../../../models/order_model.dart';
import 'order_image_gallery.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final double orderImageHeight = AppSizes.orderImageHeight;
    final double orderImageWidth = AppSizes.orderImageWidth;
    final double orderTileHeight = AppSizes.orderTileHeight;
    final double orderTileRadius = AppSizes.orderTileRadius;

    return InkWell(
      child: Container(
        padding: AppSpacingStyle.defaultPagePadding,
        decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(orderTileRadius),
          border: Border.all(
            width: AppSizes.defaultBorderWidth,
            color: Theme.of(context).colorScheme.outline, // Border color
          )
        ),
        child: Column(
          children: [
            Column(
              spacing: AppSizes.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Number'),
                    Row(
                      spacing: AppSizes.sm,
                      children: [
                        Text(' #${order.id}'),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: order.id.toString()));
                            // You might want to show a snackbar or toast to indicate successful copy
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order Id copied')),
                            );
                          },
                          child: const Icon(Icons.copy, size: 17,),
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Total'),
                    Row(
                      children: [
                        Text('${AppSettings.currencySymbol}${order.total}'),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Date'),
                    Row(
                      children: [
                        Text(AppFormatter.formatDate(order.dateCreated)),
                      ],
                    ),
                  ],
                ),
                Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Status'),
                          Row(
                            spacing: AppSizes.sm,
                            children: [
                              Text(order.status?.prettyName ?? ''),
                            ],
                          ),
                        ],
                      ),
                SizedBox(height: AppSizes.xs),
                OrderImageGallery(cartItems: order.lineItems ?? [], galleryImageHeight: 40),
              ],
            ),
            // Positioned(top: 0, right: 0, child: TOrderHelper.mapOrderStatus(order.status ?? OrderStatus.unknown)),
          ],
        ),
      ),
    );
  }
}
