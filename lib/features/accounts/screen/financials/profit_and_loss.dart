import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../controller/financial/financial_controller.dart';
import '../../controller/financial/profit_and_loss_controller.dart';
import 'widgets/financial_tile.dart';

class ProfitAndLossTab extends StatelessWidget {

  const ProfitAndLossTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FinancialController controller = Get.put(FinancialController());
    // final ProfitAndLossController controller = Get.put(ProfitAndLossController());

    return Obx(() => Column(
      children: [
        FinancialTile(
          title: 'Revenue',
          value: controller.revenue,
          isCurrency: true,
          index: 0,
          isParent: true,
          isExpanded: controller.isRevenueExpanded.value,
          onToggle: controller.isRevenueExpanded.toggle,
        ),
        if (controller.isRevenueExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'In-Transit Orders',
                value: controller.revenueInTransit,
                percent: controller.revenueInTransitPercent,
                count: controller.orderInTransit,
                isCurrency: true,
                index: 0,
              ),
              FinancialTile(
                title: 'Completed Orders',
                value: controller.revenueCompleted,
                percent: controller.revenueCompletedPercent,
                count: controller.orderCompleted,
                isCurrency: true,
                index: 0,
              ),
              FinancialTile(
                title: 'Return Orders',
                value: controller.revenueReturn,
                percent: controller.revenueReturnPercent,
                count: controller.orderReturnCount,
                isCurrency: true,
                index: 0,
              ),
              FinancialTile(
                title: 'Total Revenue',
                value: controller.revenueTotal,
                count: controller.orderTotal,
                isCurrency: true,
                index: 0,
              ),
            ],
          ),

        FinancialTile(
          title: 'Expenses',
          value: controller.expensesTotalOperatingCost,
          percent: controller.expensesCogsPercent,
          isCurrency: true,
          index: 1,
          isParent: true,
          isExpanded: controller.isExpensesExpanded.value,
          onToggle: controller.isExpensesExpanded.toggle,
        ),
        if (controller.isExpensesExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'COGS',
                value: controller.expensesCogs,
                percent: controller.expensesCogsPercent,
                isCurrency: true,
                index: 1,
              ),
              GridLayout(
                itemCount: controller.expenseSummaries.length,
                mainAxisExtent: 50,
                itemBuilder: (context, index) {
                  final summary = controller.expenseSummaries[index];
                  return FinancialTile(
                    title: summary.name,
                    value: summary.total,
                    percent: summary.percent.toInt(),
                    isCurrency: true,
                    index: 1,
                  );
                },
              ),
            ],
          ),

        FinancialTile(
          title: 'Net Profit(PAT)',
          value: controller.netProfit,
          percent: controller.netProfitPercent,
          isCurrency: true,
          index: 2,
          isParent: true,
          isExpanded: controller.isProfitExpanded.value,
          onToggle: controller.isProfitExpanded.toggle,
        ),
        if (controller.isProfitExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'Gross Profit',
                value: controller.grossProfit,
                percent: controller.grossProfitPercent,
                isCurrency: true,
                index: 2,
              ),
              FinancialTile(
                title: 'Operating Profit(EBITA)',
                value: controller.operatingProfit,
                percent: controller.operatingProfitPercent,
                isCurrency: true,
                index: 2,
              ),
            ],
          ),
      ],
    ));
  }
}
