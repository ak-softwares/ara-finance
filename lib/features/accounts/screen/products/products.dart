import 'package:line_icons/line_icons.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets/common/colored_amount.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/product/product_controller.dart';
import 'add_product.dart';
import 'sync_product.dart';
import 'widget/product_shimmer.dart';
import 'widget/product_tile.dart';

class Products extends StatelessWidget {
  const Products({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final controller = Get.put(ProductController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshProducts();
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!controller.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (controller.products.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          controller.isLoadingMore(true);
          controller.currentPage++; // Increment current page
          await controller.getAllProducts();
          controller.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Products Found...',
      animation: Images.pencilAnimation,
    );

    return Scaffold(
        appBar: AppAppBar(
            title: 'Products',
            showSearchIcon: true,
            searchType: SearchType.product,
            widgetInActions: IconButton(
                onPressed: () => Get.to(() => SyncProductScreen()),
                icon: Text('Sync Products', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.linkColor),)
            )
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'product',
          shape: CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () => Get.to(() => AddProducts()),
          tooltip: 'Add Products',
          child: Icon(LineIcons.plus, size: 30, color: Colors.white,),
        ),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async => controller.refreshProducts(),
          child: ListView(
            controller: scrollController,
            padding: AppSpacingStyle.defaultPagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
            // Product Info Card
              Obx(() {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: AppSizes.defaultSpace),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inventory Summary', style: TextStyle(fontSize: 20)),
                        const SizedBox(height: AppSizes.sm),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Products:', style: TextStyle(fontSize: 14)),
                            Text('${controller.totalProducts}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Active Products:', style: TextStyle(fontSize: 14)),
                            Text('${controller.totalActiveProducts}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Stock Value:', style: TextStyle(fontSize: 14)),
                            ColoredAmount(amount: controller.totalStockValue.toDouble())
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              Obx(() {
                if (controller.isLoading.value) {
                    return  ProductTileShimmer(itemCount: 2);
                } else if(controller.products.isEmpty) {
                    return emptyWidget;
                } else {
                  final products = controller.products;
                  return GridLayout(
                    itemCount: controller.isLoadingMore.value ? products.length + 2 : products.length,
                    crossAxisCount:  1,
                    mainAxisExtent: AppSizes.productVoucherTileHeight,
                    itemBuilder: (context, index) {
                      if (index < products.length) {
                        return ProductTile(product: products[index]);
                      } else {
                        return ProductTileShimmer();
                      }
                    }
                  );
                }
              })
            ],
          ),
        )
    );
  }
}

