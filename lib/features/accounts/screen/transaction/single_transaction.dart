import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/dialog_massage.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../controller/transaction/transaction_controller.dart';
import '../../models/transaction_model.dart'; // Updated import
import 'add_transaction.dart'; // Updated import

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
            if(transaction.transactionType == TransactionType.purchase) {
              DialogHelper.showDialog(
                context: context,
                title: 'Error in Update Transaction',
                message: 'You can not update this purchase transactions instead you can update purchase '
                    'this transaction will update automatically',
                onSubmit: () async { },
                actionButtonText: 'Done',
              );
            } else {
              Get.to(() => AddTransaction(transaction: transaction));
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
            Container(
              width: transactionTileWidth,
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(transactionTileRadius),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                children: [
                  // Transaction ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transaction ID', style: TextStyle(fontSize: 14)),
                      Text('#${transaction.transactionId.toString()}', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount', style: TextStyle(fontSize: 14)),
                      Text(transaction.amount?.toStringAsFixed(2) ?? 'N/A', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Date', style: TextStyle(fontSize: 14)),
                      Text(AppFormatter.formatStringDate(transaction.date.toString()), style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  // Payment Method
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Payment Method', style: TextStyle(fontSize: 14)),
                      Text('N/A', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwSection),

            // Delete Button
            Center(
              child: TextButton(
                onPressed: () => transactionController.deleteTransactionByDialog(
                  context: context,
                  transaction: transaction
                ),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}