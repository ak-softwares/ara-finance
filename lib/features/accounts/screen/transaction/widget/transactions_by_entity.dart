import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/transaction/transaction_controller.dart';
import 'transaction_simmer.dart';
import 'transaction_tile.dart';

class TransactionsByEntity extends StatelessWidget {
  const TransactionsByEntity({super.key, required this.entityType, required this.entityId});

  final EntityType entityType;
  final String entityId;

  @override
  Widget build(BuildContext context) {
    final double transactionTileHeight = AppSizes.transactionTileHeight;
    final transactionController = Get.put(TransactionController());
    final ScrollController scrollController = ScrollController();

    transactionController.refreshTransactionByEntityId(entityType: entityType, entityId: entityId);

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if (!transactionController.isLoadingMore.value) {
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (transactionController.transactionsByEntity.length % itemsPerPage != 0) {
            // If the length of transactions is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          transactionController.isLoadingMore(true);
          transactionController.currentPage++; // Increment current page
          await transactionController.getTransactionByEntity(entityType: entityType, entityId: entityId); // Updated method
          transactionController.isLoadingMore(false);
        }
      }
    });


    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Transactions Found...', // Updated text
      animation: Images.pencilAnimation,
    );

    // onRefresh: () async => transactionController.refreshTransactionByEntity(entityType: entityType, entityId: entityId),

    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900  // Dark mode color
          : Colors.grey.shade50,  // Light mode color
      child: ListView(
        shrinkWrap: true,
        controller: scrollController,
        padding: AppSpacingStyle.defaultPagePadding,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Obx(() {
            if (transactionController.isLoading.value) {
              return TransactionTileShimmer(itemCount: 2); // Updated shimmer
            } else if (transactionController.transactionsByEntity.isEmpty) {
              return emptyWidget;
            } else {
              final transactions = transactionController.transactionsByEntity; // Updated list
              return Column(
                children: [
                  GridLayout(
                    itemCount: transactionController.isLoadingMore.value
                        ? transactions.length + 2
                        : transactions.length,
                    crossAxisCount: 1,
                    mainAxisExtent: transactionTileHeight, // Updated height
                    itemBuilder: (context, index) {
                      if (index < transactions.length) {
                        return TransactionTile(transaction: transactions[index]); // Updated tile
                      } else {
                        return TransactionTileShimmer(); // Updated shimmer
                      }
                    },
                  ),
                ],
              );
            }
          }),
        ],
              ),
    );
  }
}
