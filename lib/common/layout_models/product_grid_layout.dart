import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/accounts/models/product_model.dart';
import '../../features/accounts/screen/products/widget/product_tile.dart';
import '../../utils/constants/enums.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../dialog_box_massages/animation_loader.dart';
import '../widgets/shimmers/product_voucher_shimmer.dart';

class ProductGridLayout extends StatelessWidget {
  const ProductGridLayout({
    super.key,
    required this.controller,
    this.emptyWidget = const AnimationLoaderWidgets(text: 'Whoops! No products found...', animation: Images.pencilAnimation),
    this.onTap,
  });

  final dynamic controller;
  final Widget emptyWidget;
  final ValueChanged<ProductModel>? onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return  ProductVoucherShimmer(itemCount: 2);
      } else if(controller.products.isEmpty) {
        return emptyWidget;
      } else {
        final products = controller.products;
        return GridLayout(
          itemCount: controller.isLoadingMore.value ? products.length + 2 : products.length,
          crossAxisCount: 1,
          mainAxisExtent: AppSizes.productVoucherTileHeight,
          itemBuilder: (context, index) {
            if (index < products.length) {
              return ProductTile(
                  product: products[index],
                  onTap: () => onTap?.call(products[index]), // Pass the product directly
              );
            } else {
              return ProductVoucherShimmer();
            }
          }
        );
      }
    });
  }
}

class GridLayout extends StatelessWidget {
  const GridLayout({
    super.key,
    required this.itemCount,
    this.crossAxisCount = 1,
    this.crossAxisSpacing = AppSizes.defaultSpaceBWTCard,
    this.mainAxisSpacing = AppSizes.defaultSpaceBWTCard,
    required this.mainAxisExtent,
    required this.itemBuilder,
    this.onDelete,
    this.onEdit,
  });

  final int itemCount, crossAxisCount;
  final double mainAxisExtent, crossAxisSpacing, mainAxisSpacing;
  final Widget Function(BuildContext, int) itemBuilder;
  final void Function(int)? onDelete;
  final void Function(int)? onEdit;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          mainAxisExtent: mainAxisExtent
      ),
      cacheExtent: 50, // Keeps items in memory
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return itemBuilder(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                if (onEdit != null) onEdit!(index);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Delete"),
              onTap: () {
                Navigator.pop(context);
                if (onDelete != null) onDelete!(index);
              },
            ),
          ],
        );
      },
    );
  }
}