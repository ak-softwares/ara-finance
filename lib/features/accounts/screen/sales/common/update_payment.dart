import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/navigation_bar/appbar.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/widgets/common/input_field_with_button.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../settings/app_settings.dart';
import '../../../controller/sales_controller/payment_controller.dart';
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
          onPressed: () => _pickCsvFile(controller),
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
                  final totalAmount = controller.orders.fold<double>(0.0, (sum, order) => sum + (order['amount'] as num).toDouble());
                  return Text('Update Payments (${controller.orders.length} - ${AppSettings.currencySymbol}${totalAmount.toStringAsFixed(0)})',);
                }),
              ),
            )
          : SizedBox.shrink()),
      body: Padding(
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

            // List of Orders
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (controller.orders.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => _pickCsvFile(controller),
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
                return GridLayout(
                  mainAxisExtent: AppSizes.barcodeTileHeight,
                  itemCount: controller.orders.length,
                  itemBuilder: (_, index) {
                    final order = controller.orders[index];
                    final orderNumber = order['orderNumber'];
                    final isValid = controller.existingOrders.any((existingOrder) => existingOrder.orderId == orderNumber);

                    return BarcodeSaleTile(
                        color: isValid ? null : Colors.red.shade50,
                        orderId: controller.orders[index]['orderNumber'],
                        amount: controller.orders[index]['amount'],
                        onClose: () {
                          controller.orders.removeAt(index);
                          controller.orders.refresh();
                        },
                    );
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCsvFile(UpdatePaymentController controller) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          await controller.parseCsvFromFile(file.path!);
          AppMassages.showToastMessage(message: 'File imported successfully');
        } else {
          AppMassages.errorSnackBar(title: 'Error', message: 'Invalid file path');
        }
      }
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: 'Failed to pick file: ${e.toString()}');
    }
  }
}