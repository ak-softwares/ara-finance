import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/accounts/models/transaction_model.dart';
import '../../../features/accounts/screen/transaction/single_transaction.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/formatters/formatters.dart';

class HeadingRowForLedger extends StatelessWidget {
  const HeadingRowForLedger({
    super.key,
    this.firstRow = 'Particulars',
    this.middleRow = 'Voucher',
    this.lastRow = 'Amount',
  });

  final String firstRow, middleRow, lastRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double fontSize = 13;
    final Color fontColor = theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(firstRow, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ),
        Expanded(
          flex: 3,
          child: Text(middleRow, style: TextStyle(fontSize: 13, color: Colors.black54)),
        ),
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(lastRow, style: TextStyle(fontSize: 13, color: Colors.black54)),
          ),
        ),
      ],
    );
  }
}

class TransactionsDataInRows extends StatelessWidget {
  const TransactionsDataInRows({
    super.key,
    required this.transaction,
    required this.voucherId,
    this.total,
    this.index = 0,
  });

  final String voucherId;
  final TransactionModel transaction;
  final double? total;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double fontSize = 14;
    final double subtitleFontSize = 13;
    final isEven = index % 2 == 0;

    final Color fontColor = theme.colorScheme.onSurface;
    final Color subtitleFontColor = theme.colorScheme.onSurfaceVariant;
    final Color amountColor = voucherId == transaction.fromAccountVoucher?.id ? Colors.red : Colors.green;

    return InkWell(
      onTap: () => Get.to(() => SingleTransaction(transaction: transaction)), // Updated navigation
      child: Container(
        color: isEven ? theme.colorScheme.surface : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
        child: Row(
          children: [
            /// Column 1: Particulars
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    voucherId != transaction.fromAccountVoucher?.id
                        ? transaction.fromAccountVoucher?.title ?? ''
                        : transaction.toAccountVoucher?.title ?? '',
                    style: TextStyle(fontSize: fontSize, color: fontColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppFormatter.formatDate(transaction.date),
                    style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                  ),
                ],
              ),
            ),

            /// Column 2: Voucher
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    transaction.transactionType?.name.capitalizeFirst ?? '',
                    style: TextStyle(fontSize: fontSize, color: fontColor),
                  ),
                  Row(
                    children: [
                      Text(
                        transaction.transactionId.toString(),
                        style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                      ),
                      if(transaction.transactionType == AccountVoucherType.sale)
                        Text('/${(transaction.orderIds?.first).toString()}',
                          style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            /// Column 3: Amount
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    transaction.amount?.toStringAsFixed(0) ?? '0',
                    style: TextStyle(fontSize: fontSize, color: amountColor),
                  ),
                  Text(
                    total?.toStringAsFixed(0) ?? '',
                    style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsDataInRowsForProducts extends StatelessWidget {
  const TransactionsDataInRowsForProducts({
    super.key,
    required this.transaction,
    this.totalStock,
    this.index = 0,
    this.stock = 0,
  });

  final TransactionModel transaction;
  final int? totalStock;
  final int index, stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double fontSize = 14;
    final double subtitleFontSize = 13;
    final isEven = index % 2 == 0;

    final Color fontColor = theme.colorScheme.onSurface;
    final Color subtitleFontColor = theme.colorScheme.onSurfaceVariant;
    final Color amountColor = transaction.transactionType != AccountVoucherType.purchase ? Colors.red : Colors.green;

    return InkWell(
      onTap: () => Get.to(() => SingleTransaction(transaction: transaction)), // Updated navigation
      child: Container(
        color: isEven ? theme.colorScheme.surface : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
        child: Row(
          children: [
            /// Column 1: Particulars
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    transaction.toAccountVoucher?.title ?? '',
                    style: TextStyle(fontSize: fontSize, color: fontColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppFormatter.formatDate(transaction.date),
                    style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                  ),
                ],
              ),
            ),

            /// Column 2: Voucher
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        transaction.transactionType?.name.capitalizeFirst ?? '',
                        style: TextStyle(fontSize: fontSize, color: fontColor),
                      ),
                      if(transaction.transactionType == AccountVoucherType.sale && transaction.status == OrderStatus.returned)
                        const Text('(Returned)', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        transaction.transactionId.toString(),
                        style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                      ),
                      if(transaction.transactionType == AccountVoucherType.sale)
                        Text('/${(transaction.orderIds?.first).toString()}',
                          style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            /// Column 3: Amount
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stock.toString(),
                    style: TextStyle(fontSize: fontSize, color: amountColor),
                  ),
                  Text(
                    totalStock?.toStringAsFixed(0) ?? '',
                    style: TextStyle(fontSize: subtitleFontSize, color: subtitleFontColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
