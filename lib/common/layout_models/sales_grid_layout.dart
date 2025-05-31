import 'package:ara_finance/features/accounts/screen/sales/widget/sale_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/accounts/screen/sales/widget/sale_shimmer.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../dialog_box_massages/animation_loader.dart';
import 'product_grid_layout.dart';

class SalesGridLayout extends StatelessWidget {
  const SalesGridLayout({
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
        return SaleShimmer(itemCount: 2,);
      } else if(controller.sales.isEmpty) {
        return emptyWidget;
      } else {
        final sales = controller.sales;
        return GridLayout(
            itemCount: controller.isLoadingMore.value ? sales.length + 2 : sales.length,
            crossAxisCount: 1,
            mainAxisExtent: AppSizes.saleTileHeight,
            itemBuilder: (context, index) {
              if (index < sales.length) {
                return SaleTile(sale: sales[index]);
              } else {
                return SaleShimmer();
              }
            }
        );
      }
    });
  }
}
