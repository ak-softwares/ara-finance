import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../../personalization/models/user_model.dart';
import '../../controller/transaction/add_transaction_controller.dart';
import '../../controller/transaction/transaction_controller.dart';
import '../../models/account_model.dart';
import '../../models/transaction_model.dart';
import '../accounts/widget/account_tile.dart';
import '../purchase/purchase_entry/widget/search_products.dart';
import '../vendor/widget/vendor_tile.dart'; // Updated import

class AddTransaction extends StatelessWidget {
  const AddTransaction({super.key, this.transaction});

  final TransactionModel? transaction; // Updated model

  @override
  Widget build(BuildContext context) {
    final AddTransactionController controller = Get.put(AddTransactionController()); // Updated controller

    // If editing an existing transaction, reset the form values
    if (transaction != null) {
      controller.resetValue(transaction!);
    }

    return Scaffold(
      appBar: AppAppBar(title: transaction != null ? 'Update Transaction' : 'Add Transaction'), // Updated title
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => transaction != null
              ? controller.saveUpdatedTransaction(oldTransaction: transaction!) // Updated method
              : controller.saveTransaction(), // Updated method
          child: Text(
            transaction != null ? 'Update Transaction' : 'Add Transaction',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.transactionFormKey, // Updated form key
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

                // Vendor
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vendor'),
                        InkWell(
                          onTap: () async {
                            // Navigate to the search screen and wait for the result
                            final UserModel getSelectedVendor = await showSearch(context: context,
                              delegate: SearchVoucher1(
                                  searchType: SearchType.vendor,
                                  selectedItems: controller.selectedVendor.value
                              ),
                            );
                            // If products are selected, update the state
                            if (getSelectedVendor.companyName != null) {
                              controller.addVendor(getSelectedVendor);
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
                    Obx(() => controller.selectedVendor.value.companyName != '' && controller.selectedVendor.value.companyName != null
                        ? Dismissible(
                        key: Key(controller.selectedVendor.value.companyName ?? ''), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe left to remove
                        onDismissed: (direction) {
                          controller.selectedVendor.value = UserModel();
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vendor removed")),);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: VendorTile(vendor: controller.selectedVendor.value))
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

                // Payment
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Method'),
                        InkWell(
                          onTap: () async {
                            // Navigate to the search screen and wait for the result
                            final AccountModel getSelectedPayment = await showSearch(context: context,
                              delegate: SearchVoucher1(searchType: SearchType.paymentMethod),
                            );
                            // If products are selected, update the state
                            if (getSelectedPayment.accountName != null) {
                              controller.selectedPaymentMethod(getSelectedPayment);
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
                    Obx(() => controller.selectedPaymentMethod.value.accountName != '' && controller.selectedPaymentMethod.value.accountName != null
                        ? Dismissible(
                        key: Key(controller.selectedPaymentMethod.value.accountName ?? ''), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe left to remove
                        onDismissed: (direction) {
                          controller.selectedPaymentMethod.value = AccountModel();
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Method removed")),);
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: SizedBox(width: double.infinity, child: AccountTile(account: controller.selectedPaymentMethod.value))
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