import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/common/heading_for_ledger.dart';
import '../../../../common/widgets/custom_shape/image/circular_image.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/authentication_controller/authentication_controller.dart';
import '../../../settings/app_settings.dart';
import '../../controller/product/product_controller.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../transaction/widget/transaction_simmer.dart';
import 'add_product.dart';

class SingleProduct extends StatefulWidget {
  const SingleProduct({super.key, required this.product});

  final ProductModel product;

  @override
  State<SingleProduct> createState() => _SingleProductState();
}

class _SingleProductState extends State<SingleProduct> {
  late ProductModel product;
  final controller = Get.put(ProductController());
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final ScrollController scrollController = ScrollController();
  final RxInt currentPage = 1.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<TransactionModel> transactionsByProductId = <TransactionModel>[].obs;
  final String userId = AuthenticationController.instance.admin.value.id!;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    fetchInitialTransactions();

    scrollController.addListener(() async {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value) {
          const int itemsPerPage = 10;
          if (transactionsByProductId.length % itemsPerPage != 0) return;
          isLoadingMore(true);
          currentPage.value++;
          await fetchTransactionsByProductId();
          isLoadingMore(false);
        }
      }
    });
  }

  Future<void> fetchInitialTransactions() async {
    isLoading(true);
    currentPage.value = 1;
    transactionsByProductId.clear();
    await fetchTransactionsByProductId();
    isLoading(false);
  }

  Future<void> fetchTransactionsByProductId() async {
    try {
      final fetched = await mongoTransactionRepo.fetchTransactionByProductId(
        productId: product.productId ?? 0,
        page: currentPage.value,
      );
      transactionsByProductId.addAll(fetched);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> _refreshProduct() async {
    final updatedProduct = await controller.getProductByID(id: product.id ?? '');
    setState(() {
      product = updatedProduct;
    });
    fetchInitialTransactions();
  }

  final Widget emptyWidget = AnimationLoaderWidgets(
    text: 'Whoops! No Transactions Found...',
    animation: Images.pencilAnimation,
  );

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: 'Product',
        widgetInActions: TextButton(
          onPressed: () => Get.to(() => AddProducts(product: product)),
          child: const Text('Edit', style: TextStyle(color: AppColors.linkColor)),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: _refreshProduct,
        child: ListView(
          controller: scrollController,
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: AppSizes.spaceBtwSection),
            RoundedImage(
              height: 100,
              width: 100,
              isNetworkImage: true,
              isTapToEnlarge: true,
              image: product.mainImage ?? '',
            ),
            const SizedBox(height: AppSizes.spaceBtwSection),
            Container(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.productVoucherTileRadius),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title ?? '', style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Product ID:'),
                      Text('#${product.productId}', style: const TextStyle(fontSize: 14))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Vendor:'),
                      Text(product.vendor?.title ?? ''),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Purchase Price:'),
                      Text(AppSettings.currencySymbol + (product.purchasePrice ?? 0).toStringAsFixed(2))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Stock:'),
                      Text('${product.stockQuantity}', style: const TextStyle(fontSize: 14))
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spaceBtwSection),
            Obx(() {
              if (isLoading.value) {
                return TransactionTileShimmer(itemCount: 2);
              } else if (transactionsByProductId.isEmpty) {
                return emptyWidget;
              } else {
                final transactions = transactionsByProductId;
                int totalStock = product.stockQuantity ?? 0;

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
                          return const TransactionTileShimmer();
                        }

                        final transaction = transactions[index];
                        final matchedProduct = transaction.products?.firstWhereOrNull((p) => p.productId == product.productId);

                        if (matchedProduct != null) {
                          if (transaction.transactionType == AccountVoucherType.purchase) {
                            totalStock -= matchedProduct.quantity;
                          } else {
                            if(transaction.status != OrderStatus.returned){
                              totalStock += matchedProduct.quantity;
                            }
                          }
                        }

                        return TransactionsDataInRowsForProducts(
                          transaction: transaction,
                          totalStock: totalStock,
                          index: index,
                          stock: transaction.status != OrderStatus.returned ? matchedProduct?.quantity ?? 0 : 0,
                        );
                      },
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
