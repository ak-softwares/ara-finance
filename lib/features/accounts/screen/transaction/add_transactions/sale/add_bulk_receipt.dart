import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../common/styles/spacing_style.dart';
import '../../../../../../common/widgets/common/input_field_with_button.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../settings/app_settings.dart';
import '../../../../controller/search/search_delegate.dart';
import '../../../../controller/transaction/sale/add_bulk_receipt_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import 'widget/barcode_sale_tile.dart';

class AddBulkReceipt extends StatelessWidget {
  const AddBulkReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    // Use find instead of put if the controller is already initialized
    final AddBulkReceiptController controller = Get.put(AddBulkReceiptController());

    return Scaffold(
      appBar: AppAppBar(
        title: 'Update Bulk Receipt',
        widgetInActions: IconButton(
          icon: const Icon(Icons.upload_file),
          onPressed: () => controller.pickCsvFile(),
          tooltip: 'Import CSV file',
        ),
      ),
      bottomNavigationBar: Obx(() => controller.receiptSales.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: ElevatedButton(
                onPressed: () async {
                  await controller.pushBulkReceipt(newReceiptSales: controller.receiptSales);
                },
                child: Obx(() {
                  final totalAmount = controller.receiptSales.fold<double>(0.0, (sum, order) => sum + (order.amount as num).toDouble());
                  return Text('Update Receipt (${controller.receiptSales.length} - ${AppSettings.currencySymbol}${totalAmount.toStringAsFixed(0)})',);
                }),
              ),
            )
          : SizedBox.shrink()),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.defaultPagePadding,
          child: Column(
            spacing: AppSizes.spaceBtwItems,
            children: [
              // Customer
              Column(
                spacing: AppSizes.spaceBtwItems,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select customer'),
                      InkWell(
                        onTap: () async {
                          // Navigate to the search screen and wait for the result
                          final AccountVoucherModel getSelectedCustomer = await showSearch(context: context,
                            delegate: AppSearchDelegate(voucherType: AccountVoucherType.customer, isPicker: true),
                          );
                          // If products are selected, update the state
                          if (getSelectedCustomer.id != null) {
                            controller.selectedCustomer(getSelectedCustomer);
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
                  Obx(() => controller.selectedCustomer.value.id != '' && controller.selectedCustomer.value.id != null
                      ? Dismissible(
                      key: Key(controller.selectedCustomer.value.id ?? ''), // Unique key for each item
                      direction: DismissDirection.endToStart, // Swipe left to remove
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
                      child: SizedBox(width: double.infinity, child: AccountVoucherTile(accountVoucher: controller.selectedCustomer.value, voucherType: AccountVoucherType.customer))
                  )
                      : SizedBox.shrink(),
                  ),
                ],
              ),

              // Account
              Column(
                spacing: AppSizes.spaceBtwItems,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Account'),
                      InkWell(
                        onTap: () async {
                          // Navigate to the search screen and wait for the result
                          final AccountVoucherModel getSelectedPayment = await showSearch(context: context,
                            delegate: AppSearchDelegate(voucherType: AccountVoucherType.bankAccount, isPicker: true),
                          );
                          // If products are selected, update the state
                          if (getSelectedPayment.id != null) {
                            controller.selectedBankAccount(getSelectedPayment);
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

                  // Select Bank Account
                  Obx(() => controller.selectedBankAccount.value.id != null
                      ? Dismissible(
                      key: Key(controller.selectedBankAccount.value.id ?? ''), // Unique key for each item
                      direction: DismissDirection.endToStart, // Swipe left to remove
                      onDismissed: (direction) {
                        controller.selectedBankAccount.value = AccountVoucherModel();
                        AppMassages.showSnackBar(massage: 'Bank account removed');
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: SizedBox(
                          width: double.infinity,
                          child: AccountVoucherTile(accountVoucher: controller.selectedBankAccount.value, voucherType: AccountVoucherType.bankAccount)
                      )
                  )
                      : SizedBox.shrink(),
                  ),
                ],
              ),

              // Add Input field
              InputFieldWithButton(
                textEditingController: controller.addOrderTextEditingController,
                onPressed: () async {
                  await controller.addManualOrder();
                },
              ),

              // List of Orders
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.receiptSales.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => controller.pickCsvFile(),
                        icon: Column(
                          children: [
                            Icon(Icons.file_upload, size: 100, color: AppColors.linkColor,),
                            Text('Click here', style: TextStyle(color: AppColors.linkColor),)
                          ],
                        )
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: const Text('No sale numbers found. Import a CSV file or paste data.'),
                      ),
                    ],
                  );
                } else{
                  return Column(
                    spacing: 5,
                    children: [
                      GridLayout(
                        mainAxisExtent: AppSizes.barcodeTileHeight,
                        itemCount: controller.ordersNotFount.length,
                        itemBuilder: (_, index) {
                          final orderNumber = controller.ordersNotFount[index];
                          return BarcodeSaleTile(
                            color: Colors.red.shade50,
                            orderId: orderNumber,
                            amount: 0,
                            onClose: () {
                              controller.ordersNotFount.removeAt(index);
                              controller.ordersNotFount.refresh();
                            },
                          );
                        },
                      ),
                      GridLayout(
                        mainAxisExtent: AppSizes.barcodeTileHeight,
                        itemCount: controller.receiptSales.length,
                        itemBuilder: (_, index) {
                          final sale = controller.receiptSales[index];
                          final orderNumber = sale.orderIds;
                          final isValid = controller.receiptSales.any((existingOrder) => existingOrder.orderIds == orderNumber);
        
                          return BarcodeSaleTile(
                              color: isValid ? null : Colors.red.shade50,
                              orderId: controller.receiptSales[index].orderIds?.first ?? 0,
                              invoiceId: controller.receiptSales[index].transactionId,
                              amount: controller.receiptSales[index].amount?.toInt(),
                              onClose: () {
                                controller.receiptSales.removeAt(index);
                                controller.receiptSales.refresh();
                              },
                          );
                        },
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}