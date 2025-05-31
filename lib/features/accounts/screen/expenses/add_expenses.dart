import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../../settings/app_settings.dart';
import '../../controller/expenses/add_expenses_controller.dart';
import '../../controller/expenses/expenses_controller.dart';
import '../../models/expense_model.dart';
import '../../models/account_model.dart';
import '../accounts/widget/account_tile.dart';
import '../purchase/purchase_entry/widget/search_products.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key, this.expense});

  final ExpenseModel? expense;

  @override
  Widget build(BuildContext context) {
    final AddExpenseController controller = Get.put(AddExpenseController());
    final theme = Theme.of(context);

    if (expense != null) {
      controller.prefillExpenseForm(expense!);
    }

    return Scaffold(
      appBar: AppAppBar(
        title: expense != null ? 'Update Expense' : 'Add New Expense',
        showBackArrow: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: ElevatedButton(
          onPressed: () => expense != null
              ? controller.prepareUpdatedExpense(previousExpense: expense!)
              : controller.prepareExpense(),
          child: Text(
            expense != null ? 'Update Expense' : 'Add Expense',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Form(
            key: controller.expenseFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Voucher number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Expense ID - '),
                        expense != null
                            ? Text('#${expense!.expenseId}', style: theme.textTheme.bodyLarge)
                            : Obx(() => Text('#${controller.expenseId.value}', style: theme.textTheme.bodyLarge)),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: controller.date,
                      builder: (context, value, child) {
                        return InkWell(
                          onTap: () => controller.selectDate(context),
                          child: Row(
                            children: [
                              Text('Date - '),
                              Text(AppFormatter.formatStringDate(controller.date.text),
                                style: TextStyle(color: AppColors.linkColor),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spaceBtwSection),

                DropdownButtonFormField<ExpenseType>(
                  value: controller.selectedExpenseType,
                  decoration: const InputDecoration(
                    labelText: 'Expense Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ExpenseType.values.map((ExpenseType type) {
                    return DropdownMenuItem<ExpenseType>(
                      value: type,
                      child: Text(type.name), // You can format this if needed
                    );
                  }).toList(),
                  onChanged: (ExpenseType? newValue) {
                    controller.selectedExpenseType = newValue;
                  },
                  validator: (value) =>
                  value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: AppSizes.inputFieldSpace),

                // Amount
                TextFormField(
                  controller: controller.amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '${AppSettings.currencySymbol} ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.inputFieldSpace),

                // Payment
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Account'),
                        InkWell(
                          onTap: () async {
                            // Navigate to the search screen and wait for the result
                            final AccountModel getSelectedPayment = await showSearch(context: context,
                              delegate: SearchVoucher1(searchType: SearchType.account),
                            );
                            // If products are selected, update the state
                            if (getSelectedPayment.id != null) {
                              controller.selectedAccountType(getSelectedPayment);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add, color: AppColors.linkColor),
                              Text('Add', style:  TextStyle(color: AppColors.linkColor),)
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.selectedAccountType.value.accountName != '' && controller.selectedAccountType.value.accountName != null
                        ? Dismissible(
                        key: Key(controller.selectedAccountType.value.accountName ?? ''), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe left to remove
                        onDismissed: (direction) {
                          controller.selectedAccountType.value = AccountModel();
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Method removed")),);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: AccountTile(account: controller.selectedAccountType.value))
                    )
                        : SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}