import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import 'package:line_icons/line_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets/shimmers/order_shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/sales_controller/sales_controller.dart';
import 'common/add_barcode_sale.dart';
import 'common/add_return_barcode.dart';
import 'add_sale.dart';
import 'common/update_payment.dart';
import 'widget/sale_shimmer.dart';
import 'widget/sale_tile.dart';

class Sales extends StatelessWidget {
  const Sales({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final controller = Get.put(SaleController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshSales();
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!controller.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (controller.sales.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          controller.isLoadingMore(true);
          controller.currentPage++; // Increment current page
          await controller.getSales();
          controller.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Orders Found...',
      animation: Images.pencilAnimation,
    );
    
    return Scaffold(
        appBar: AppAppBar(
          title: 'Sales',
          searchType: SearchType.sale,
          widgetInActions: Row(
            children: [
              IconButton(
                onPressed: () => Get.to(() => AddBarcodeSale()),
                icon: Icon(Icons.qr_code_scanner_outlined),
              ),
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          heroTag: 'sales_fab',
          backgroundColor: Colors.blue,
          icon: LineIcons.plus,
          activeIcon: Icons.close,
          foregroundColor: Colors.white,
          spacing: 10,
          spaceBetweenChildren: 8,
          shape: const CircleBorder(),
          tooltip: 'Actions',
          children: [
            SpeedDialChild(
              child: Icon(Icons.add_shopping_cart, color: Colors.white),
              backgroundColor: Colors.green,
              label: 'New Sale',
              onTap: () => Get.to(() => AddNewSale()),
            ),
            SpeedDialChild(
              child: Icon(Icons.add_shopping_cart, color: Colors.white),
              backgroundColor: Colors.blue,
              label: 'Add Bulk Sale',
              onTap: () {
                Get.to(() => AddBarcodeSale());
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.sync, color: Colors.white),
              backgroundColor: Colors.orange,
              label: 'Add Return',
              onTap: () {
                Get.to(() => AddReturnBarcode());
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.receipt_long, color: Colors.white),
              backgroundColor: Colors.blue,
              label: 'Update Payment',
              onTap: () {
                Get.to(() => OrderNumbersView());
              },
            ),
            // Add more submenu buttons as needed
          ],
        ),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async => controller.refreshSales(),
          child: ListView(
            controller: scrollController,
            padding: AppSpacingStyle.defaultPagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return SaleShimmer(itemCount: 2,);
                } else if(controller.sales.isEmpty) {
                  return emptyWidget;
                } else {
                  final sales = controller.sales;
                  return GridLayout(
                      itemCount: controller.isLoadingMore.value ? sales.length + 2 : sales.length,
                      crossAxisCount:  1,
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
              }),
            ],
          ),
        )
    );
  }
}
