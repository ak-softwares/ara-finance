import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/text/section_heading.dart';
import '../../../../../common/widgets/common/heading_for_ledger.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/transaction/transaction_controller.dart';
import 'transaction_simmer.dart';
import 'transaction_tile.dart';

class EntityTransactionList extends StatelessWidget {
  const EntityTransactionList({
    super.key,
    required this.voucherId,
    this.initialAmount = 0.0,
  });

  final String voucherId;
  final double initialAmount;

  @override
  Widget build(BuildContext context) {
    final TransactionController controller = Get.put(TransactionController());
    final ScrollController scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshTransactionByEntityId(voucherId: voucherId);
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if (!controller.isLoadingMore.value) {
          const int itemsPerPage = 10;
          if (controller.transactionsByEntity.length % itemsPerPage != 0) return;
          controller.isLoadingMore(true);
          controller.currentPage++;
          await controller.getTransactionByEntity(voucherId: voucherId);
          controller.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Transactions Found...',
      animation: Images.pencilAnimation,
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return TransactionTileShimmer(itemCount: 2);
      } else if (controller.transactionsByEntity.isEmpty) {
        return emptyWidget;
      } else {
        final transactions = controller.transactionsByEntity;
        double amount = initialAmount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading(title: 'Transaction'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            HeadingRowForLedger(),
            GridLayout(
              itemCount: controller.isLoadingMore.value ? transactions.length + 2 : transactions.length,
              crossAxisCount: 1,
              mainAxisExtent: 50,
              itemBuilder: (context, index) {
                if (index >= transactions.length) {
                  return TransactionTileShimmer();
                }

                final transaction = transactions[index];

                if (voucherId == transaction.formAccountVoucher?.id) {
                  amount += transaction.amount ?? 0;
                } else {
                  amount -= transaction.amount ?? 0;
                }

                return TransactionsDataInRows(
                  voucherId: voucherId,
                  transaction: transaction,
                  total: amount,
                  index: index,
                );
              },
            ),
          ],
        );
      }
    });
  }
}
