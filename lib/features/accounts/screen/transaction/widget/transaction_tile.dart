import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatters.dart';
import '../../../models/transaction_model.dart';
import '../single_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionModel transaction; // Updated model

  @override
  Widget build(BuildContext context) {
    const double transactionTileHeight = AppSizes.transactionTileHeight; // Updated constant
    const double transactionTileWidth = AppSizes.transactionTileWidth; // Updated constant
    const double transactionTileRadius = AppSizes.transactionTileRadius; // Updated constant
    const double transactionImageHeight = AppSizes.transactionImageHeight; // Updated constant
    const double transactionImageWidth = AppSizes.transactionImageWidth; // Updated constant

    return InkWell(
      onTap: () => Get.to(() => SingleTransaction(transaction: transaction)), // Updated navigation
      child: Container(
        // width: transactionTileWidth,
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(transactionTileRadius),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transaction Id', style: TextStyle(fontSize: 14)),
                Text('#${transaction.transactionId.toString()}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Date', style: TextStyle(fontSize: 14)),
                Text(AppFormatter.formatStringDate(transaction.date.toString()), style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('From Entity', style: TextStyle(fontSize: 14)),
                Text(transaction.fromEntityName ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Amount', style: TextStyle(fontSize: 14)),
                Text(transaction.amount?.toStringAsFixed(2) ?? 'N/A', style: const TextStyle(fontSize: 14)),
              ],
            ),
            if(transaction.toEntityType != null)
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('To Entity', style: TextStyle(fontSize: 14)),
                Text(transaction.toEntityName ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Method', style: TextStyle(fontSize: 14)),
                Text(transaction.transactionType?.name.capitalizeFirst ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
            if(transaction.transactionType == TransactionType.purchase)
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Purchase ID', style: TextStyle(fontSize: 14)),
                Text('#${transaction.purchaseId.toString()}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}