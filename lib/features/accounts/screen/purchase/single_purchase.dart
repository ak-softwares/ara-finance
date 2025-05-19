import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/layout_models/product_list_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../../settings/app_settings.dart';
import '../../controller/purchase/purchase_controller.dart';
import '../../models/order_model.dart';
import '../../models/transaction_model.dart';
import '../products/widget/product_cart_tile.dart';
import '../transaction/widget/transaction_tile.dart';
import '../vendor/single_vendor.dart';
import 'add_new_purchase.dart';


class SinglePurchase extends StatefulWidget {
  const SinglePurchase({super.key, required this.purchase});

  final OrderModel purchase;

  @override
  State<SinglePurchase> createState() => _SinglePurchaseState();
}

class _SinglePurchaseState extends State<SinglePurchase> {
  late OrderModel purchase;
  final PurchaseController purchaseController = Get.find<PurchaseController>();

  @override
  void initState() {
    super.initState();
    purchase = widget.purchase; // Initialize with the passed purchase
  }

  Future<void> _refreshPurchase() async {
      final updatedPurchase = await purchaseController.getPurchaseById(purchaseId: purchase.id ?? '');
      setState(() {
        purchase = updatedPurchase; // Update the purchase data
      });
  }

  @override
  Widget build(BuildContext context) {
    const double cartTileHeight = AppSizes.cartTileHeight;

    return Scaffold(
      appBar: AppAppBar(
        title: 'Purchase #${purchase.invoiceNumber}',
        widgetInActions: TextButton(
            onPressed: () => Get.to(() => AddNewPurchase(previousPurchase: purchase)),
            child: Text('Edit', style: TextStyle(color: AppColors.linkColor),)
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => _refreshPurchase(),
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Column(
              spacing: AppSizes.spaceBtwSection,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Number'),
                        Text('#${purchase.invoiceNumber}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date'),
                        Text(AppFormatter.formatDate(purchase.dateCreated)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vendor'),
                        InkWell(
                            onTap: () => purchase.user != null ? Get.to(() => SingleVendor(vendor: purchase.user!)) : {},
                            child: Text(purchase.user?.companyName ?? '', style: TextStyle(color: Colors.blue),)
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total'),
                        Text(purchase.total.toString()),
                      ],
                    ),
                    Container(
                      height: 1,
                      color: AppColors.borderDark,
                    ),
                  ],
                ),


                // Products
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Text('Products ${purchase.lineItems?.length.toString()}'),
                    GridLayout(
                        itemCount: purchase.lineItems?.length ?? 0,
                        crossAxisCount: 1,
                        mainAxisExtent: cartTileHeight,
                        itemBuilder: (context, index) {
                          return ProductCartTile(cartItem: purchase.lineItems![index], orderType: OrderType.purchase,);
                        }
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total'),
                        Text(AppSettings.currencySymbol + purchase.total.toString()),
                      ],
                    )
                  ],
                ),

                // Transaction
                TransactionTile(transaction: purchase.transaction ?? TransactionModel()),

                // Image of Invoice
                if(purchase.purchaseInvoiceImages != null && purchase.purchaseInvoiceImages!.isNotEmpty)
                  Column(
                  spacing: AppSizes.spaceBtwItems,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Image'),
                    ListLayout(
                        height: 150,
                        itemCount: purchase.purchaseInvoiceImages?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Padding(
                                padding: EdgeInsets.only(right: AppSizes.sm),
                                child: RoundedImage(
                                  height: 150,
                                  width: 100,
                                  fit: BoxFit.cover,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  borderRadius: 15,
                                  isNetworkImage: true,
                                  image: purchase.purchaseInvoiceImages?[index].imageUrl ?? '',
                                  isTapToEnlarge: true,
                                )
                            );
                        }
                    )
                  ],
                ),

                Center(child: TextButton(
                    onPressed: () => purchaseController.confirmDeletePurchaseDialog(purchase: purchase, context: context),
                    child: Text('Delete', style: TextStyle(color: Colors.red),))
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

