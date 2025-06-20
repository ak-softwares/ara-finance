import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../settings/app_settings.dart';
import '../../../controller/product/product_controller.dart';
import '../../../models/product_model.dart';
import '../add_product.dart';
import '../single_product.dart';
import 'product_title.dart';


class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    this.onTap,

  });

  final ProductModel product;
  final VoidCallback? onTap; // Make it nullable


  @override
  Widget build(BuildContext context) {
    const double productVoucherTileHeight = AppSizes.productVoucherTileHeight;
    const double productVoucherTileWidth = AppSizes.productVoucherTileWidth;
    const double productVoucherTileRadius = AppSizes.productVoucherTileRadius;
    const double productVoucherImageHeight = AppSizes.productVoucherImageHeight;
    const double productVoucherImageWidth = AppSizes.productVoucherImageWidth;

    return InkWell(
        onTap: onTap ?? () {
          // Default navigation when onTap is not provided
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => SingleProduct(product: product)));
        },
        onLongPress: () => showMenuBottomSheet(context: context),
        child: Container(
          width: productVoucherTileWidth,
          padding: const EdgeInsets.all(AppSizes.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(productVoucherTileRadius),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              // Main Image
              RoundedImage(
                  image: product.mainImage ?? '',
                  height: productVoucherImageHeight,
                  width: productVoucherImageWidth,
                  borderRadius: productVoucherTileRadius,
                  isNetworkImage: true,
                  padding: 0
              ),

              // Title, Rating and price
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSizes.sm),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      ProductTitle(title: product.title ?? '', size: 13, maxLines: 1),

                      // Supplier
                      if(product.vendor != null)
                        Text('Vendor: ${product.vendor?.title ?? ''}'),

                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Stock ${product.stockQuantity}',
                            style: TextStyle(
                              fontSize: 14,
                              color: product.stockQuantity == null || product.stockQuantity == 0
                                  ? null
                                  : product.stockQuantity! < 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),

                          // Price
                          Text('Purchase Price ${AppSettings.currencySymbol + product.purchasePrice.toString()}'),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
  void showMenuBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                icon: Icons.edit,
                title: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => AddProducts(product: product));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.delete,
                title: "Delete",
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  Get.put(ProductController()).deleteProduct(context: context, id: product.id ?? '');
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        bool isDestructive = false,
        required VoidCallback onTap,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? colorScheme.error
                  : colorScheme.onSurface.withOpacity(0.8),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}










