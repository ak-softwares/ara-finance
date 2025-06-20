import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/transaction/transaction_controller.dart';
import '../../models/transaction_model.dart';
import 'add_transactions/add_expenses.dart';
import 'add_transactions/add_payment.dart';
import 'add_transactions/add_receipt.dart';
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
  final transactionController = Get.put(TransactionController()); // Updated controller

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction; // Initialize with the passed transaction
  }

  Future<void> _refreshTransaction() async {
    final updatedTransaction = await transactionController.getTransactionByID(id: transaction.id ?? '');
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
        widgetInActions: TextButton(
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
            }
          },
          child: Text('Edit', style: TextStyle(color: AppColors.linkColor)),
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

            // Delete Button
            Center(
              child: TextButton(
                onPressed: () => transactionController.deleteTransactionByDialog(context: context, transaction: transaction),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}