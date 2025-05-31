import 'package:ara_finance/features/accounts/screen/purchase/widget/purchase_shimmer.dart';
import 'package:ara_finance/features/accounts/screen/sales/widget/sale_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/accounts/screen/purchase/widget/purchase_tile.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../dialog_box_massages/animation_loader.dart';
import 'product_grid_layout.dart';

class PurchaseGridLayout extends StatelessWidget {
  const PurchaseGridLayout({
    super.key,
    required this.controller,
    this.emptyWidget = const AnimationLoaderWidgets(text: 'Whoops! No Sale found...', animation: Images.pencilAnimation),
  });

  final dynamic controller;
  final Widget emptyWidget;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return PurchaseShimmer(itemCount: 2);
      } else if(controller.purchases.isEmpty) {
        return emptyWidget;
      } else {
        final purchases = controller.purchases;
        return GridLayout(
            itemCount: controller.isLoadingMore.value ? purchases.length + 2 : purchases.length,
            crossAxisCount: 1,
            mainAxisExtent: AppSizes.saleTileHeight,
            itemBuilder: (context, index) {
              if (index < purchases.length) {
                return PurchaseTile(purchase: purchases[index]);
              } else {
                return PurchaseShimmer();
              }
            }
        );
      }
    });
  }
}
