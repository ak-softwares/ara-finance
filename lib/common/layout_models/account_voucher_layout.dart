import 'package:ara_finance/features/accounts/screen/account_voucher/widget/account_voucher_simmer.dart';
import 'package:ara_finance/utils/constants/enums.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../features/accounts/models/account_voucher_model.dart';
import '../../features/accounts/screen/account_voucher/widget/account_voucher_tile.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../dialog_box_massages/animation_loader.dart';
import 'product_grid_layout.dart';

class AccountVoucherGridLayout extends StatelessWidget {
  const AccountVoucherGridLayout({
    super.key,
    required this.controller,
    this.onTap,
    required this.voucherType,
  });

  final dynamic controller;
  final AccountVoucherType voucherType;
  final ValueChanged<AccountVoucherModel>? onTap;

  final Widget emptyWidget = const AnimationLoaderWidgets(
    text: 'Whoops! No account vouchers found...',
    animation: Images.pencilAnimation,
  );
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return AccountVoucherTileShimmer(itemCount: 2);
      } else if (controller.accountVouchers.isEmpty) {
        return emptyWidget;
      } else {
        final vouchers = controller.accountVouchers;
        return GridLayout(
          itemCount: controller.isLoadingMore.value ? vouchers.length + 2 : vouchers.length,
          crossAxisCount: 1,
          mainAxisExtent: AppSizes.accountTileHeight,
          itemBuilder: (context, index) {
            if (index < vouchers.length) {
              return AccountVoucherTile(
                accountVoucher: vouchers[index],
                onTap: () => onTap?.call(vouchers[index]),
                voucherType: voucherType,
              );
            } else {
              return AccountVoucherTileShimmer();
            }
          },
        );
      }
    });
  }
}
