import 'package:ara_finance/common/widgets/common/colored_amount.dart';
import 'package:ara_finance/utils/formatters/formatters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/account_voucher/account_voucher_controller.dart';
import '../../../models/account_voucher_model.dart';
import '../add_account_voucher.dart';

class AccountVoucherTile extends StatelessWidget {
  const AccountVoucherTile({super.key, required this.accountVoucher, this.onTap, required this.voucherType});

  final AccountVoucherType voucherType;
  final AccountVoucherModel accountVoucher;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const double tileHeight = AppSizes.accountTileHeight;
    const double tileWidth = AppSizes.accountTileWidth;
    const double tileRadius = AppSizes.accountTileRadius;

    return InkWell(
      onTap: onTap,
      onLongPress: () => showMenuBottomSheet(context: context),
      child: Container(
        width: tileWidth,
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tileRadius),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Voucher Id'),
                Text('#${accountVoucher.voucherId}', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Title'),
                Text(accountVoucher.title ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Date created'),
                Text(AppFormatter.formatDate(accountVoucher.dateCreated), style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Voucher Type'),
                Text(accountVoucher.voucherType?.name.capitalizeFirst ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Opening Balance'),
                Text(accountVoucher.openingBalance?.toStringAsFixed(0) ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Balance'),
                Text(accountVoucher.currentBalance?.toStringAsFixed(0) ?? '', style: const TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Closing Balance Balance'),
                ColoredAmount(amount: accountVoucher.closingBalance),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showMenuBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _buildMenuItem(
                context,
                icon: Icons.edit,
                title: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => AddAccountVoucher(accountVoucher: accountVoucher, voucherType: voucherType));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.delete,
                title: "Delete",
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  AccountVoucherController.instance.deleteAccountVoucher(
                    context: context,
                    id: accountVoucher.id ?? '',
                  );
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        bool isDestructive = false,
        required VoidCallback onTap,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? colorScheme.error
                  : colorScheme.onSurface.withOpacity(0.8),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive
                    ? colorScheme.error
                    : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

}