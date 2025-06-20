import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/accounts/models/transaction_model.dart';
import '../../features/accounts/screen/transaction/widget/transaction_simmer.dart';
import '../../features/accounts/screen/transaction/widget/transaction_tile.dart';
import '../../utils/constants/enums.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../dialog_box_massages/animation_loader.dart';
import '../widgets/common/heading_for_ledger.dart';
import 'product_grid_layout.dart';

class TransactionGridLayout extends StatelessWidget {
  const TransactionGridLayout({
    super.key,
    required this.controller,
    this.voucherType,
    this.onTap,
  });

  final dynamic controller;
  final AccountVoucherType? voucherType;
  final ValueChanged<TransactionModel>? onTap;

  final Widget emptyWidget = const AnimationLoaderWidgets(
    text: 'Whoops! No transactions found...',
    animation: Images.pencilAnimation,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return TransactionTileShimmer(itemCount: 2);
      } else if (controller.transactions.isEmpty) {
        return emptyWidget;
      } else {
        final transactions = controller.transactions;
        return GridLayout(
          itemCount: controller.isLoadingMore.value ? transactions.length + 2 : transactions.length,
          crossAxisCount: 1,
          mainAxisExtent: AppSizes.transactionTileHeight,
          itemBuilder: (context, index) {
            if (index < transactions.length) {
              return TransactionTile(
                transaction: transactions[index],
              );
            } else {
              return TransactionTileShimmer();
            }
          },
        );
      }
    });
  }
}
