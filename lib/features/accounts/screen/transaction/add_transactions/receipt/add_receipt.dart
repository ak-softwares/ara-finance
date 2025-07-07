import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/formatters/formatters.dart';
import '../../../../controller/transaction/receipt/add_receipt_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import '../../../search/search_and_select/search_products.dart';

class AddReceipt extends StatelessWidget {
  const AddReceipt({super.key, this.receipt});

  final TransactionModel? receipt; // Updated model

  @override
  Widget build(BuildContext context) {
    final AddReceiptController controller = Get.put(AddReceiptController()); // Updated controller

    // If editing an existing transaction, reset the form values
    if (receipt != null) {
      controller.resetValue(receipt!);
    }

    return Scaffold(
      appBar: AppAppBar(title: receipt != null ? 'Update Receipt' : 'Add Receipt'), // Updated title
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => receipt != null
              ? controller.saveUpdatedReceiptTransaction(oldReceiptTransaction: receipt!) // Updated method
              : controller.saveReceiptTransaction(), // Updated method
          child: Text(
            receipt != null ? 'Update Receipt' : 'Add Receipt',
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
                        receipt != null
                            ? Text('#${receipt!.transactionId}', style: const TextStyle(fontSize: 14))
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
                        Text('Select customer'),
                        InkWell(
                          onTap: () async {
                            // Navigate to the search screen and wait for the result
                            final AccountVoucherModel getSelectedCustomer = await showSearch(context: context,
                              delegate: SearchVoucher1(
                                  voucherType: AccountVoucherType.customer,
                                  selectedItems: controller.selectedCustomer.value
                              ),
                            );
                            // If products are selected, update the state
                            if (getSelectedCustomer.id != null) {
                              controller.addSender(getSelectedCustomer);
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
                          controller.selectedCustomer.value = AccountVoucherModel();
                          AppMassages.showSnackBar(massage: 'Customer removed');
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: AccountVoucherTile(accountVoucher: controller.selectedCustomer.value, voucherType: AccountVoucherType.customer))
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

                    // Select Bank Account
                    Obx(() => controller.selectedBankAccount.value.id != null
                        ? Dismissible(
                            key: Key(controller.selectedBankAccount.value.id ?? ''), // Unique key for each item
                            direction: DismissDirection.endToStart, // Swipe left to remove
                            onDismissed: (direction) {
                              controller.selectedBankAccount.value = AccountVoucherModel();
                              AppMassages.showSnackBar(massage: 'Bank account removed');
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}