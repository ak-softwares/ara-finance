import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/text/section_heading.dart';
import '../../../../../common/widgets/common/heading_for_ledger.dart';
import '../../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/transaction_model.dart';
import 'transaction_simmer.dart';

class ProductTransactionList extends StatefulWidget {
  const ProductTransactionList({
    super.key,
    required this.productId,
    this.initialStock = 0,
  });

  final int productId;
  final int initialStock;

  @override
  State<ProductTransactionList> createState() => _ProductTransactionListState();
}

class _ProductTransactionListState extends State<ProductTransactionList> {
  // Variables
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;

  RxList<TransactionModel> transactionsByProductId = <TransactionModel>[].obs;
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());

  // Get All products
  Future<void> getTransactionByProductId({required int productId}) async {
    try {
      final fetchedTransactions = await mongoTransactionRepo.fetchTransactionByProductId(
          productId: productId,
          page: currentPage.value
      );
      transactionsByProductId.addAll(fetchedTransactions);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTransactionByProductId(productId: widget.productId);
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if (!isLoadingMore.value) {
          const int itemsPerPage = 10;
          if (transactionsByProductId.length % itemsPerPage != 0) return;
          isLoadingMore(true);
          currentPage++;
          await getTransactionByProductId(productId: widget.productId);
          isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Transactions Found...',
      animation: Images.pencilAnimation,
    );

    return Obx(() {
      if (isLoading.value) {
        return TransactionTileShimmer(itemCount: 2);
      } else if (transactionsByProductId.isEmpty) {
        return emptyWidget;
      } else {
        final transactions = transactionsByProductId;
        int totalStock = widget.initialStock;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading(title: 'Transaction'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            HeadingRowForLedger(lastRow: 'Stock'),
            GridLayout(
              itemCount: isLoadingMore.value ? transactions.length + 2 : transactions.length,
              crossAxisCount: 1,
              mainAxisExtent: 50,
              itemBuilder: (context, index) {
                if (index >= transactions.length) {
                  return TransactionTileShimmer();
                }

                final transaction = transactions[index];

                CartModel? matchedProduct;

                try {
                  matchedProduct = transaction.products
                      ?.firstWhere((product) => product.productId == widget.productId);
                } catch (e) {
                  matchedProduct = null;
                }

                if (matchedProduct != null) {
                  if (transaction.transactionType == AccountVoucherType.purchase) {
                    totalStock -= matchedProduct.quantity;
                  } else {
                    totalStock += matchedProduct.quantity;
                  }
                }
                return TransactionsDataInRowsForProducts(
                  transaction: transaction,
                  totalStock: totalStock,
                  index: index,
                  stock: matchedProduct?.quantity ?? 0
                );
              },
            ),
          ],
        );
      }
    });
  }
}
