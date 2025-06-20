import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/dialog_box_massages/snack_bar_massages.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/common/heading_for_ledger.dart';
import '../../../../data/repositories/mongodb/transaction/transaction_repo.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/account_voucher/account_voucher_controller.dart';
import '../../models/account_voucher_model.dart';
import '../../models/transaction_model.dart';
import '../transaction/widget/transaction_simmer.dart';
import '../transaction/widget/transaction_tile.dart';
import 'add_account_voucher.dart';
import 'widget/account_voucher_tile.dart';

class SingleAccountVoucher extends StatefulWidget {
  const SingleAccountVoucher({
    super.key,
    required this.accountVoucher,
    required this.voucherType,
  });

  final AccountVoucherModel accountVoucher;
  final AccountVoucherType voucherType;

  @override
  State<SingleAccountVoucher> createState() => _SingleAccountVoucherState();
}

class _SingleAccountVoucherState extends State<SingleAccountVoucher> {
  // State
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxList<TransactionModel> transactionsByEntity = <TransactionModel>[].obs;

  // Dependencies
  late AccountVoucherModel accountVoucher;
  final mongoTransactionRepo = Get.put(MongoTransactionRepo());
  final controller = Get.put(AccountVoucherController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    accountVoucher = widget.accountVoucher;
    fetchInitialData();

    scrollController.addListener(() async {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value) {
          const int itemsPerPage = 10;
          if (transactionsByEntity.length % itemsPerPage != 0) return;
          isLoadingMore(true);
          currentPage.value++;
          await getTransactionByEntity(voucherId: accountVoucher.id ?? '');
          isLoadingMore(false);
        }
      }
    });
  }

  void fetchInitialData() async {
    isLoading(true);
    currentPage.value = 1;
    transactionsByEntity.clear();
    await getTransactionByEntity(voucherId: widget.accountVoucher.id ?? '');
    isLoading(false);
  }

  Future<void> getTransactionByEntity({required String voucherId}) async {
    try {
      final fetched = await mongoTransactionRepo.fetchTransactionByEntity(
        voucherId: voucherId,
        page: currentPage.value,
      );
      transactionsByEntity.addAll(fetched);
    } catch (e) {
      AppMassages.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  Future<void> _refreshAccountVoucher() async {
    final updated = await controller.getAccountVoucherByID(id: accountVoucher.id ?? '');
    setState(() {
      accountVoucher = updated;
    });
    fetchInitialData();
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
        title: accountVoucher.title ?? 'AccountVoucher',
        showSearchIcon: true,

        widgetInActions: TextButton(
          onPressed: () => Get.to(() => AddAccountVoucher(
            accountVoucher: accountVoucher,
            voucherType: widget.voucherType,
          )),
          child: const Text('Edit', style: TextStyle(color: AppColors.linkColor)),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: _refreshAccountVoucher,
        child: ListView(
          controller: scrollController,
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AccountVoucherTile(accountVoucher: accountVoucher, voucherType: widget.voucherType),
            const SizedBox(height: AppSizes.spaceBtwItems),
            Obx(() {
              if (isLoading.value) {
                return TransactionTileShimmer(itemCount: 3);
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
                double amount = accountVoucher.closingBalance ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Heading(title: 'Transaction'),
                    const SizedBox(height: AppSizes.spaceBtwItems),
                    HeadingRowForLedger(),
                    GridLayout(
                      itemCount: isLoadingMore.value
                          ? transactionsByEntity.length + 2
                          : transactionsByEntity.length,
                      crossAxisCount: 1,
                      mainAxisExtent: 50,
                      itemBuilder: (context, index) {
                        if (index >= transactionsByEntity.length) {
                          return const TransactionTileShimmer();
                        }

                        final transaction = transactionsByEntity[index];

                        if (accountVoucher.id == transaction.fromAccountVoucher?.id) {
                          amount += transaction.amount ?? 0;
                        } else {
                          amount -= transaction.amount ?? 0;
                        }

                        return TransactionsDataInRows(
                          voucherId: accountVoucher.id ?? '',
                          transaction: transaction,
                          total: amount,
                          index: index,
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
