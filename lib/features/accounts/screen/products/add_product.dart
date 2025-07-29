import 'package:ara_finance/features/accounts/screen/account_voucher/widget/account_voucher_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/product/add_product_controller.dart';
import '../../models/account_voucher_model.dart';
import '../../models/product_model.dart';
import '../search/search_and_select/search_products.dart';

class AddProducts extends StatelessWidget {
  const AddProducts({super.key, this.product});

  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    final AddProductController controller = Get.put(AddProductController());

    if (product != null) {
      controller.resetProductValues(product!);
    }

    return Scaffold(
      appBar: AppAppBar(title: product != null ? 'Update Product' : 'Add Product'),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => product != null ? controller.saveUpdatedProduct(previousProduct: product!) : controller.saveProduct(),
          child: Text(product != null ? 'Update Product' : 'Add Product', style: TextStyle(fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: controller.productFormKey,
            child: Column(
              spacing: AppSizes.spaceBtwItems,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Product ID'),
                  ],
                ),

                // Name
                TextFormField(
                  controller: controller.productTitleController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                // Purchase Price
                TextFormField(
                  controller: controller.purchasePriceController,
                  decoration: InputDecoration(
                    labelText: 'Purchase Price',
                    border: OutlineInputBorder(),
                  ),
                ),

                // openingStock
                TextFormField(
                  controller: controller.openingStock,
                  decoration: InputDecoration(
                    labelText: 'Opening Stock',
                    border: OutlineInputBorder(),
                  ),
                ),

                // HSN
                TextFormField(
                  controller: controller.hsnCode,
                  decoration: InputDecoration(
                    labelText: 'HSN Code',
                    border: OutlineInputBorder(),
                  ),
                ),

                // Tax Rate
                DropdownButtonFormField<TaxRate>(
                  value: controller.selectedTaxRate, // must be a reactive or state value
                  onChanged: (TaxRate? newValue) {
                    if (newValue != null) {
                      controller.selectedTaxRate = newValue;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Tax Rate',
                    border: OutlineInputBorder(),
                  ),
                  items: TaxRate.values.map((rate) {
                    return DropdownMenuItem(
                      value: rate,
                      child: Text(rate.label),
                    );
                  }).toList(),
                ),


                // Vendor
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select vendor'),
                        InkWell(
                          onTap: () async {
                            // Navigate to the search screen and wait for the result
                            final AccountVoucherModel getSelectedVendor = await showSearch(context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.vendor),
                            );
                            // If products are selected, update the state
                            if (getSelectedVendor.id != null) {
                              controller.addVendor(getSelectedVendor);
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
                    Obx(() => controller.selectedVendor.value.id != null
                        ? Dismissible(
                        key: Key(controller.selectedVendor.value.id ?? ''), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe left to remove
                        onDismissed: (direction) {
                          controller.selectedVendor.value = AccountVoucherModel();
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vendor removed")),);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: AccountVoucherTile(accountVoucher: controller.selectedVendor.value, voucherType: AccountVoucherType.vendor))
                    )
                        : SizedBox.shrink(),
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
