import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/account_voucher/account_voucher_controller.dart';
import 'add_account_voucher.dart';
import 'common/sync_customer.dart';
import 'single_account_voucher.dart';
import 'widget/account_voucher_simmer.dart';
import 'widget/account_voucher_tile.dart';


class AccountVouchers extends StatelessWidget {
  const AccountVouchers({super.key, required this.voucherType});

  final AccountVoucherType voucherType;

  @override
  Widget build(BuildContext context) {
    const double accountVoucherTileHeight = AppSizes.accountTileHeight;

    final ScrollController scrollController = ScrollController();
    final accountVoucherController = Get.put(AccountVoucherController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      accountVoucherController.refreshAccountVouchers(voucherType: voucherType);
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if (!accountVoucherController.isLoadingMore.value) {
          const int itemsPerPage = 10;
          if (accountVoucherController.accountVouchers.length % itemsPerPage != 0) return;
          accountVoucherController.isLoadingMore(true);
          accountVoucherController.currentPage++;
          await accountVoucherController.getAccountVouchers(voucherType: voucherType);
          accountVoucherController.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No AccountVouchers Found...',
      animation: Images.pencilAnimation,
    );

    return Scaffold(
      appBar: AppAppBar(
        title: voucherType.name.capitalizeFirst ?? 'Account voucher',
        showSearchIcon: true,
        searchType: SearchType.accountVoucher,
        voucherType: voucherType,
        widgetInActions: voucherType == AccountVoucherType.customer
            ? IconButton(
                onPressed: () => Get.to(() => SyncCustomerScreen()),
                icon: Text(
                  'Sync Customers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.linkColor,
                  ),
                ),
              )
            : SizedBox(), // or null if your widget allows it
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'voucher_$voucherType',
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        onPressed: () => Get.to(() => AddAccountVoucher(voucherType: voucherType)),
        tooltip: 'Add Account Vouchers',
        child: const Icon(LineIcons.plus, size: 30, color: Colors.white),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => accountVoucherController.refreshAccountVouchers(voucherType: voucherType),
        child: ListView(
          controller: scrollController,
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Obx(() {
              if (accountVoucherController.isLoading.value) {
                return const AccountVoucherTileShimmer(itemCount: 2);
              } else if (accountVoucherController.accountVouchers.isEmpty) {
                return emptyWidget;
              } else {
                final accountVouchers = accountVoucherController.accountVouchers;
                return Column(
                  children: [
                    GridLayout(
                      itemCount: accountVoucherController.isLoadingMore.value ? accountVouchers.length + 2 : accountVouchers.length,
                      crossAxisCount: 1,
                      mainAxisExtent: accountVoucherTileHeight,
                      itemBuilder: (context, index) {
                        if (index < accountVouchers.length) {
                          return AccountVoucherTile(
                            voucherType: voucherType,
                            onTap: () => Get.to(() => SingleAccountVoucher(accountVoucher: accountVouchers[index], voucherType: voucherType,)),
                            accountVoucher: accountVouchers[index],
                          );
                        } else {
                          return const AccountVoucherTileShimmer();
                        }
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