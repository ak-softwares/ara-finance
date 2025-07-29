import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/formatters/formatters.dart';
import '../../../../controller/transaction/expense/add_expenses_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import '../../../search/search_and_select/search_products.dart';

class AddExpenseTransaction extends StatelessWidget {
  const AddExpenseTransaction({super.key, this.expense});

  final TransactionModel? expense;

  @override
  Widget build(BuildContext context) {
    final AddExpenseTransactionController controller = Get.put(AddExpenseTransactionController()); // ✅ Changed controller

    if (expense != null) {
      controller.resetValue(expense!);
    }

    return Scaffold(
      appBar: AppAppBar(title: expense != null ? 'Update Expense' : 'Add Expense'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => expense != null
              ? controller.saveUpdatedExpenseTransaction(oldExpenseTransaction: expense!) // ✅ Changed method
              : controller.saveExpenseTransaction(), // ✅ Changed method
          child: Text(
            expense != null ? 'Update Expense' : 'Add Expense',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.expenseFormKey, // ✅ Changed form key
            child: Column(
              spacing: AppSizes.spaceBtwSection,
              children: [

                // Date and Transaction ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Transaction ID - '),
                        expense != null
                            ? Text('#${expense!.transactionId}', style: const TextStyle(fontSize: 14))
                            : Obx(() => Text('#${controller.transactionId.value}', style: const TextStyle(fontSize: 14))),
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

                // Select Expense
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Expense'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedExpense = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.expense),
                            );
                            if (getSelectedExpense.id != null) {
                              controller.selectedExpense(getSelectedExpense);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(Icons.add, color: AppColors.linkColor),
                              Text('Add', style: TextStyle(color: AppColors.linkColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.selectedExpense.value.id != null
                        ? Dismissible(
                              key: Key(controller.selectedExpense.value.id ?? ''),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                controller.selectedExpense.value = AccountVoucherModel();
                                AppMassages.showSnackBar(massage: 'Expense removed');
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: AccountVoucherTile(accountVoucher: controller.selectedExpense.value, voucherType: AccountVoucherType.bankAccount)
                              )
                          )
                        : SizedBox.shrink(),
                    ),
                  ],
                ),

                // Amount Field
                TextFormField(
                  controller: controller.amount,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                // Select Account
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
                            final AccountVoucherModel getSelectedPayment = await showSearch(context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.bankAccount),
                            );
                            // If products are selected, update the state
                            if (getSelectedPayment.id != null) {
                              controller.selectedBankAccount(getSelectedPayment);
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
                    Obx(() => controller.selectedBankAccount.value.id != null
                        ? Dismissible(
                              key: Key(controller.selectedBankAccount.value.id ?? ''), // Unique key for each item
                              direction: DismissDirection.endToStart, // Swipe left to remove
                              onDismissed: (direction) {
                                controller.selectedBankAccount.value = AccountVoucherModel();
                                AppMassages.showSnackBar(massage: 'Account removed');
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: SizedBox(
                                  width: double.infinity,
                                  child: AccountVoucherTile(accountVoucher: controller.selectedBankAccount.value, voucherType: AccountVoucherType.bankAccount)
                              )
                          )
                        : SizedBox.shrink(),
                    ),
                  ],
                ),

                // Description
                TextFormField(
                  controller: controller.description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
