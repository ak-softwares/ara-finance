import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../../common/navigation_bar/appbar.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/formatters/formatters.dart';
import '../../../../controller/transaction/contra_voucher/contra_voucher_controller.dart';
import '../../../../models/account_voucher_model.dart';
import '../../../../models/transaction_model.dart';
import '../../../account_voucher/widget/account_voucher_tile.dart';
import '../../../search/search_and_select/search_products.dart';

class ContraVoucher extends StatelessWidget {
  const ContraVoucher({super.key, this.contra});

  final TransactionModel? contra;

  @override
  Widget build(BuildContext context) {
    final ContraVoucherController controller = Get.put(ContraVoucherController());

    if (contra != null) {
      controller.resetValue(contra!);
    }

    return Scaffold(
      appBar: AppAppBar(title: contra != null ? 'Update Contra Voucher' : 'Add Contra Voucher'),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
        child: ElevatedButton(
          onPressed: () => contra != null
              ? controller.saveUpdatedPaymentTransaction(oldPaymentTransaction: contra!)
              : controller.savePaymentTransaction(),
          child: Text(
            contra != null ? 'Update Contra Voucher' : 'Add Contra Voucher',
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
                        contra != null
                            ? Text('#${contra!.transactionId}', style: const TextStyle(fontSize: 14))
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

                // Select From Bank Account
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select From Bank Account'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedAccount = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.bankAccount),
                            );
                            if (getSelectedAccount.id != null) {
                              controller.fromBankAccount(getSelectedAccount);
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
                    Obx(() => controller.fromBankAccount.value.id != null
                        ? Dismissible(
                      key: Key(controller.fromBankAccount.value.id ?? ''),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        controller.fromBankAccount.value = AccountVoucherModel();
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
                          child: AccountVoucherTile(accountVoucher: controller.fromBankAccount.value, voucherType: AccountVoucherType.bankAccount)
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

                // Select to Bank Account
                Column(
                  spacing: AppSizes.spaceBtwItems,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select To Bank Account'),
                        InkWell(
                          onTap: () async {
                            final AccountVoucherModel getSelectedAccount = await showSearch(
                              context: context,
                              delegate: SearchVoucher1(voucherType: AccountVoucherType.bankAccount),
                            );
                            if (getSelectedAccount.id != null) {
                              controller.toBankAccount(getSelectedAccount);
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
                    Obx(() => controller.toBankAccount.value.id != null
                        ? Dismissible(
                            key: Key(controller.toBankAccount.value.id ?? ''),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              controller.toBankAccount.value = AccountVoucherModel();
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
                                child: AccountVoucherTile(accountVoucher: controller.toBankAccount.value, voucherType: AccountVoucherType.bankAccount)
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
