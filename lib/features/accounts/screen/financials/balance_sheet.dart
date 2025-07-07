import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/financial/financial_controller.dart';
import 'widgets/financial_tile.dart';

class BalanceSheetTab extends StatelessWidget {

  const BalanceSheetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final FinancialController controller = Get.put(FinancialController());

    return Obx(() => Column(
      children: [
        FinancialTile(
          title: 'Assets',
          value: controller.assets,
          isCurrency: true,
          index: 0,
          isParent: true,
          isExpanded: controller.isAssetsExpanded.value,
          onToggle: controller.isAssetsExpanded.toggle,
        ),
        if (controller.isAssetsExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'Inventory',
                value: controller.stock.value,
                percent: controller.stockPercent,
                isCurrency: true,
                index: 0,
              ),
              FinancialTile(
                title: 'Inventory In-Transit',
                value: controller.expensesCogsInTransit.value,
                count: controller.countSalesInTransit.value,
                percent: controller.expensesCogsInTransitPercent,
                isCurrency: true,
                index: 0,
              ),
              FinancialTile(
                title: 'Cash',
                value: controller.cashTotal.value,
                percent: controller.cashPercent,
                isCurrency: true,
                index: 0,
              ),
              FinancialTile(
                title: 'Account Receivables',
                value: 0,
                isCurrency: true,
                index: 0,
              ),
            ],
          ),

        FinancialTile(
          title: 'Liabilities',
          value: controller.liabilities,
          isCurrency: true,
          index: 1,
          isParent: true,
          isExpanded: controller.isLiabilitiesExpanded.value,
          onToggle: controller.isLiabilitiesExpanded.toggle,
        ),
        if (controller.isLiabilitiesExpanded.value)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinancialTile(
                title: 'Accounts Payable',
                value: controller.accountsPayable.value,
                percent: controller.accountsPayablePercent,
                isCurrency: true,
                index: 1,
              ),
            ],
          ),

        FinancialTile(
          title: 'Equity',
          value: 0,
          isCurrency: true,
          index: 2,
          isParent: true,
          isExpanded: controller.isEquityExpanded.value,
          onToggle: controller.isEquityExpanded.toggle,
        ),

        FinancialTile(
          title: 'Net Worth',
          value: controller.netWorth,
          isCurrency: true,
          index: 3,
          isParent: true,
          isExpanded: controller.isNetWorthExpanded.value,
          onToggle: controller.isNetWorthExpanded.toggle,
        ),
      ],
    ));
  }
}
