import 'package:fincom/common/widgets/custom_shape/image/circular_image.dart';
import 'package:fincom/features/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/product/product_controller.dart';
import '../../models/product_model.dart';
import 'add_product.dart';

class SingleProduct extends StatefulWidget {
  const SingleProduct({super.key, required this.product});

  final ProductModel product;

  @override
  State<SingleProduct> createState() => _SingleProductState();
}

class _SingleProductState extends State<SingleProduct> {
  late ProductModel product;
  final productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    product = widget.product;
  }

  Future<void> _refreshProduct() async {
    final updatedProduct = await productController.getProductByID(id: product.id ?? '');
    setState(() {
      product = updatedProduct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Product',
        widgetInActions: TextButton(
          onPressed: () => Get.to(() => AddProducts(product: product)),
          child: Text('Edit', style: TextStyle(color: AppColors.linkColor)),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => _refreshProduct(),
        child: ListView(
          padding: TSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: AppSizes.spaceBtwSection,),
            RoundedImage(
                height: 100,
                width: 100,
                // borderRadius: 100,
                isNetworkImage: true,
                isTapToEnlarge: true,
                image: product.mainImage ?? ''
            ),
            SizedBox(height: AppSizes.spaceBtwSection,),
            Container(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.productVoucherTileRadius),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  Text(product.name ?? '', style: TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Product ID: '),
                      Text('#${product.productId.toString()}', style: TextStyle(fontSize: 14))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Purchase Price'),
                      Text(AppSettings.currencySymbol + (product.purchasePrice ?? 0).toStringAsFixed(2), style: TextStyle(fontSize: 14))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Stock:'),
                      Text(product.stockQuantity.toString(), style: TextStyle(fontSize: 14))
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.spaceBtwSection),
            Heading(title: 'Purchase History', paddingLeft: AppSizes.sm),
            SizedBox(height: AppSizes.spaceBtwItems),
            // if(product.purchaseHistory != null && product.purchaseHistory!.isNotEmpty)
            //   GridLayout(
            //     crossAxisCount: 1,
            //     mainAxisExtent: 105,
            //     itemCount: product.purchaseHistory!.length,
            //     itemBuilder: (context, index) {
            //       final purchase = product.purchaseHistory?[index];
            //       return Container(
            //         padding: const EdgeInsets.all(AppSizes.defaultSpace),
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(AppSizes.productVoucherTileRadius),
            //           color: Theme.of(context).colorScheme.surface,
            //         ),
            //         child: Column(
            //           children: [
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('Date:'),
            //                 Text(AppFormatter.formatStringDate(purchase?.purchaseDate), style: TextStyle(fontSize: 14))
            //               ],
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('Purchase ID:'),
            //                 Text(purchase!.purchaseId.toString(), style: TextStyle(fontSize: 14))
            //               ],
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('Price:'),
            //                 Text(AppSettings.appCurrencySymbol + purchase!.price!.toStringAsFixed(2), style: TextStyle(fontSize: 14))
            //               ]
            //             ),
            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text('Quantity:'),
            //                 Text(purchase.quantity.toString(), style: TextStyle(fontSize: 14))
            //               ]
            //             ),
            //           ]
            //         )
            //       );
            //     }
            //   ),
            SizedBox(height: AppSizes.spaceBtwSection),
            Center(
              child: TextButton(
                onPressed: () => productController.deleteProduct(context: context, id: product.id ?? ''),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
