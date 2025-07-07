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
import '../../../setup/screens/app_user_list.dart';
import '../../controller/financial/financial_controller.dart';
import 'balance_sheet.dart';
import 'general_matrix.dart';
import 'profit_and_loss.dart';
import 'widgets/financial_heading.dart';
import 'widgets/financial_shimmer.dart';
import 'widgets/financial_tile.dart';

class Financials extends StatelessWidget {
  const Financials({super.key});

  @override
  Widget build(BuildContext context) {
    final FinancialController controller = Get.put(FinancialController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const financialsTabs = ['Profit & Loss', 'Balance Sheet', 'General Matrix'];

    return DefaultTabController(
      length: financialsTabs.length,
      child: Scaffold(
        appBar: AppAppBar(
          title: 'Financials',
          toolbarHeight: 40,
          bottom: AppTabBar(
            isScrollable: false,
            tabs: financialsTabs.map((tab) => Padding(
              padding: const EdgeInsets.only(
                top: AppSizes.defaultBtwTiles,
                bottom: AppSizes.defaultBtwTiles,
              ),
              child: Text(tab, style: const TextStyle(fontSize: 13)),
            )).toList(),
          ),
          widgetInActions: Obx(() {
            if(controller.userEmail == 'aramarket.in@gmail.com'){
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
                child: TextButton(
                  onPressed: () => Get.to(() => AppUserList()),
                  child: Text('Users: ${controller.userCount}', style: TextStyle(color: AppColors.linkColor),),
                )
              );
            }else {
              return SizedBox.shrink();
            }
          }),
        ),
        body: TabBarView(
          children: financialsTabs.map((financialsTab) {
            return _buildFinancialTabView(controller, financialsTab, financialsTabs, colorScheme);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFinancialTabView(
      FinancialController controller,
      String financialsTab,
      List<String> financialsTabs,
      ColorScheme colorScheme,
      ) {
    return RefreshIndicator(
      color: AppColors.refreshIndicator,
      onRefresh: controller.refreshFinancials,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildShortOptions(controller),
          FinancialHeading(),
          Obx(() {
            if (controller.isLoading.value) {
              return const FinancialShimmer();
            }
            return _buildTabContent(controller, financialsTab, financialsTabs);
          }),
        ],
      ),
    );
  }

  Widget _buildShortOptions(FinancialController controller) {
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

  Widget _buildTabContent(FinancialController controller, String financialsTab, List<String> financialsTabs) {
    switch (financialsTabs.indexOf(financialsTab)) {
      case 0: // Profit & Loss
        return ProfitAndLossTab();
      case 1: // Balance Sheet
        return BalanceSheetTab();
      case 2: // General Matrix
        return GeneralMatrixTab();
      default:
        return const SizedBox();
    }
  }


}