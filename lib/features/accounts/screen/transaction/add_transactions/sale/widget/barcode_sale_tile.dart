import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../../utils/constants/sizes.dart';
import '../../../../../../settings/app_settings.dart';

class BarcodeSaleTile extends StatelessWidget {
  const BarcodeSaleTile({
    super.key,
    required this.orderId,
    this.invoiceId,
    this.amount,
    this.color,
    this.leadingIcon = Icons.qr_code,
    required this.onClose,
  });

  final int orderId;
  final int? invoiceId;
  final int? amount;
  final IconData leadingIcon;
  final VoidCallback onClose;
  final Color? color;

  @override
  Widget build(BuildContext context) {

    return Container(
      color: color ?? Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(leadingIcon),
        title: Row(
          spacing: AppSizes.spaceBtwItems,
          children: [
            Text('#$invoiceId/$orderId'),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: orderId.toString()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order Id copied')),
                );
              },
              child: const Icon(Icons.copy, size: 17),
            )
          ],
        ),
        subtitle: Text(amount != null ? '${AppSettings.currencySymbol}$amount' : ''),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: onClose,
        ),
      ),
    );
  }
}