import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../../common/layout_models/product_list_layout.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../../../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/formatters/formatters.dart';
import '../../../../../settings/app_settings.dart';
import '../../../../controller/transaction/purchase/add_purchase_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../../models/product_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import '../../../search/search_and_select/search_products.dart';
import 'widget/product_tile.dart';

class AddPurchase extends StatelessWidget {
  const AddPurchase({super.key, this.purchase});

  final TransactionModel? purchase;

  @override
  Widget build(BuildContext context) {
    const double purchaseProductTileHeight = AppSizes.purchaseProductTileHeight;
    final AddPurchaseTransactionController controller = Get.put(AddPurchaseTransactionController());

    if (purchase != null) {
      controller.resetValue(purchase!);
    }

    return Scaffold(
      appBar: AppAppBar(title: purchase != null ? 'Update Purchase' : 'Add Purchase'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => purchase != null
              ? controller.saveUpdatedPurchaseTransaction(oldPurchaseTransaction: purchase!)
              : controller.savePurchaseTransaction(),
          child: Text(
            purchase != null ? 'Update Purchase' : 'Add Purchase',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.purchaseFormKey,
            child: Column(
              spacing: AppSizes.spaceBtwSection,
              children: [

                // Transaction ID and Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Transaction ID - '),
                        purchase != null
                            ? Text('#${purchase!.transactionId}', style: const TextStyle(fontSize: 14))
                            : Obx(() => Text('#${controller.transactionId.value}', style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: controller.date,
                      builder: (context, value, child) {
                        return InkWell(
                          onTap: () => controller.selectDate(context),
                          child: Row(
                            children: [
                              Text('Date - '),
                              Text(AppFormatter.formatStringDate(controller.date.text),
                                style: TextStyle(color: AppColors.linkColor),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Select Vendor
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Vendor'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedVendor = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.vendor),
                            );
                            if (getSelectedVendor.id != null) {
                              controller.selectedVendor(getSelectedVendor);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add, color: AppColors.linkColor),
                              Text('Add', style: TextStyle(color: AppColors.linkColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.selectedVendor.value.id != null
                        ? Dismissible(
                        key: Key(controller.selectedVendor.value.id ?? ''),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          controller.selectedVendor.value = AccountVoucherModel();
                          AppMassages.showSnackBar(massage: 'Vendor removed');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(
                            width: double.infinity,
                            child: AccountVoucherTile(accountVoucher: controller.selectedVendor.value, voucherType: AccountVoucherType.customer)
                        )
                    )
                        : SizedBox.shrink(),
                    ),
                  ],
                ),

                // Select Purchase Account
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Purchase Voucher'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedPurchaseVoucher = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.purchase),
                            );
                            if (getSelectedPurchaseVoucher.id != null) {
                              controller.selectedPurchaseVoucher(getSelectedPurchaseVoucher);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add, color: AppColors.linkColor),
                              Text('Add', style: TextStyle(color: AppColors.linkColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.selectedPurchaseVoucher.value.id != null
                        ? Dismissible(
                              key: Key(controller.selectedPurchaseVoucher.value.id ?? ''),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                controller.selectedPurchaseVoucher.value = AccountVoucherModel();
                                AppMassages.showSnackBar(massage: 'Purchase Voucher removed');
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: AccountVoucherTile(accountVoucher: controller.selectedPurchaseVoucher.value, voucherType: AccountVoucherType.purchase)
                              )
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
                        Text('Select Products'),
                        InkWell(
                          onTap: () async {
                            // Navigate to the search screen and wait for the result
                            final List<ProductModel> getSelectedProducts = await showSearch(context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.product),
                            );
                            // If products are selected, update the state
                            if (getSelectedProducts.isNotEmpty) {
                              controller.addProducts(getSelectedProducts);
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
                        itemCount: controller.selectedProducts.length,
                        crossAxisCount: 1,
                        mainAxisExtent: purchaseProductTileHeight,
                        itemBuilder: (context, index) {
                          return Dismissible(
                              key: Key(controller.selectedProducts[index].id.toString()), // Unique key for each item
                              direction: DismissDirection.endToStart, // Swipe left to remove
                              onDismissed: (direction) {
                                controller.removeProducts(controller.selectedProducts[index]);
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
                                    cartItem: controller.selectedProducts[index],
                                    controller: controller,
                                    orderType: OrderType.purchase,
                                  )
                              )
                          );
                        }
                    )),
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Product Count - ${(controller.selectedProducts.length).toStringAsFixed(0)}'),
                        Text('Total - ${AppSettings.currencySymbol + (controller.purchaseTotal.value).toStringAsFixed(0)}'),
                      ],
                    ))
                  ],
                ),

                // Upload purchase invoice
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upload Invoice Image'),
                    Obx(() => ListLayout(
                        height: 150,
                        itemCount: controller.purchaseInvoiceImages.length + 1,
                        itemBuilder: (context, index) {
                          if(index == controller.purchaseInvoiceImages.length) { // if index is last index
                            return InkWell(
                              onTap: controller.pickImage,
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
                                      isFileImage: controller.purchaseInvoiceImages[index].imageUrl == null ? true : false,
                                      isNetworkImage: controller.purchaseInvoiceImages[index].imageUrl == null ? false : true,
                                      image: controller.purchaseInvoiceImages[index].imageUrl == null
                                          ? controller.purchaseInvoiceImages[index].image?.path ?? ''
                                          : controller.purchaseInvoiceImages[index].imageUrl ?? '',
                                      isTapToEnlarge: true,
                                    ),
                                    Positioned(
                                        top: -5,
                                        right: -5,
                                        child: IconButton(onPressed: () => controller.deleteImage(controller.purchaseInvoiceImages[index]), icon: Icon(Icons.cancel), color: Colors.grey.shade200.withOpacity(0.8))
                                    ),
                                    Positioned(
                                        bottom: 10,
                                        left: 5,
                                        right: 5, // This ensures it's centered horizontally
                                        child: SizedBox(
                                            height: 30,
                                            child: controller.purchaseInvoiceImages[index].imageUrl == null || controller.purchaseInvoiceImages[index].imageUrl!.isEmpty
                                                ? ElevatedButton(
                                                onPressed: () => controller.uploadImage(controller.purchaseInvoiceImages[index]),
                                                style: ButtonStyle(
                                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 5, vertical: 0)), // Padding
                                                  textStyle: MaterialStateProperty.all(TextStyle(fontSize: 12, fontWeight: FontWeight.w500)), // Text Style
                                                  fixedSize: MaterialStateProperty.all(Size(80, 25)), // Set width & height Set width & height
                                                ),
                                                child: !controller.isUploadingImage.value
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
                                                onPressed: () => controller.deleteImage(controller.purchaseInvoiceImages[index]),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                                  textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                                                  fixedSize: Size(80, 25),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))), // Remove rounded corners
                                                ),
                                                child: !controller.isDeletingImage.value
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
        ),
      ),
    );
  }
}
