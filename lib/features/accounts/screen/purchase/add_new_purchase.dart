import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/layout_models/product_list_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../../personalization/models/user_model.dart';
import '../../../settings/app_settings.dart';
import '../../controller/purchase/add_purchase_controller.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../vendor/widget/vendor_tile.dart';
import 'purchase_entry/widget/search_products.dart';
import 'widget/product_tile.dart';

class AddNewPurchase extends StatelessWidget {
  const AddNewPurchase({super.key, this.previousPurchase});

  final OrderModel? previousPurchase;

  @override
  Widget build(BuildContext context) {
    const double purchaseProductTileHeight = AppSizes.purchaseProductTileHeight;
    final addPurchaseController = Get.put(AddPurchaseController());

    final clonedPreviousPurchase = previousPurchase?.copyWith(
        lineItems: previousPurchase?.lineItems?.map((item) => item.copyWith()).toList()
    );

    if (clonedPreviousPurchase != null) {
      addPurchaseController.resetValue(purchase: clonedPreviousPurchase);
    } else{
      addPurchaseController.dateController.text = DateTime.now().toString();
    }

    return Scaffold(
      appBar: AppAppBar(title: previousPurchase != null ? 'Update purchase' : 'Add new purchase'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () => previousPurchase != null
              ? addPurchaseController.saveUpdatedPurchase(oldPurchase: previousPurchase!)
              : addPurchaseController.savePurchase(),
          child: Text(previousPurchase != null ? 'Update Purchase' : 'Add Purchase', style: TextStyle(fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacingStyle.defaultPagePadding,
        child: Column(
          spacing: AppSizes.spaceBtwSection,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Voucher number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Purchase Number - '),
                    previousPurchase != null
                        ? Text('#${previousPurchase!.invoiceNumber}')
                        : Obx(() => Text(addPurchaseController.invoiceId.value.toString())),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: addPurchaseController.dateController,
                  builder: (context, value, child) {
                    return InkWell(
                      onTap: () => addPurchaseController.selectDate(context),
                      child: Row(
                        children: [
                          Text('Date - '),
                          Text(AppFormatter.formatStringDate(addPurchaseController.dateController.text),
                            style: TextStyle(color: AppColors.linkColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            // Vendor
            Column(
              spacing: AppSizes.spaceBtwItems,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vendor'),
                    InkWell(
                      onTap: () async {
                        // Navigate to the search screen and wait for the result
                        final UserModel getSelectedVendor = await showSearch(context: context,
                          delegate: SearchVoucher1(
                              searchType: SearchType.vendor,
                              selectedItems: addPurchaseController.selectedSupplier.value
                          ),
                        );
                        // If products are selected, update the state
                        if (getSelectedVendor.companyName != null) {
                          addPurchaseController.addSupplier(getSelectedVendor);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add, color: AppColors.linkColor),
                          Text('Add', style:  TextStyle(color: AppColors.linkColor),)
                        ],
                      ),
                    ),
                  ],
                ),
                Obx(() => addPurchaseController.selectedSupplier.value.companyName != '' && addPurchaseController.selectedSupplier.value.companyName != null
                    ? Dismissible(
                          key: Key(addPurchaseController.selectedSupplier.value.companyName ?? ''), // Unique key for each item
                          direction: DismissDirection.endToStart, // Swipe left to remove
                          onDismissed: (direction) {
                            addPurchaseController.selectedSupplier.value = UserModel();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vendor removed")),);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: SizedBox(width: double.infinity, child: VendorTile(vendor: addPurchaseController.selectedSupplier.value))
                      )
                    : SizedBox.shrink(),
                ),
              ],
            ),

            // Products
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: AppSizes.spaceBtwItems,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Products'),
                    InkWell(
                      onTap: () async {
                        // Navigate to the search screen and wait for the result
                        final List<ProductModel> getSelectedProducts = await showSearch(context: context,
                          delegate: SearchVoucher1(searchType: SearchType.products),
                        );
                        // If products are selected, update the state
                        if (getSelectedProducts.isNotEmpty) {
                          addPurchaseController.addProducts(getSelectedProducts);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add, color: AppColors.linkColor),
                          Text('Add', style:  TextStyle(color: AppColors.linkColor),)
                        ],
                      ),
                    ),
                  ],
                ),
                Obx(() => GridLayout(
                    itemCount: addPurchaseController.selectedProducts.length,
                    crossAxisCount: 1,
                    mainAxisExtent: purchaseProductTileHeight,
                    itemBuilder: (context, index) {
                      return Dismissible(
                          key: Key(addPurchaseController.selectedProducts[index].id.toString()), // Unique key for each item
                          direction: DismissDirection.endToStart, // Swipe left to remove
                          onDismissed: (direction) {
                            addPurchaseController.removeProducts(addPurchaseController.selectedProducts[index]);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item removed")),);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: SizedBox(
                              width: double.infinity,
                              child: PurchaseProductCard(
                                  cartItem: addPurchaseController.selectedProducts[index],
                                  controller: addPurchaseController,
                                  orderType: OrderType.purchase,
                              )
                          )
                      );
                    }
                )),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Product Count - ${(addPurchaseController.selectedProducts.length).toStringAsFixed(0)}'),
                    Text('Total - ${AppSettings.currencySymbol + (addPurchaseController.purchaseTotal.value).toStringAsFixed(0)}'),
                  ],
                ))
              ],
            ),

            Column(
              spacing: AppSizes.spaceBtwItems,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upload Invoice Image'),
                Obx(() => ListLayout(
                    height: 150,
                    itemCount: addPurchaseController.purchaseInvoiceImages.length + 1,
                    itemBuilder: (context, index) {
                      if(index == addPurchaseController.purchaseInvoiceImages.length) { // if index is last index
                        return InkWell(
                          onTap: addPurchaseController.pickImage,
                          child: RoundedContainer(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              radius: 15,
                              height: 150,
                              width: 100,
                              child: Icon(Iconsax.image, color: Theme.of(context).colorScheme.onSurfaceVariant)
                          ),
                        );
                      } else {
                        return Obx(() => Padding(
                              padding: EdgeInsets.only(right: AppSizes.sm),
                              child: Stack(
                                children: [
                                  RoundedImage(
                                    height: 150,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    backgroundColor: Theme.of(context).colorScheme.surface,
                                    borderRadius: 15,
                                    isFileImage: addPurchaseController.purchaseInvoiceImages[index].imageUrl == null ? true : false,
                                    isNetworkImage: addPurchaseController.purchaseInvoiceImages[index].imageUrl == null ? false : true,
                                    image: addPurchaseController.purchaseInvoiceImages[index].imageUrl == null
                                        ? addPurchaseController.purchaseInvoiceImages[index].image?.path ?? ''
                                        : addPurchaseController.purchaseInvoiceImages[index].imageUrl ?? '',
                                    isTapToEnlarge: true,
                                  ),
                                  Positioned(
                                      top: -5,
                                      right: -5,
                                      child: IconButton(onPressed: () => addPurchaseController.deleteImage(addPurchaseController.purchaseInvoiceImages[index]), icon: Icon(Icons.cancel), color: Colors.grey.shade200.withOpacity(0.8))
                                  ),
                                  Positioned(
                                      bottom: 10,
                                      left: 5,
                                      right: 5, // This ensures it's centered horizontally
                                      child: SizedBox(
                                          height: 30,
                                          child: addPurchaseController.purchaseInvoiceImages[index].imageUrl == null || addPurchaseController.purchaseInvoiceImages[index].imageUrl!.isEmpty
                                              ? ElevatedButton(
                                                    onPressed: () => addPurchaseController.uploadImage(addPurchaseController.purchaseInvoiceImages[index]),
                                                    style: ButtonStyle(
                                                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5, vertical: 0)), // Padding
                                                      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 12, fontWeight: FontWeight.w500)), // Text Style
                                                      fixedSize: MaterialStateProperty.all(Size(80, 25)), // Set width & height Set width & height
                                                    ),
                                                    child: !addPurchaseController.isUploadingImage.value
                                                        ? Row(
                                                            mainAxisSize: MainAxisSize.min, // Ensures row takes only required space
                                                            spacing: AppSizes.xs,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text('Upload'),
                                                              Icon(Icons.upload, color: Colors.white, ),
                                                            ],
                                                          )
                                                        : SizedBox(height: 10, width: 10, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                                                )
                                              : TextButton(
                                                    onPressed: () => addPurchaseController.deleteImage(addPurchaseController.purchaseInvoiceImages[index]),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                                      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                                                      fixedSize: Size(80, 25),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))), // Remove rounded corners
                                                    ),
                                                    child: !addPurchaseController.isDeletingImage.value
                                                        ? Row(
                                                      mainAxisSize: MainAxisSize.min, // Ensures row takes only required space
                                                      spacing: AppSizes.xs,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text('Delete', style: TextStyle(color: Colors.white),),
                                                        Icon(Icons.delete, color: Colors.white),
                                                      ],
                                                    )
                                                  : SizedBox(height: 10, width: 10, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                                          )
                                      )
                                  )
                                ],
                              )
                          ),
                        );
                      }
                    }
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

