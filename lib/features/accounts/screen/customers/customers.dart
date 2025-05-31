import 'package:line_icons/line_icons.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/customer/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../products/sync_product.dart';
import 'add_customer.dart';
import 'single_customer.dart';
import 'sync_customer.dart';
import 'widget/customer_tile.dart';
import 'widget/customer_tile_simmer.dart';

class CustomersVoucher extends StatelessWidget {
  const CustomersVoucher({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final controller = Get.put(CustomerController());

    controller.refreshCustomers();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!controller.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (controller.customers.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          controller.isLoadingMore(true);
          controller.currentPage++; // Increment current page
          await controller.getAllCustomers();
          controller.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Customer Found...',
      animation: Images.pencilAnimation,
    );

    return Scaffold(
        appBar: AppAppBar(
          title: 'Customers',
          searchType: SearchType.customer,
          widgetInActions: IconButton(
              onPressed: () => Get.to(() => SyncCustomerScreen()),
              icon: Text('Sync Customers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.linkColor),)
          )
        ),
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () => Get.to(() => AddCustomer()),
          tooltip: 'Add Products',
          child: Icon(LineIcons.plus, size: 30, color: Colors.white,),
        ),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async => controller.refreshCustomers(),
          child: ListView(
            controller: scrollController,
            padding: AppSpacingStyle.defaultPagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return  CustomersTileShimmer(itemCount: 2);
                } else if(controller.customers.isEmpty) {
                  return emptyWidget;
                } else {
                  final customers = controller.customers;
                  return Column(
                    children: [
                      GridLayout(
                          itemCount: controller.isLoadingMore.value ? customers.length + 2 : customers.length,
                          crossAxisCount: 1,
                          mainAxisExtent: AppSizes.customerVoucherTileHeight,
                          itemBuilder: (context, index) {
                            if (index < customers.length) {
                              return CustomerTile(
                                  onTap: () => Get.to(() => SingleCustomer(customer: customers[index])),
                                  customer: customers[index]
                              );
                            } else {
                              return CustomersTileShimmer();
                            }
                          }
                      ),
                    ],
                  );
                }
              })
            ],
          ),
        )
    );
  }
}


