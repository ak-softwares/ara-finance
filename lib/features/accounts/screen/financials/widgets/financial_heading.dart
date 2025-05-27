import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinancialHeading extends StatelessWidget {
  const FinancialHeading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(Get.context!);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16), // Or use AppSpacingStyle.defaultPageHorizontal
      title: Text(
        'Particulars',
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '(In ₹)', // Or use AppSettings.currencySymbol
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 16), // Or use AppSizes.xl
          const SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Ratio',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
