import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/accounts/screen/orders/widgets/order_tile.dart';
import '../../features/accounts/screen/sales/widget/sale_tile_simmer.dart';
import '../../utils/constants/enums.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../dialog_box_massages/animation_loader.dart';
import 'product_grid_layout.dart';

class OrdersGridLayout extends StatelessWidget {
  const OrdersGridLayout({
    super.key,
    required this.controller,
    required this.sourcePage,
    this.orientation = OrientationType.horizontal,
    this.emptyWidget = const AnimationLoaderWidgets(text: 'Whoops! No products found...', animation: Images.pencilAnimation),
  });

  final dynamic controller;
  final String sourcePage;
  final OrientationType orientation;
  final Widget emptyWidget;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return OrderShimmer(itemCount: 2,);
      } else if(controller.sales.isEmpty) {
        return emptyWidget;
      } else {
        final orders = controller.sales;
        return GridLayout(
            itemCount: controller.isLoadingMore.value ? orders.length + 2 : orders.length,
            crossAxisCount: orientation == OrientationType.vertical ? 2 : 1,
            mainAxisExtent: AppSizes.orderTileHeight,
            itemBuilder: (context, index) {
              if (index < orders.length) {
                return OrderTile(order: orders[index]);
              } else {
                return OrderShimmer();
              }
            }
        );
      }
    });
  }
}
