import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/formatters/formatters.dart';
import '../../../../../settings/app_settings.dart';
import '../../../../controller/transaction/sale/add_sale_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../../models/product_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import '../../../search/search_and_select/search_products.dart';
import '../purchase/widget/product_tile.dart';

class AddSale extends StatelessWidget {
  const AddSale({super.key, this.sale});

  final TransactionModel? sale;

  @override
  Widget build(BuildContext context) {
    const double saleProductTileHeight = AppSizes.purchaseProductTileHeight;
    final AddSaleController controller = Get.put(AddSaleController());

    if (sale != null) {
      controller.resetValue(sale!);
    }

    return Scaffold(
      appBar: AppAppBar(title: sale != null ? 'Update Sale' : 'Add Sale'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => sale != null
              ? controller.saveUpdatedSaleTransaction(oldSaleTransaction: sale!)
              : controller.saveSaleTransaction(),
          child: Text(
            sale != null ? 'Update Sale' : 'Add Sale',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.saleFormKey,
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
                        sale != null
                            ? Text('#${sale!.transactionId}', style: const TextStyle(fontSize: 14))
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

                // Select Status
                DropdownButtonFormField<OrderStatus>(
                  value: controller.selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Select Order Status",
                    border: OutlineInputBorder(),
                  ),
                  items: OrderStatus.values.map((OrderStatus status) {
                    return DropdownMenuItem<OrderStatus>(
                      value: status,
                      child: Text(status.name.capitalize!),
                    );
                  }).toList(),
                  onChanged: (OrderStatus? newValue) {
                    controller.selectedStatus = newValue ?? OrderStatus.inTransit;
                    // If you're using setState(), update here
                  },
                ),

                // Select Customer
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Customer'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedCustomer = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.customer),
                            );
                            if (getSelectedCustomer.id != null) {
                              controller.selectedCustomer(getSelectedCustomer);
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
                    Obx(() => controller.selectedCustomer.value.id != null
                        ? Dismissible(
                        key: Key(controller.selectedCustomer.value.id ?? ''),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          controller.selectedCustomer.value = AccountVoucherModel();
                          AppMassages.showSnackBar(massage: 'Customer removed');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(
                            width: double.infinity,
                            child: AccountVoucherTile(accountVoucher: controller.selectedCustomer.value, voucherType: AccountVoucherType.customer)
                        )
                    )
                        : SizedBox.shrink(),
                    ),
                  ],
                ),

                // Select Sale Account
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Sale Voucher'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedSaleVoucher = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.sale),
                            );
                            if (getSelectedSaleVoucher.id != null) {
                              controller.selectedSaleVoucher(getSelectedSaleVoucher);
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
                    Obx(() => controller.selectedSaleVoucher.value.id != null
                        ? Dismissible(
                        key: Key(controller.selectedSaleVoucher.value.id ?? ''),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          controller.selectedSaleVoucher.value = AccountVoucherModel();
                          AppMassages.showSnackBar(massage: 'Sale Voucher removed');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(
                            width: double.infinity,
                            child: AccountVoucherTile(accountVoucher: controller.selectedSaleVoucher.value, voucherType: AccountVoucherType.sale)
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
                            final List<ProductModel> getSelectedProducts = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.product),
                            );
                            if (getSelectedProducts.isNotEmpty) {
                              controller.addProducts(getSelectedProducts);
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
                    Obx(() => GridLayout(
                        itemCount: controller.selectedProducts.length,
                        crossAxisCount: 1,
                        mainAxisExtent: saleProductTileHeight,
                        itemBuilder: (context, index) {
                          return Dismissible(
                              key: Key(controller.selectedProducts[index].id.toString()),
                              direction: DismissDirection.endToStart,
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
                                  child: PurchaseProductCard( // You can rename this widget to SaleProductCard if needed
                                    cartItem: controller.selectedProducts[index],
                                    controller: controller,
                                    orderType: OrderType.sale,
                                  )
                              )
                          );
                        }
                    )),
                  ],
                ),

                // Discount and shipping
                Row(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.discountController,
                        decoration: InputDecoration(
                          labelText: 'Discount',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: controller.shippingController,
                        decoration: InputDecoration(
                          labelText: 'Shipping',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                // Total
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Product Count - ${(controller.selectedProducts.length).toStringAsFixed(0)}'),
                    Text('Total - ${AppSettings.currencySymbol + (controller.saleTotal.value).toStringAsFixed(0)}'),
                  ],
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
