import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../features/settings/app_settings.dart';
import '../../../utils/constants/enums.dart';

class ColoredAmount extends StatelessWidget {
  const ColoredAmount({
    super.key,
    required this.amount,
  });

  final double amount;

  @override
  Widget build(BuildContext context) {
    Color textColor;

    if (amount == 0) {
      textColor = Colors.black;
    } else if (amount < 0) {
      textColor = Colors.red;
    } else {
      textColor = Colors.green;
    }

    return Text(
      AppSettings.currencySymbol + amount.toStringAsFixed(0),
      style: TextStyle(
        fontSize: 14,
        color: textColor,
        fontWeight: FontWeight.bold
      ),
    );
  }
}

class ColoredStatusText extends StatelessWidget {
  const ColoredStatusText({
    super.key,
    required this.status,
  });

  final OrderStatus? status;

  Color get textColor {
    switch (status) {
      case OrderStatus.returned:
        return Colors.red;
      case OrderStatus.inTransit:
        return Colors.blue;
      default:
        return Theme.of(Get.context!).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      status?.name.capitalizeFirst ?? '',
      style: TextStyle(
        fontSize: 14,
        color: textColor,
      ),
    );
  }
}
