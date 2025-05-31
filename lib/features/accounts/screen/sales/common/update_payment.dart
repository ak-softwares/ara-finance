import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/navigation_bar/appbar.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/widgets/common/input_field_with_button.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../../settings/app_settings.dart';
import '../../../controller/sales_controller/payment_controller.dart';
import '../../customers/widget/customer_tile.dart';
import '../../purchase/purchase_entry/widget/search_products.dart';
import '../widget/barcode_sale_tile.dart';

class OrderNumbersView extends StatelessWidget {
  const OrderNumbersView({super.key});

  @override
  Widget build(BuildContext context) {
    // Use find instead of put if the controller is already initialized
    final UpdatePaymentController controller = Get.put(UpdatePaymentController());

    return Scaffold(
      appBar: AppAppBar(
        title: 'Update Payment',
        widgetInActions: IconButton(
          icon: const Icon(Icons.upload_file),
          onPressed: () => controller.pickCsvFile(),
          tooltip: 'Import CSV file',
        ),
      ),
      bottomNavigationBar: Obx(() => controller.orders.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: ElevatedButton(
                onPressed: () async {
                  await controller.updatePaymentStatus();
                },
                child: Obx(() {
                  final totalAmount = controller.orders.fold<double>(0.0, (sum, order) => sum + (order.total as num).toDouble());
                  return Text('Update Payments (${controller.orders.length} - ${AppSettings.currencySymbol}${totalAmount.toStringAsFixed(0)})',);
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
              // Add Input field
              InputFieldWithButton(
                textEditingController: controller.addOrderTextEditingController,
                onPressed: () async {
                  await controller.addManualOrder();
                },
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
                                selectedItems: controller.selectedCustomer.value
                            ),
                          );
                          // If products are selected, update the state
                          if (getSelectedCustomer.id != null) {
                            controller.addCustomer(getSelectedCustomer);
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
                        controller.selectedCustomer.value = UserModel();
                        AppMassages.showSnackBar(massage: 'Customer removed');
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: SizedBox(width: double.infinity, child: CustomerTile(customer: controller.selectedCustomer.value))
                  )
                      : SizedBox.shrink(),
                  ),
                ],
              ),

              // List of Orders
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.orders.isEmpty) {
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
                        child: const Text('No order numbers found. Import a CSV file or paste data.'),
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
                        itemCount: controller.orders.length,
                        itemBuilder: (_, index) {
                          final order = controller.orders[index];
                          final orderNumber = order.orderId;
                          final isValid = controller.orders.any((existingOrder) => existingOrder.orderId == orderNumber);
        
                          return BarcodeSaleTile(
                              color: isValid ? null : Colors.red.shade50,
                              orderId: controller.orders[index].orderId ?? 0,
                              amount: controller.orders[index].total?.toInt(),
                              onClose: () {
                                controller.orders.removeAt(index);
                                controller.orders.refresh();
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