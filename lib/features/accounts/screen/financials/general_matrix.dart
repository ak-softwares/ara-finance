import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/financial/financial_controller.dart';
import 'widgets/financial_tile.dart';

class GeneralMatrixTab extends StatelessWidget {

  const GeneralMatrixTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FinancialController controller = Get.put(FinancialController());

    return Obx(() => Column(
      children: [
        FinancialTile(
          title: 'General Matrix',
          value: 0,
          index: 0,
          isParent: true,
          isExpanded: controller.isGeneralMatrixExpanded.value,
          onToggle: controller.isGeneralMatrixExpanded.toggle,
        ),
        if (controller.isGeneralMatrixExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'Coupon Used',
                value: controller.couponUsed,
                index: 0,
              ),
              FinancialTile(
                title: 'Coupon Discount Total',
                value: controller.couponDiscountTotal.toInt(),
                isCurrency: true,
                index: 0,
              ),
              FinancialTile(
                title: 'Returning Customers',
                value: 0,
                isCurrency: true,
                index: 0,
              ),
            ],
          ),

        FinancialTile(
          title: 'Purchase',
          value: controller.purchasesTotal,
          isCurrency: true,
          index: 1,
          isParent: true,
          isExpanded: controller.isPurchaseExpanded.value,
          onToggle: controller.isPurchaseExpanded.toggle,
        ),
        if (controller.isPurchaseExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'Purchase',
                value: controller.purchasesTotal,
                count: controller.purchasesCount,
                isCurrency: true,
                index: 1,
              ),
            ],
          ),

        FinancialTile(
          title: 'Unit Matrix(AOV)',
          value: controller.averageOrderValue.toInt(),
          index: 2,
          isParent: true,
          isExpanded: controller.isUnitMatrixExpanded.value,
          onToggle: controller.isUnitMatrixExpanded.toggle,
        ),
        if (controller.isUnitMatrixExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'COGS',
                value: controller.unitCogs.toInt(),
                percent: controller.unitCogsPercent,
                isCurrency: true,
                index: 2,
              ),
              FinancialTile(
                title: 'Shipping',
                value: controller.unitShipping.toInt(),
                percent: controller.unitShippingPercent,
                isCurrency: true,
                index: 2,
              ),
              FinancialTile(
                title: 'Ads',
                value: controller.unitAds.toInt(),
                percent: controller.unitAdsPercent,
                isCurrency: true,
                index: 2,
              ),
              FinancialTile(
                title: 'Profit',
                value: controller.unitProfit.toInt(),
                percent: controller.unitProfitPercent,
                isCurrency: true,
                index: 2,
              ),
            ],
          ),

        FinancialTile(
          title: 'Attributes',
          value: controller.revenueTotal,
          isCurrency: true,
          index: 3,
          isParent: true,
          isExpanded: controller.isAttributesExpanded.value,
          onToggle: controller.isAttributesExpanded.toggle,
        ),
        if (controller.isAttributesExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'Total Revenue',
                value: controller.revenueTotal,
                count: controller.orderTotal,
                isCurrency: true,
                index: 3,
              ),
              for (var summary in controller.revenueSummaries) ...[
                FinancialTile(
                  title: summary.type,
                  value: summary.totalRevenue.toInt(),
                  count: summary.orderCount,
                  percent: summary.percent.toInt(),
                  isCurrency: true,
                  index: 3,
                ),
                for (var entry in summary.sourceBreakdown)
                  FinancialTile(
                    title: '• ${entry.source}',
                    count: entry.orderCount,
                    value: entry.revenue,
                    percent: entry.percent.toInt(),
                    isCurrency: true,
                    index: 2,
                  ),
              ],
            ],
          ),
      ],
    ));
  }
}
