import 'package:ara_finance/common/widgets/common/colored_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                Text('Transaction Id', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                Row(
                  children: [
                    Text('#${transaction.transactionId.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                    if(transaction.transactionType == AccountVoucherType.sale)
                    Row(
                      spacing: AppSizes.spaceBtwItems,
                      children: [
                        Text('/${transaction.orderIds?.first.toString()}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: (transaction.orderIds?.first).toString()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order Id copied')),
                            );
                          },
                          child: const Icon(Icons.copy, size: 17),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                Text(AppFormatter.formatStringDate(transaction.date.toString()), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
              ],
            ),
            if(transaction.transactionType == AccountVoucherType.sale)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                  ColoredStatusText(status: transaction.status),                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('From Entity', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                  Text(transaction.fromAccountVoucher?.title ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Amount', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                Text(transaction.amount?.toStringAsFixed(2) ?? 'N/A', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('To Entity', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                Text(transaction.toAccountVoucher?.title ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Transaction Type', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                Text(transaction.transactionType?.name.capitalizeFirst ?? '', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}