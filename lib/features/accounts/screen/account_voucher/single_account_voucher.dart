import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/account_voucher/account_voucher_controller.dart';
import '../../models/account_voucher_model.dart';
import '../transaction/widget/transactions_by_entity.dart';
import 'add_account_voucher.dart';
import 'widget/account_voucher_tile.dart';

class SingleAccountVoucher extends StatefulWidget {
  const SingleAccountVoucher({super.key, required this.accountVoucher, required this.voucherType});

  final AccountVoucherModel accountVoucher;
  final AccountVoucherType voucherType;

  @override
  State<SingleAccountVoucher> createState() => _SingleAccountVoucherState();
}

class _SingleAccountVoucherState extends State<SingleAccountVoucher> {
  late AccountVoucherModel accountVoucher;
  final controller = Get.put(AccountVoucherController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    accountVoucher = widget.accountVoucher;
  }

  Future<void> _refreshAccountVoucher() async {
    final updatedAccountVoucher = await controller.getAccountVoucherByID(id: accountVoucher.id ?? '');
    setState(() {
      accountVoucher = updatedAccountVoucher;
    });
  }

  final Widget emptyWidget = AnimationLoaderWidgets(
    text: 'Whoops! No Transactions Found...',
    animation: Images.pencilAnimation,
  );

  @override
  Widget build(BuildContext context) {
    const double accountVoucherTileHeight = AppSizes.accountTileHeight;
    const double accountVoucherTileWidth = AppSizes.accountTileWidth;
    const double accountVoucherTileRadius = AppSizes.accountTileRadius;
    const double accountVoucherImageHeight = AppSizes.accountImageHeight;
    const double accountVoucherImageWidth = AppSizes.accountImageWidth;

    return Scaffold(
      appBar: AppAppBar(
        title: accountVoucher.title ?? 'AccountVoucher',
        widgetInActions: TextButton(
          onPressed: () => Get.to(() => AddAccountVoucher(accountVoucher: accountVoucher, voucherType: widget.voucherType)),
          child: const Row(
            children: [
              Text('Edit', style: TextStyle(color: AppColors.linkColor)),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => _refreshAccountVoucher(),
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AccountVoucherTile(accountVoucher: accountVoucher, voucherType: widget.voucherType),
            const SizedBox(height: AppSizes.spaceBtwItems),
            EntityTransactionList(
              voucherId: accountVoucher.id ?? '',
              initialAmount: accountVoucher.openingBalance ?? 0,
            ),
          ],
        ),
      ),
    );
  }
}