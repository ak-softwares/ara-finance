import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/formatters/formatters.dart';
import '../../../../controller/transaction/payment/add_payment_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import '../../../search/search_and_select/search_products.dart';

class AddPayment extends StatelessWidget {
  const AddPayment({super.key, this.payment});

  final TransactionModel? payment;

  @override
  Widget build(BuildContext context) {
    final AddPaymentController controller = Get.put(AddPaymentController());

    if (payment != null) {
      controller.resetValue(payment!);
    }

    return Scaffold(
      appBar: AppAppBar(title: payment != null ? 'Update Payment' : 'Add Payment'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => payment != null
              ? controller.saveUpdatedPaymentTransaction(oldPaymentTransaction: payment!)
              : controller.savePaymentTransaction(),
          child: Text(
            payment != null ? 'Update Payment' : 'Add Payment',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: AppSizes.sm),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.paymentFormKey,
            child: Column(
              spacing: AppSizes.spaceBtwSection,
              children: [

                // Date and Transaction ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Transaction ID - '),
                        payment != null
                            ? Text('#${payment!.transactionId}', style: const TextStyle(fontSize: 14))
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
                              const Text('Date - '),
                              Text(AppFormatter.formatStringDate(controller.date.text),
                                style: const TextStyle(color: AppColors.linkColor),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Select Bank Account
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Bank Account'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedAccount = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.bankAccount),
                            );
                            if (getSelectedAccount.id != null) {
                              controller.selectedBankAccount(getSelectedAccount);
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.add, color: AppColors.linkColor),
                              Text('Add', style: TextStyle(color: AppColors.linkColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.selectedBankAccount.value.id != null
                        ? Dismissible(
                      key: Key(controller.selectedBankAccount.value.id ?? ''),
                      direction: DismissDirection.endToStart,
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
                      ),
                    )
                        : const SizedBox.shrink(),
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

                // Select vendor
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select vendor'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedParty = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.vendor),
                            );
                            if (getSelectedParty.id != null) {
                              controller.selectedVendor(getSelectedParty);
                            }
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.add, color: AppColors.linkColor),
                              Text('Add', style: TextStyle(color: AppColors.linkColor)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.selectedVendor.value.id != null
                        ? Dismissible(
                            key: Key(controller.selectedVendor.value.id ?? ''),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              controller.selectedVendor.value = AccountVoucherModel();
                              AppMassages.showSnackBar(massage: 'Vendor removed');
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            child: SizedBox(
                                width: double.infinity,
                                child: AccountVoucherTile(accountVoucher: controller.selectedVendor.value, voucherType: AccountVoucherType.vendor)
                            ),
                          )
                        : const SizedBox.shrink(),
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
