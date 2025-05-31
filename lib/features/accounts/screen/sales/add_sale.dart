import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../../personalization/models/user_model.dart';
import '../../../settings/app_settings.dart';
import '../../controller/sales_controller/add_sale_controller.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../customers/widget/customer_tile.dart';
import '../purchase/purchase_entry/widget/search_products.dart';
import '../purchase/widget/product_tile.dart';
import '../search/search.dart';
import '../vendor/widget/vendor_tile.dart';

class AddNewSale extends StatelessWidget {
  const AddNewSale({super.key, this.previousSale});

  final OrderModel? previousSale;

  @override
  Widget build(BuildContext context) {
    const double saleProductTileHeight = AppSizes.saleProductTileHeight;
    final addSaleController = Get.put(AddSaleController());

    final clonedPreviousSale = previousSale?.copyWith(
        lineItems: previousSale?.lineItems?.map((item) => item.copyWith()).toList()
    );

    if (clonedPreviousSale != null) {
      addSaleController.resetValue(sale: clonedPreviousSale);
    } else{
      addSaleController.dateController.text = DateTime.now().toString();
    }

    return Scaffold(
      appBar: AppAppBar(title: previousSale != null ? 'Update sale' : 'Add new sale'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () => previousSale != null
              ? addSaleController.saveUpdatedSale(previousSale: previousSale!)
              : addSaleController.saveSale(),
          child: Text(previousSale != null ? 'Update Sale' : 'Add Sale', style: TextStyle(fontSize: 16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacingStyle.defaultPagePadding,
        child: Column(
          spacing: AppSizes.spaceBtwSection,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Invoice number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Invoice Number - '),
                    previousSale != null
                        ? Text('#${previousSale!.invoiceNumber}')
                        : Obx(() => Text(addSaleController.invoiceId.value.toString())),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: addSaleController.dateController,
                  builder: (context, value, child) {
                    return InkWell(
                      onTap: () => addSaleController.selectDate(context),
                      child: Row(
                        children: [
                          Text('Date - '),
                          Text(AppFormatter.formatStringDate(addSaleController.dateController.text),
                            style: TextStyle(color: AppColors.linkColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            // Customer
            Column(
              spacing: AppSizes.spaceBtwItems,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customer'),
                    InkWell(
                      onTap: () async {
                        // Navigate to the search screen and wait for the result
                        final UserModel getSelectedCustomer = await showSearch(context: context,
                          delegate: SearchVoucher1(
                              searchType: SearchType.customer,
                              selectedItems: addSaleController.selectedCustomer.value
                          ),
                        );
                        // If customer is selected, update the state
                        if (getSelectedCustomer.name != null) {
                          addSaleController.addCustomer(getSelectedCustomer);
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
                Obx(() => addSaleController.selectedCustomer.value.name != '' && addSaleController.selectedCustomer.value.name != null
                    ? Dismissible(
                          key: Key(addSaleController.selectedCustomer.value.name ?? ''), // Unique key for each item
                          direction: DismissDirection.endToStart, // Swipe left to remove
                          onDismissed: (direction) {
                            addSaleController.selectedCustomer.value = UserModel();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Customer removed")),);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: SizedBox(width: double.infinity, child: CustomerTile(customer: addSaleController.selectedCustomer.value))
                      )
                    : SizedBox.shrink()),
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
                          addSaleController.addProducts(getSelectedProducts);
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
                    itemCount: addSaleController.selectedProducts.length,
                    crossAxisCount: 1,
                    mainAxisExtent: saleProductTileHeight,
                    itemBuilder: (context, index) {
                      return Dismissible(
                          key: Key(addSaleController.selectedProducts[index].id.toString()), // Unique key for each item
                          direction: DismissDirection.endToStart, // Swipe left to remove
                          onDismissed: (direction) {
                            addSaleController.removeProducts(addSaleController.selectedProducts[index]);
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
                                cartItem: addSaleController.selectedProducts[index],
                                controller: addSaleController,
                                orderType: OrderType.sale,
                              )
                          )
                      );
                    }
                )),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Product Count - ${(addSaleController.selectedProducts.length).toStringAsFixed(0)}'),
                    Text('Total - ${AppSettings.currencySymbol + (addSaleController.saleTotal.value).toStringAsFixed(0)}'),
                  ],
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}