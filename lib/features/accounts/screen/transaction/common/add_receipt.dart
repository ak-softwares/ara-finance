import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/navigation_bar/appbar.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatters.dart';
import '../../../../personalization/models/user_model.dart';
import '../../../controller/transaction/add_payment_controller.dart';
import '../../../controller/transaction/add_receipt_controller.dart';
import '../../../controller/transaction/transaction_controller.dart';
import '../../../models/account_model.dart';
import '../../../models/transaction_model.dart';
import '../../accounts/widget/account_tile.dart';
import '../../customers/widget/customer_tile.dart';
import '../../purchase/purchase_entry/widget/search_products.dart';
import '../../vendor/widget/vendor_tile.dart'; // Updated import

class AddReceipt extends StatelessWidget {
  const AddReceipt({super.key, this.transaction});

  final TransactionModel? transaction; // Updated model

  @override
  Widget build(BuildContext context) {
    final AddReceiptController controller = Get.put(AddReceiptController()); // Updated controller

    // If editing an existing transaction, reset the form values
    if (transaction != null) {
      controller.resetValue(transaction!);
    }

    return Scaffold(
      appBar: AppAppBar(title: transaction != null ? 'Update Receipt' : 'Add Receipt'), // Updated title
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => transaction != null
              ? controller.saveUpdatedReceiptTransaction(oldReceiptTransaction: transaction!) // Updated method
              : controller.saveReceiptTransaction(), // Updated method
          child: Text(
            transaction != null ? 'Update Receipt' : 'Add Receipt',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.receiptFormKey, // Updated form key
            child: Column(
              spacing: AppSizes.spaceBtwSection,
              children: [

                // Date and Voucher number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Transaction ID - '),
                        transaction != null
                            ? Text('#${transaction!.transactionId}', style: const TextStyle(fontSize: 14))
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

                // Customer
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Customer'),
                        InkWell(
                          onTap: () async {
                            // Navigate to the search screen and wait for the result
                            final UserModel getSelectedCustomer = await showSearch(context: context,
                              delegate: SearchVoucher1(
                                  searchType: SearchType.customer,
                                  selectedItems: controller.selectedCustomer.value
                              ),
                            );
                            // If products are selected, update the state
                            if (getSelectedCustomer.id != null) {
                              controller.addCustomer(getSelectedCustomer);
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
                    Obx(() => controller.selectedCustomer.value.id != '' && controller.selectedCustomer.value.id != null
                        ? Dismissible(
                        key: Key(controller.selectedCustomer.value.id ?? ''), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe left to remove
                        onDismissed: (direction) {
                          controller.selectedCustomer.value = UserModel();
                          AppMassages.showSnackBar(massage: 'Customer removed');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: CustomerTile(customer: controller.selectedCustomer.value))
                    )
                        : SizedBox.shrink(),
                    ),
                  ],
                ),

                // Amount Field
                TextFormField(
                  controller: controller.amount, // Updated controller
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                // Account
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
                            if (getSelectedPayment.accountName != null) {
                              controller.selectedAccount(getSelectedPayment);
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
                    Obx(() => controller.selectedAccount.value.accountName != '' && controller.selectedAccount.value.accountName != null
                        ? Dismissible(
                        key: Key(controller.selectedAccount.value.accountName ?? ''), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe left to remove
                        onDismissed: (direction) {
                          controller.selectedAccount.value = AccountModel();
                          AppMassages.showSnackBar(massage: 'Account removed');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: AccountTile(account: controller.selectedAccount.value))
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