import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinancialTile extends StatelessWidget {

  const FinancialTile({
    super.key,
    required this.title,
    required this.value,
    this.count,
    this.percent,
    this.isCurrency = false,
    this.index = 0,
    this.isExpanded = false,
    this.isParent = false,
    this.onToggle,
  });

  final String title;
  final int value;
  final int? count;
  final int? percent;
  final bool isCurrency;
  final int index;
  final bool isExpanded;
  final bool isParent;
  final VoidCallback? onToggle;



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(Get.context!);
    final isEven = index % 2 == 0;
    final isNegative = value < 0;
    final color = isNegative ? Colors.red : theme.colorScheme.onSurface;

    return ListTile(
      tileColor: isEven ? theme.colorScheme.surface : Colors.transparent,
      dense: true,
      contentPadding: isParent
          ? const EdgeInsets.symmetric(horizontal: 16)
          : const EdgeInsets.only(left: 32.0, right: 16.0),
      title: Row(
        children: [
          if (isParent)
            InkWell(
              onTap: onToggle,
              child: Icon(
                isExpanded ? Icons.remove : Icons.add,
                size: 22,
                color: Colors.blue,
              ),
            ),
          if (isParent) const SizedBox(width: 10),
          Expanded(child: Text(title, style: TextStyle(fontSize: isParent ? 14 : 13), overflow: TextOverflow.ellipsis, maxLines: 1)),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (isCurrency)
                  TextSpan(
                    text: '₹', // You can use AppSettings.currencySymbol
                    style: TextStyle(fontSize: 13, color: color),
                  ),
                TextSpan(
                  text: value.toString() +
                      (count != null ? ' ($count)' : ''),
                  style: TextStyle(
                      fontSize: isParent ? 14 : 13, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 40,
            child: percent != null
                ? Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$percent%',
                style: TextStyle(
                    fontSize: isParent ? 14 : 13,
                    color: Colors.grey.shade600),
              ),
            )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
