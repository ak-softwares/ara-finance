import 'package:flutter/material.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../models/order_model.dart';
import 'widget/sale_tile.dart';

class OrdersByStatus extends StatelessWidget {
  const OrdersByStatus({super.key, required this.orders, required this.orderStatus});

  final List<OrderStatus> orderStatus;
  final List<OrderModel> orders;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Purchase List Orders'),
      body: SingleChildScrollView(
        padding: AppSpacingStyle.defaultPagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSizes.sm,
          children: [
            Text(orderStatus.map((e) => e.prettyName).join(', ') ?? '',),
            GridLayout(
              itemCount: orders.length,
              crossAxisCount: 1,
              mainAxisExtent: AppSizes.saleTileHeight,
              itemBuilder: (context, index) {
                return SaleTile(sale: orders[index]);
              },
            ),
          ],
        ),
      )
    );
  }
}
