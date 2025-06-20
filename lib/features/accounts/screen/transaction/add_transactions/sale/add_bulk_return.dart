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
import '../../../../../personalization/models/user_model.dart';
import '../../../../../settings/app_settings.dart';
import '../../../../controller/transaction/sale/sale_bulk_return_controller.dart';
import '../../../search/search_and_select/search_products.dart';
import 'widget/barcode_sale_tile.dart';

class AddBulkReturn extends StatelessWidget {

  const AddBulkReturn({super.key});

  @override
  Widget build(BuildContext context) {
    final AddBulkReturnController controller = Get.put(AddBulkReturnController());

    return Scaffold(
      appBar: AppAppBar(title: 'Add Bulk Return'),
      bottomNavigationBar: Obx(() => controller.returns.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: ElevatedButton(
                onPressed: () => controller.pushBulkReturn(newReturnSales: controller.returns),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orange.shade500),
                ),
                child: Obx(() {
                  final totalAmount = controller.returns.fold<double>(0.0, (sum, order) => sum + (order.amount as num).toDouble());
                  return Text('Add Bulk Return (${controller.returns.length} - ${AppSettings.currencySymbol}${totalAmount.toStringAsFixed(0)})',);
                }),
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
              textEditingController: controller.returnOrderTextEditingController,
              onPressed: () async {
                await controller.addManualReturn();
              },
            ),
          ),

          // List of Orders
          Obx(() {
            return controller.returns.isEmpty
                ? const Center(child: Text('No codes scanned yet.'))
                : GridLayout(
                    mainAxisExtent: AppSizes.barcodeTileHeight,
                    itemCount: controller.returns.length,
                    itemBuilder: (_, index) {
                      return BarcodeSaleTile(
                          orderId: controller.returns[index].orderIds?.first ?? 0,
                          invoiceId: controller.returns[index].transactionId,
                          amount: controller.returns[index].amount?.toInt(),
                          onClose: () {
                            controller.returns.removeAt(index);
                            controller.returns.refresh();
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

