import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/layout_models/product_list_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/navigation_bar/tabbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/widgets/custom_shape/containers/rounded_container.dart';
import '../../../../common/widgets/shimmers/order_shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../settings/app_settings.dart';
import '../../controller/financial/financial_controller.dart';

class Financials extends StatelessWidget {
  const Financials({super.key});

  @override
  Widget build(BuildContext context) {
    final FinancialController controller = Get.put(FinancialController());

    final List<String> financialsTabs = ['Profit & Loss', 'Balance Sheet', 'General Matrix'];

    return DefaultTabController(
      length: financialsTabs.length,
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Financials',
          toolbarHeight: 40,
          bottom: AppTabBar(
            isScrollable: false,
            tabs: financialsTabs.map((tab) {
              return Padding(
                padding: const EdgeInsets.only(
                  top: AppSizes.defaultBtwTiles,
                  bottom: AppSizes.defaultBtwTiles,
                ),
                child: Text(tab, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: financialsTabs.map((financialsTab) {
            return RefreshIndicator(
              color: AppColors.refreshIndicator,
              onRefresh: () async => controller.refreshFinancials(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Short
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm, left: AppSizes.defaultSpace),
                    child: ListLayout(
                      height: 50,
                      itemCount: controller.short.length,
                      itemBuilder: (context, index) {
                        return Obx(() {
                          final option = controller.short[index];
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
                                    )
                                ),
                              ),
                            ),
                          );
                        });
                      }
                    ),
                  ),
                  Obx(() {
                    if(controller.isLoading.value) {
                      return OrderShimmer(itemCount: 2);
                    } else {
                      return Column(
                        children: [
                          // Profit & Loss
                          if (financialsTab == financialsTabs[0])
                            Obx(() => Column(
                                children: [
                                  _buildThreeColumnHeading(),
                                  _buildThreeColumnRow(
                                    label: 'Revenue',
                                    value: controller.revenue,
                                    isCurrency: true,
                                    index: 0,
                                    isExpanded:
                                    controller.isRevenueExpanded.value,
                                    onToggle: () => controller.isRevenueExpanded.toggle(),
                                  ),
                                  if (controller.isRevenueExpanded.value) ...[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildThreeColumnChild(
                                            label: 'In-Transit Orders',
                                            value: controller.revenueInTransit,
                                            percent: controller.revenueInTransitPercent,
                                            count: controller.orderInTransit,
                                            isCurrency: true,
                                            index: 0
                                        ),
                                        _buildThreeColumnChild(
                                            label: 'Completed Orders',
                                            value: controller.revenueCompleted,
                                            percent: controller.revenueCompletedPercent,
                                            count: controller.orderCompleted,
                                            isCurrency: true,
                                            index: 0
                                        ),
                                        _buildThreeColumnChild(
                                            label: 'Return Orders',
                                            value: controller.revenueReturn,
                                            percent: controller.revenueReturnPercent,
                                            count: controller.orderReturnCount,
                                            isCurrency: true,
                                            index: 0
                                        ),
                                        _buildThreeColumnChild(
                                            label: 'Total Revenue',
                                            value: controller.revenueTotal,
                                            count: controller.orderTotal,
                                            isCurrency: true,
                                            index: 0
                                        ),
                                      ],
                                    )
                                  ],
                                  _buildThreeColumnRow(
                                    label: 'Expenses',
                                    value: controller.expensesTotalOperatingCost,
                                    percent: controller.expensesCogsPercent,
                                    isCurrency: true,
                                    index: 1,
                                    isExpanded:
                                    controller.isExpensesExpanded.value,
                                    onToggle: () => controller.isExpensesExpanded.toggle(),
                                  ),
                                  if (controller.isExpensesExpanded.value) ...[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildThreeColumnChild(
                                            label: 'COGS',
                                            value: controller.expensesCogs.value,
                                            percent: controller.expensesCogsPercent,
                                            isCurrency: true,
                                            index: 1
                                        ),
                                        GridLayout(
                                            itemCount: controller.expenseSummaries.length,
                                            mainAxisExtent: 50,
                                            itemBuilder: (context, index) {
                                              return _buildThreeColumnChild(
                                                  label: controller.expenseSummaries[index].name,
                                                  value: controller.expenseSummaries[index].total,
                                                  percent: controller.expenseSummaries[index].percent.toInt(),
                                                  isCurrency: true,
                                                  index: 1
                                              );
                                            }
                                        )
                                      ],
                                    )
                                  ],
                                  _buildThreeColumnRow(
                                    label: 'Net Profit(PAT)',
                                    value: controller.netProfit,
                                    percent: controller.netProfitPercent,
                                    isCurrency: true,
                                    index: 2,
                                    isExpanded:
                                    controller.isProfitExpanded.value,
                                    onToggle: () => controller.isProfitExpanded.toggle(),
                                  ),
                                  if (controller.isProfitExpanded.value) ...[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        _buildThreeColumnChild(
                                            label: 'Gross Profit',
                                            value: controller.grossProfit,
                                            percent: controller.grossProfitPercent,
                                            isCurrency: true,
                                            index: 1
                                        ),
                                        _buildThreeColumnChild(
                                            label: 'Operating Profit(EBITA)',
                                            value: controller.operatingProfit,
                                            percent: controller.operatingProfitPercent,
                                            isCurrency: true,
                                            index: 1
                                        ),
                                      ],
                                    )
                                  ],
                                ],
                              ))

                          // Balance Sheet
                          else if (financialsTab == financialsTabs[1])
                            Column(
                              children: [
                                _buildThreeColumnHeading(),
                                _buildThreeColumnRow(
                                  label: 'Assets',
                                  value: controller.assets,
                                  isCurrency: true,
                                  index: 0,
                                  isExpanded:
                                  controller.isAssetsExpanded.value,
                                  onToggle: () => controller.isAssetsExpanded.toggle(),
                                ),
                                if (controller.isAssetsExpanded.value) ...[
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      _buildThreeColumnChild(
                                          label: 'Inventory',
                                          value: controller.stock.value,
                                          percent: controller.stockPercent,
                                          isCurrency: true,
                                          index: 0
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Inventory In-Transit',
                                          value: controller.expensesCogsInTransit.value,
                                          percent: controller.expensesCogsInTransitPercent,
                                          isCurrency: true,
                                          index: 0
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Cash',
                                          value: controller.cash.value,
                                          percent: controller.cashPercent,
                                          isCurrency: true,
                                          index: 0
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Account Receivables',
                                          value: 0,
                                          isCurrency: true,
                                          index: 0
                                      )
                                    ],
                                  )
                                ],
                                _buildThreeColumnRow(
                                  label: 'Liabilities',
                                  value: controller.liabilities,
                                  isCurrency: true,
                                  index: 1,
                                  isExpanded: controller.isLiabilitiesExpanded.value,
                                  onToggle: () => controller.isLiabilitiesExpanded.toggle(),
                                ),
                                if (controller.isLiabilitiesExpanded.value) ...[
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      _buildThreeColumnChild(
                                          label: 'Accounts Payable',
                                          value: controller.accountsPayable.value,
                                          percent: controller.accountsPayablePercent,
                                          isCurrency: true,
                                          index: 1
                                      ),
                                    ],
                                  )
                                ],

                                _buildThreeColumnRow(
                                  label: 'Equity',
                                  value: 0,
                                  isCurrency: true,
                                  index: 2,
                                  isExpanded: controller.isEquityExpanded.value,
                                  onToggle: () => controller.isEquityExpanded.toggle(),
                                ),
                                _buildThreeColumnRow(
                                  label: 'Net Worth',
                                  value: controller.netWorth,
                                  isCurrency: true,
                                  index: 3,
                                  isExpanded: controller.isNetWorthExpanded.value,
                                  onToggle: () => controller.isNetWorthExpanded.toggle(),
                                ),
                              ],
                            )
                          else if (financialsTab == financialsTabs[2])
                            Column(
                              children: [
                                _buildThreeColumnHeading(),
                                _buildThreeColumnRow(
                                  label: 'General Matrix',
                                  value: 0,
                                  index: 0,
                                  isExpanded:
                                  controller.isGeneralMatrixExpanded.value,
                                  onToggle: () => controller.isGeneralMatrixExpanded.toggle(),
                                ),
                                if (controller.isGeneralMatrixExpanded.value) ...[
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      _buildThreeColumnChild(
                                          label: 'Coupon Used',
                                          value: controller.couponUsed,
                                          index: 0
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Coupon Discount Total',
                                          value: controller.couponDiscountTotal.toInt(),
                                          isCurrency: true,
                                          index: 0
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Returning Customers',
                                          value: 0,
                                          isCurrency: true,
                                          index: 0
                                      ),
                                    ],
                                  )
                                ],
                                _buildThreeColumnRow(
                                  label: 'Purchase',
                                  value: controller.purchasesTotal,
                                  isCurrency: true,
                                  index: 1,
                                  isExpanded:
                                  controller.isPurchaseExpanded.value,
                                  onToggle: () => controller.isPurchaseExpanded.toggle(),
                                ),
                                if (controller.isPurchaseExpanded.value) ...[
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      _buildThreeColumnChild(
                                          label: 'Purchase',
                                          value: controller.purchasesTotal,
                                          count: controller.purchasesCount,
                                          isCurrency: true,
                                          index: 1
                                      ),
                                    ],
                                  )
                                ],
                                _buildThreeColumnRow(
                                  label: 'Unit Matrix(AOV)',
                                  value: controller.averageOrderValue.toInt(),
                                  index: 2,
                                  isExpanded:
                                  controller.isUnitMatrixExpanded.value,
                                  onToggle: () => controller.isUnitMatrixExpanded.toggle(),
                                ),
                                if (controller.isUnitMatrixExpanded.value) ...[
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      _buildThreeColumnChild(
                                          label: 'COGS',
                                          value: controller.unitCogs.toInt(),
                                          percent: controller.unitCogsPercent,
                                          isCurrency: true,
                                          index: 2
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Shipping',
                                          value: controller.unitShipping.toInt(),
                                          percent: controller.unitShippingPercent,
                                          isCurrency: true,
                                          index: 2
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Ads',
                                          value: controller.unitAds.toInt(),
                                          percent: controller.unitAdsPercent,
                                          isCurrency: true,
                                          index: 2
                                      ),
                                      _buildThreeColumnChild(
                                          label: 'Profit',
                                          value: controller.unitProfit.toInt(),
                                          percent: controller.unitProfitPercent,
                                          isCurrency: true,
                                          index: 2
                                      ),
                                    ],
                                  )
                                ],
                                _buildThreeColumnRow(
                                  label: 'Attributes',
                                  value: controller.revenueTotal,
                                  isCurrency: true,
                                  index: 3,
                                  isExpanded: controller.isAttributesExpanded.value,
                                  onToggle: () => controller.isAttributesExpanded.toggle(),
                                ),

                                if (controller.isAttributesExpanded.value) ...[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildThreeColumnChild(
                                        label: 'Total Revenue',
                                        value: controller.revenueTotal,
                                        count: controller.orderTotal,
                                        isCurrency: true,
                                        index: 0,
                                      ),
                                      for (var summary in controller.revenueSummaries) ...[
                                        _buildThreeColumnChild(
                                          label: summary.type, // ads, referral, etc.
                                          value: summary.totalRevenue.toInt(),
                                          count: summary.orderCount,
                                          percent: summary.percent.toInt(),
                                          isCurrency: true,
                                          index: 0,
                                        ),
                                        for (var entry in summary.sourceBreakdown)
                                          _buildThreeColumnChild(
                                            label: '• ${entry.source}',
                                            count: entry.orderCount,
                                            value: entry.revenue,
                                            percent: entry.percent.toInt(),
                                            isCurrency: true,
                                            index: 1,
                                          ),
                                      ],
                                    ],
                                  ),
                                ]

                              ],
                            )
                        ],
                      );
                    }
                  })
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildThreeColumnRow({
    required String label,
    required int value,
    int? percent,
    bool isCurrency = false,
    int index = 0, // Add index to determine row background
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final isEven = index % 2 == 0;

    return ListTile(
      tileColor: isEven ? Theme.of(Get.context!).colorScheme.surface : Colors.transparent, // Alternate background
      dense: true,
      contentPadding: AppSpacingStyle.defaultPageHorizontal,
      title: Row(
        children: [
          InkWell(
              onTap: onToggle,
              child: Icon(
                isExpanded ? Icons.remove : Icons.add, // toggle icon
                size: 22,
                color: AppColors.linkColor,
              ),
          ),
          SizedBox(width: AppSizes.defaultSpace),
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isCurrency ? AppSettings.currencySymbol : '', style: TextStyle(fontSize: 13, color: Theme.of(Get.context!).colorScheme.onSurface,)),
          Text(value.toString(), style: TextStyle(fontSize: 14, color: Theme.of(Get.context!).colorScheme.onSurface,)),
          SizedBox(width: AppSizes.xl),
          SizedBox(
            width: 40, // Fixed width enough for '100%'
            child: percent != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$percent%',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  )
                : SizedBox(), // Empty but same width
          ),
        ],
      ),
    );
  }

  Widget _buildThreeColumnChild({
    required String label,
    required int value,
    int? count,
    int? percent,
    bool isCurrency = false,
    int index = 0, // Add index to determine row background
  }) {
    final isEven = index % 2 == 0;
    final isNegative = value < 0;
    final color = isNegative ? Colors.red : Theme.of(Get.context!).colorScheme.onSurface;

    return ListTile(
      tileColor: isEven ? Theme.of(Get.context!).colorScheme.surface : Colors.transparent, // Alternate background
      dense: true,
      contentPadding: const EdgeInsets.only(
        right: AppSizes.defaultSpace,
        left: AppSizes.defaultSpace * 2,
      ),
      title: Text(label, style: TextStyle(fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (isCurrency)
                  TextSpan(
                    text: AppSettings.currencySymbol,
                    style: TextStyle(fontSize: 13, color: color),
                  ),
                TextSpan(
                  text: value.toString() + (count != null ? ' ($count)' : ''),
                  style: TextStyle(fontSize: 14, color: color),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.xl),
          SizedBox(
            width: 40, // Fixed width enough for '100%'
            child: percent != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$percent%',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  )
                : SizedBox(), // Empty but same width
          ),
        ],
      ),
    );
  }

  Widget _buildThreeColumnHeading() {
    return ListTile(
      dense: true,
      contentPadding: AppSpacingStyle.defaultPageHorizontal,
      title: Text('Particulars', style: TextStyle(fontSize: 13, color: Theme.of(Get.context!).colorScheme.onSurfaceVariant)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('(In ${AppSettings.currencySymbol})', style: TextStyle(fontSize: 13)),
          SizedBox(width: AppSizes.xl),
          SizedBox(
            width: 40, // Fixed width enough for '100%'
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Ratio',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            )
          ),
        ],
      ),
    );
  }
}
