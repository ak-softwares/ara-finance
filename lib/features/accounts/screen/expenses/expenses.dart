import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../settings/app_settings.dart';
import '../../controller/expenses/expenses_controller.dart';
import 'add_expenses.dart';
import 'single_expense.dart';
import 'widget/expense_tile.dart';
import 'widget/expense_tile_simmer.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double expenseTileHeight = AppSizes.paymentTileHeight;

    final ScrollController scrollController = ScrollController();
    final expenseController = Get.put(ExpenseController());

    expenseController.refreshExpenses();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!expenseController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (expenseController.expenses.length % itemsPerPage != 0) {
            // If the length of expenses is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          expenseController.isLoadingMore(true);
          expenseController.currentPage++; // Increment current page
          await expenseController.getAllExpenses();
          expenseController.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'No Expenses Recorded Yet...',
      animation: Images.pencilAnimation,
      showAction: true,
      actionText: 'Add your first expense',
      onActionPress: () => Get.to(() => AddExpenseScreen()),
    );

    return Scaffold(
        appBar: const AppAppBar(title: 'Expense Tracker'),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppColors.primaryColor,
          onPressed: () => Get.to(() => const AddExpenseScreen()),
          tooltip: 'Add New Expense',
          child: const Icon(LineIcons.plus, size: 30, color: Colors.white),
        ),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async => expenseController.refreshExpenses(),
          child: ListView(
            controller: scrollController,
            padding: AppSpacingStyle.defaultPagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Summary card at the top
              Obx(() {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: AppSizes.defaultSpace),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly Summary', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Expenses:', style: Theme.of(context).textTheme.bodyLarge),
                            Text(AppSettings.currencySymbol + expenseController.totalMonthlyExpense.toStringAsFixed(2),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold
                                )),
                          ],
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Categories:', style: Theme.of(context).textTheme.bodyLarge),
                            Text('${expenseController.categoryCount}', style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Expenses list
              Obx(() {
                if (expenseController.isLoading.value) {
                  return const ExpenseTileShimmer(itemCount: 3);
                } else if(expenseController.expenses.isEmpty) {
                  return emptyWidget;
                } else {
                  final expenses = expenseController.expenses;
                  return Column(
                    children: [
                      GridLayout(
                          itemCount: expenseController.isLoadingMore.value ? expenses.length + 2 : expenses.length,
                          crossAxisCount: 1,
                          mainAxisExtent: expenseTileHeight,
                          itemBuilder: (context, index) {
                            if (index < expenses.length) {
                              return ExpenseTile(
                                expense: expenses[index],
                                onTap: () => Get.to(() => SingleExpenseScreen(expense: expenses[index])),
                              );
                            } else {
                              return const ExpenseTileShimmer();
                            }
                          }
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        )
    );
  }
}