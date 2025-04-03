import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/navigation_bar/appbar2.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller_account/expenses/expenses_controller.dart';
import '../../models/expense_model.dart';
import '../transacton/widget/transactions_by_entity.dart';
import 'add_expenses.dart';

class SingleExpenseScreen extends StatefulWidget {
  const SingleExpenseScreen({super.key, required this.expense});

  final ExpenseModel expense;

  @override
  State<SingleExpenseScreen> createState() => _SingleExpenseScreenState();
}

class _SingleExpenseScreenState extends State<SingleExpenseScreen> {
  late ExpenseModel expense;
  final expenseController = Get.put(ExpenseController());
  final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    expense = widget.expense;
  }

  Future<void> _refreshExpense() async {
    final updatedExpense = await expenseController.getExpenseById(id: expense.id ?? '');
    setState(() {
      expense = updatedExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppAppBar2(
        titleText: expense.title ?? 'Expense Details',
        widget: IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () => Get.to(() => AddExpenseScreen(expense: expense)),
          ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: _refreshExpense,
        child: ListView(
          padding: TSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Expense Summary Card
            Container(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              color: isDark ? AppColors.darkerGrey : AppColors.light,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense ID
                  _buildDetailRow('Expense ID', '#${expense.expenseId}'),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Title
                  _buildDetailRow('Title', expense.title ?? 'No title'),
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
                  _buildDetailRow('Category', expense.category ?? 'Uncategorized'),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Payment Method
                  _buildDetailRow('Payment Method', expense.paymentMethod ?? 'Not specified'),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Date
                  _buildDetailRow(
                    'Date',
                    expense.date != null
                        ? DateFormat('MMM dd, yyyy').format(expense.date!)
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
            const TSectionHeading(title: 'Related Transactions'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            SizedBox(
              height: 350,
              child: TransactionsByEntity(
                entityType: EntityType.expense,
                entityId: expense.expenseId ?? 0,
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSection),

            // Delete Button
            Center(
              child: TextButton(
                onPressed: () => _showDeleteConfirmation(context),
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              expenseController.deleteExpense(
                id: expense.id ?? '',
                context: context,
              );
              Get.back(); // Go back to previous screen after deletion
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}