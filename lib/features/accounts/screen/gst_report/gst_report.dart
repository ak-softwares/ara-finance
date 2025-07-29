import 'package:ara_finance/common/layout_models/product_grid_layout.dart';
import 'package:ara_finance/features/settings/app_settings.dart';
import 'package:ara_finance/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_list_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../controller/gst_report/gst_controller.dart';
import '../financials/widgets/financial_shimmer.dart';
import '../transaction/single_transaction.dart';

class GstReport extends StatelessWidget {
  const GstReport({super.key});

  @override
  Widget build(BuildContext context) {
    final GstController controller = Get.put(GstController());

    return Scaffold(
      appBar: AppAppBar(title: 'GST Report'),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: controller.refreshGstReport,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShortOptions(controller),
              Obx(() {
                if (controller.isLoading.value) {
                  return const FinancialShimmer();
                }else{
                  return  Padding(
                    padding: const EdgeInsets.all(AppSizes.defaultSpace),
                    child: Column(
                      spacing: AppSizes.defaultSpace,
                      children: [
                        // Sale Report
                        RoundedContainer(
                            backgroundColor: Colors.green.shade50,
                            padding: const EdgeInsets.all(AppSizes.xl),
                            radius: AppSizes.md,
                            child: Column(
                              spacing: AppSizes.md,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Heading(title: 'Sale Report'),
                                Column(
                                  spacing: AppSizes.defaultSpace,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Sale'),
                                        InkWell(
                                          onTap: () => controller.showAllSales(),
                                          child: Text('${AppSettings.currencySymbol}${controller.totalSale}(${controller.totalSaleCount})',
                                          style: TextStyle(color: AppColors.linkColor)),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total Return'),
                                        InkWell(
                                          onTap: () => controller.showSalesByStatus(OrderStatus.returned),
                                          child: Text('${AppSettings.currencySymbol}${controller.netReturn}(${controller.netReturnCount})',
                                              style: TextStyle(color: AppColors.linkColor)),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('In-Transit'),
                                        InkWell(
                                          onTap: () => controller.showSalesByStatus(OrderStatus.inTransit),
                                          child: Text('${AppSettings.currencySymbol}${controller.netInTransit}(${controller.netNetInTransitCount})',
                                              style: TextStyle(color: AppColors.linkColor)),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Net Sale'),
                                        InkWell(
                                          onTap: () => controller.showSalesByStatus(OrderStatus.completed),
                                          child: Text('${AppSettings.currencySymbol}${controller.netSale}(${controller.netSaleCount})',
                                              style: TextStyle(color: AppColors.linkColor)),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            )
                        ),

                        // B2B Report
                        RoundedContainer(
                            backgroundColor: Colors.blue.shade50,
                            padding: const EdgeInsets.all(AppSizes.xl),
                            radius: AppSizes.md,
                            child: Column(
                              spacing: AppSizes.md,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Heading(title: 'B2B Report (${controller.b2bSales.length})'),
                                    IconButton(
                                      onPressed: () => controller.isB2BExpanded.value = !controller.isB2BExpanded.value,
                                      icon: controller.isB2BExpanded.value ? const Icon(Icons.keyboard_arrow_down) : const Icon(Icons.keyboard_arrow_up),
                                    )
                                  ],
                                ),
                                if(controller.isB2BExpanded.value)
                                  GridLayout(
                                    itemCount: controller.b2bSales.toList().length,
                                    mainAxisExtent: 100,
                                    mainAxisSpacing: 10,
                                    itemBuilder: (context, index) {
                                      final transaction = controller.b2bSales.toList()[index];
                                      return InkWell(
                                        onTap: () => Get.to(() => SingleTransaction(transaction: transaction)), // Updated navigation
                                        child: RoundedContainer(
                                          backgroundColor: Colors.white,
                                          radius: AppSizes.sm,
                                          padding: const EdgeInsets.all(AppSizes.sm),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('GST Number'),
                                                  Text(transaction.address?.gstNumber ?? '')
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Invoice Number'),
                                                  Text(transaction.transactionId.toString())
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Date'),
                                                  Text(AppFormatter.formatStringDate(transaction.date.toString()))
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('Total Amount'),
                                                  Text(transaction.amount.toString())
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                
                              ],
                            )
                        ),

                        // B2C Report
                        RoundedContainer(
                            backgroundColor: Colors.orange.shade50,
                            padding: const EdgeInsets.all(AppSizes.xl),
                            radius: AppSizes.md,
                            child: Column(
                              spacing: AppSizes.md,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Heading(title: 'B2C Report (${controller.b2cSalesStateWise.length})'),
                                    IconButton(
                                      onPressed: () => controller.isB2CExpanded.value = !controller.isB2CExpanded.value,
                                      icon: controller.isB2CExpanded.value ? const Icon(Icons.keyboard_arrow_down) : const Icon(Icons.keyboard_arrow_up),
                                    )
                                  ],
                                ),
                                if(controller.isB2CExpanded.value)
                                  GridLayout(
                                  itemCount: controller.b2cSalesStateWise.entries.toList().length,
                                  mainAxisExtent: 40,
                                  mainAxisSpacing: 10,
                                  itemBuilder: (context, index) {
                                    final entry = controller.b2cSalesStateWise.entries.toList()[index];
                                    return InkWell(
                                      onTap: () {
                                        final selectedState = entry.key;
                                        controller.showStateSales(selectedState);
                                      },
                                      child: RoundedContainer(
                                        backgroundColor: Colors.white,
                                        radius: AppSizes.sm,
                                        padding: const EdgeInsets.all(AppSizes.sm),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(entry.key),       // state name
                                            Text('₹${entry.value}') // sale value
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            )
                        ),

                        // HSN wise summary
                        RoundedContainer(
                            backgroundColor: Colors.pink.shade50,
                            padding: const EdgeInsets.all(AppSizes.xl),
                            radius: AppSizes.md,
                            child: Column(
                              spacing: AppSizes.md,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Heading(title: 'HSN Report (${controller.hsnWiseSalesSummary.length})'),
                                    IconButton(
                                      onPressed: () => controller.isHSNExpanded.value = !controller.isHSNExpanded.value,
                                      icon: controller.isHSNExpanded.value ? const Icon(Icons.keyboard_arrow_down) : const Icon(Icons.keyboard_arrow_up),
                                    )
                                  ],
                                ),
                                if(controller.isHSNExpanded.value)
                                  GridLayout(
                                  itemCount: controller.hsnWiseSalesSummary.entries.toList().length,
                                  mainAxisExtent: 40,
                                  mainAxisSpacing: 10,
                                  itemBuilder: (context, index) {
                                    final entry = controller.hsnWiseSalesSummary.entries.toList()[index];
                                    return RoundedContainer(
                                      backgroundColor: Colors.white,
                                      radius: AppSizes.sm,
                                      padding: const EdgeInsets.all(AppSizes.sm),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(entry.key.toString()),       // state name
                                          Text('₹${entry.value}') // sale value
                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortOptions(GstController controller) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm, left: AppSizes.defaultSpace),
      child: ListLayout(
          height: 50,
          itemCount: controller.dateOptions.length,
          itemBuilder: (context, index) {
            return Obx(() {
              final option = controller.dateOptions[index];
              final isSelected = option == controller.selectedOption.value;
              return InkWell(
                onTap: () async {
                  controller.selectedOption.value = option;
                  await controller.selectDate();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm, top: AppSizes.sm, bottom: AppSizes.sm),
                  child: RoundedContainer(
                    radius: AppSizes.md,
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 0),
                    backgroundColor: Colors.blue.shade50,
                    child: Center(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.blue : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
          }
      ),
    );
  }

}
