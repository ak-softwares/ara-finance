import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/accounts/screen/customers/widget/customer_tile.dart';
import '../../features/accounts/screen/customers/widget/customer_tile_simmer.dart';
import '../../utils/constants/enums.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../dialog_box_massages/animation_loader.dart';
import 'product_grid_layout.dart';

class CustomersGridLayout extends StatelessWidget {
  const CustomersGridLayout({
    super.key,
    required this.controller,
    this.orientation = OrientationType.horizontal,
    this.emptyWidget = const AnimationLoaderWidgets(text: 'Whoops! No products found...', animation: Images.pencilAnimation),
  });

  final dynamic controller;
  final OrientationType orientation;
  final Widget emptyWidget;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return  CustomersTileShimmer(itemCount: 2);
      } else if(controller.users.isEmpty) {
        return emptyWidget;
      } else {
        final customers = controller.users.value;
        return Column(
          children: [
            GridLayout(
                itemCount: controller.isLoadingMore.value ? customers.length + 2 : customers.length,
                crossAxisCount: 1,
                mainAxisExtent: AppSizes.customerVoucherTileHeight,
                itemBuilder: (context, index) {
                  if (index < customers.length) {
                    return CustomerTile(customer: customers[index]);
                  } else {
                    return CustomersTileShimmer();
                  }
                }
            ),
          ],
        );
      }
    });
  }
}
