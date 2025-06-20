import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../common/widgets/common/input_field_with_button.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../settings/app_settings.dart';
import '../../../../controller/transaction/sale/add_bulk_sale_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import '../../../search/search_and_select/search_products.dart';
import 'widget/barcode_sale_tile.dart';

class AddBarcodeSale extends StatelessWidget {

  const AddBarcodeSale({super.key});

  @override
  Widget build(BuildContext context) {
    final AddBulkSaleController controller = Get.put(AddBulkSaleController());

    return Scaffold(
      appBar: AppAppBar(
        title: 'Add Sale',
        widgetInActions: TextButton(
            onPressed: () => controller.getAllNewSalesWithDialog(context: context),
            child: Text('Add Woo Orders', style: TextStyle(color: AppColors.linkColor),)
        ),
      ),
      bottomNavigationBar: Obx(() => controller.newSales.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: ElevatedButton(
                  onPressed: () => controller.pushBulkSale(),
                  child: Text('Add Sale (${controller.newSales.length} - ${AppSettings.currencySymbol}${controller.saleTotal.toStringAsFixed(0)})')
              ),
            )
          : SizedBox.shrink()),
      body: ListView(
        children: [
          // Barcode Scan
          SizedBox(
            height: 200,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                // Define scan window (centered rectangle)
                final scanWindow = Rect.fromLTWH(
                  width * 0.1,
                  height * 0.3,
                  width * 0.8,
                  height * 0.4,
                );

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: controller.cameraController,
                      onDetect: controller.handleDetection,
                      scanWindow: scanWindow,
                    ),
                    // 🔲 Scan Window Frame
                    Positioned.fromRect(
                      rect: scanWindow,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.greenAccent, width: 1),
                        ),
                      ),
                    ),
                    // 🔴 Scan Line Animation Overlay (constrained to scanWindow)
                    Positioned(
                      left: scanWindow.left + 2,
                      top: scanWindow.top,
                      width: scanWindow.width - 4,
                      height: scanWindow.height,
                      child: const ScanAnimationOverlay(),
                    ),
                  ],
                );
              },
            ),
          ),

          // Add Input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InputFieldWithButton(
              textEditingController: controller.addOrderTextEditingController,
              onPressed: () async {
                await controller.addManualSale();
              },
            ),
          ),

          // Select Customer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
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
          ),

          // Select Sale Account
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
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
          ),

          // List of Orders
          Obx(() {
            return controller.newSales.isEmpty
                ? const Center(child: Text('No codes scanned yet.'))
                : GridLayout(
                    mainAxisExtent: AppSizes.barcodeTileHeight,
                    itemCount: controller.newSales.length,
                    itemBuilder: (_, index) {
                      return BarcodeSaleTile(
                        invoiceId: controller.newSales[index].transactionId,
                        orderId: controller.newSales[index].orderIds?.first ?? 0,
                        amount: controller.newSales[index].amount?.toInt(),
                        onClose: () {
                          controller.newSales.removeAt(index);
                          controller.newSales.refresh();
                        }
                      );
                    },
                  );
          }),
        ],
      ),
    );
  }
}

class ScanAnimationOverlay extends StatefulWidget {
  const ScanAnimationOverlay({super.key});

  @override
  _ScanAnimationOverlayState createState() => _ScanAnimationOverlayState();
}

class _ScanAnimationOverlayState extends State<ScanAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final lineY = constraints.maxHeight * _animation.value;
            return Stack(
              children: [
                Positioned(
                  top: lineY,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

