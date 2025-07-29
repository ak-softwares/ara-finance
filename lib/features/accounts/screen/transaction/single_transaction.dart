import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/models/address_model.dart';
import '../../../personalization/screens/user_address/address_widgets/single_address.dart';
import '../../../personalization/screens/user_address/update_sale_address.dart';
import '../../../personalization/screens/user_address/update_user_address.dart';
import '../../controller/transaction/transaction_controller.dart';
import '../../models/transaction_model.dart';
import 'add_transactions/contra_voucher/contra_voucher.dart';
import 'add_transactions/expenses/add_expenses.dart';
import 'add_transactions/payment/add_payment.dart';
import 'add_transactions/receipt/add_receipt.dart';
import 'add_transactions/purchase/add_purchase.dart';
import 'add_transactions/sale/add_sale.dart';
import 'widget/transaction_tile.dart';

class SingleTransaction extends StatefulWidget {
  const SingleTransaction({super.key, required this.transaction});

  final TransactionModel transaction; // Updated model

  @override
  State<SingleTransaction> createState() => _SingleTransactionState();
}

class _SingleTransactionState extends State<SingleTransaction> {
  late TransactionModel transaction;
  final controller = Get.put(TransactionController()); // Updated controller

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction; // Initialize with the passed transaction
  }

  Future<void> _refreshTransaction() async {
    final updatedTransaction = await controller.getTransactionByID(id: transaction.id ?? '');
    setState(() {
      transaction = updatedTransaction; // Update the transaction data
    });
  }

  @override
  Widget build(BuildContext context) {
    const double transactionTileHeight = AppSizes.transactionTileHeight; // Updated constant
    const double transactionTileWidth = AppSizes.transactionTileWidth; // Updated constant
    const double transactionTileRadius = AppSizes.transactionTileRadius; // Updated constant

    return Scaffold(
      appBar: AppAppBar(
        title: 'Transaction #${transaction.transactionId}', // Updated title
        widgetInActions: Row(
          children: [
            if(transaction.transactionType == AccountVoucherType.sale)
              IconButton(
                  onPressed: () => controller.saveAndOpenPdf(context: context, transaction: transaction),
                  icon: Icon(Icons.print, color: AppColors.linkColor,)
              ),
            TextButton(
              onPressed: () {
                if(transaction.transactionType == AccountVoucherType.expense) {
                  Get.to(() => AddExpenseTransaction(expense: transaction));
                } else if(transaction.transactionType == AccountVoucherType.payment) {
                  Get.to(() => AddPayment(payment: transaction));
                } else if(transaction.transactionType == AccountVoucherType.receipt) {
                  Get.to(() => AddReceipt(receipt: transaction));
                } else if(transaction.transactionType == AccountVoucherType.purchase) {
                  Get.to(() => AddPurchase(purchase: transaction));
                } else if(transaction.transactionType == AccountVoucherType.sale) {
                  Get.to(() => AddSale(sale: transaction));
                } else if(transaction.transactionType == AccountVoucherType.contra) {
                  Get.to(() => ContraVoucher(contra: transaction));
                }
              },
              child: Text('Edit', style: TextStyle(color: AppColors.linkColor)),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => _refreshTransaction(), // Updated method
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TransactionTile(transaction: transaction),
            SizedBox(height: AppSizes.defaultSpace),

            // Order Ids
            if(transaction.transactionType == AccountVoucherType.sale)
              // Address
              Column(
                children: [
                  const SectionHeading(title: 'Address', seeActionButton: false),
                  SingleAddress(
                    address: transaction.address ?? AddressModel(),
                    onTap: () => Get.to(() => UpdateTransactionAddress(transaction: transaction)),
                    // onTap: () {}
                  ),
                ],
              ),

            // Order Ids
            if(transaction.orderIds != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Ids', style: TextStyle(fontSize: 14)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.defaultSpace),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(transactionTileRadius),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText(
                          transaction.orderIds.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Expense Description
            if(transaction.transactionType == AccountVoucherType.expense)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: TextStyle(fontSize: 14)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.defaultSpace),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(transactionTileRadius),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Text(transaction.description ?? '', style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

            // Delete Button
            Center(
              child: TextButton(
                onPressed: () => controller.deleteTransactionByDialog(context: context, transaction: transaction),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}