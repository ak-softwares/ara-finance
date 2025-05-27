import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/models/user_model.dart';
import '../../controller/product/add_product_controller.dart';
import '../../models/product_model.dart';
import '../purchase/purchase_entry/widget/search_products.dart';
import '../vendor/widget/vendor_tile.dart';

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
                TextFormField(
                  controller: controller.productTitleController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                ),

                TextFormField(
                  controller: controller.purchasePriceController,
                  decoration: InputDecoration(
                    labelText: 'Purchase Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                TextFormField(
                  controller: controller.stockController,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
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
                              delegate: SearchVoucher1(searchType: SearchType.vendor),
                            );
                            // If products are selected, update the state
                            if (getSelectedVendor.id != null) {
                              controller.addSupplier(getSelectedVendor);
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
                          controller.selectedVendor.value = UserModel();
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vendor removed")),);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: VendorTile(vendor: controller.selectedVendor.value))
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
