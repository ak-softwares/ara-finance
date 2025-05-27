import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/expenses/expenses_controller.dart';
import '../../models/expense_model.dart';
import '../transaction/widget/transactions_by_entity.dart';
import 'add_expenses.dart';

class SingleExpenseScreen extends StatefulWidget {
  const SingleExpenseScreen({super.key, required this.expense});

  final ExpenseModel expense;

  @override
  State<SingleExpenseScreen> createState() => _SingleExpenseScreenState();
}

class _SingleExpenseScreenState extends State<SingleExpenseScreen> {
  late ExpenseModel expense;
  final controller = Get.put(ExpenseController());
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    expense = widget.expense;
  }

  Future<void> _refreshExpense() async {
    final updatedExpense = await controller.getExpenseById(id: expense.id ?? '');
    setState(() {
      expense = updatedExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppAppBar(
        title: expense.expenseType?.name ?? 'Expense Details',
        widgetInActions: IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () => Get.to(() => AddExpenseScreen(expense: expense)),
          ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: _refreshExpense,
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Expense Summary Card
            Container(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense ID
                  _buildDetailRow('Expense ID', '#${expense.expenseId}'),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Amount
                  _buildDetailRow(
                    'Amount',
                    currencyFormat.format(expense.amount ?? 0),
                    valueStyle: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Category
                  _buildDetailRow('Expense Type', expense.expenseType?.name ?? ExpenseType.other.name),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Payment Method
                  _buildDetailRow('Account Name', expense.account?.accountName ?? 'Not specified'),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Date
                  _buildDetailRow(
                    'Date',
                    expense.dateCreated != null
                        ? DateFormat('MMM dd, yyyy').format(expense.dateCreated!)
                        : 'No date',
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Description
                  if (expense.description?.isNotEmpty ?? false) ...[
                    Text('Description:', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSizes.spaceBtwItems / 2),
                    Text(expense.description ?? '',
                        style: theme.textTheme.bodyLarge),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSection),

            // Related Transactions Section
            const SectionHeading(title: 'Related Transactions'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            SizedBox(
              height: 350,
              child: TransactionsByEntity(
                entityType: EntityType.expense,
                entityId: expense.id ?? '0',
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSection),

            // Delete Button
            Center(
              child: TextButton(
                onPressed: () => controller.deleteExpense(expense: expense, context: context),
                child: Text(
                  'Delete Expense',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: valueStyle ?? Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

}