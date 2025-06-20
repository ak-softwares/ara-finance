import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/text/section_heading.dart';
import '../../../../../common/widgets/common/heading_for_ledger.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/transaction/transaction_controller.dart';
import '../../../models/transaction_model.dart';
import 'transaction_simmer.dart';
import 'transaction_tile.dart';

class EntityTransactionList extends StatefulWidget {
  const EntityTransactionList({
    super.key,
    required this.voucherId,
    this.initialAmount = 0.0,
    this.isRefresh = false,
  });

  final String voucherId;
  final double initialAmount;
  final bool isRefresh;

  @override
  State<EntityTransactionList> createState() => _EntityTransactionListState();
}

class _EntityTransactionListState extends State<EntityTransactionList> {

  // Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<TransactionModel> transactionsByEntity = <TransactionModel>[].obs;
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  // Get All products
  Future<void> getTransactionByEntity({required String voucherId}) async {
    try {
      if(widget.isRefresh){
        transactionsByEntity.clear();
      }
      final fetchedTransactions = await mongoTransactionRepo.fetchTransactionByEntity(
          voucherId: voucherId,
          page: currentPage.value
      );
      transactionsByEntity.addAll(fetchedTransactions);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTransactionByEntity(voucherId: widget.voucherId);
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if (!isLoadingMore.value) {
          const int itemsPerPage = 10;
          if (transactionsByEntity.length % itemsPerPage != 0) return;
          isLoadingMore(true);
          currentPage++;
          await getTransactionByEntity(voucherId: widget.voucherId);
          isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = Text('Whoops! No Transactions Found...');

    return Obx(() {
      if (isLoading.value) {
        return TransactionTileShimmer(itemCount: 2);
      } else if (transactionsByEntity.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading(title: 'Transaction'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            emptyWidget,
          ],
        );
      } else {
        final transactions = transactionsByEntity;
        double amount = widget.initialAmount;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading(title: 'Transaction'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            HeadingRowForLedger(),
            GridLayout(
              itemCount: isLoadingMore.value ? transactions.length + 2 : transactions.length,
              crossAxisCount: 1,
              mainAxisExtent: 50,
              itemBuilder: (context, index) {
                if (index >= transactions.length) {
                  return TransactionTileShimmer();
                }

                final transaction = transactions[index];

                if (widget.voucherId == transaction.fromAccountVoucher?.id) {
                  amount += transaction.amount ?? 0;
                } else {
                  amount -= transaction.amount ?? 0;
                }

                return TransactionsDataInRows(
                  voucherId: widget.voucherId,
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
