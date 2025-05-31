import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../common/widgets/common/colored_amount.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/account/account_controller.dart';
import '../../../models/account_model.dart';
import '../add_account.dart';

class AccountTile extends StatelessWidget {
  const AccountTile({super.key, required this.account, this.onTap});

  final AccountModel account;
  final VoidCallback? onTap; // Function to handle tap events

  @override
  Widget build(BuildContext context) {
    const double paymentTileHeight = AppSizes.accountTileHeight;
    const double paymentTileWidth = AppSizes.accountTileWidth;
    const double paymentTileRadius = AppSizes.accountTileRadius;
    const double paymentImageHeight = AppSizes.accountImageHeight;
    const double paymentImageWidth = AppSizes.accountImageWidth;

    final controller = Get.put(AccountController());

    return InkWell(
    onTap: onTap,
     onLongPress: () => showMenuBottomSheet(context: context),
      child: Container(
        width: paymentTileWidth,
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(paymentTileRadius),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Stack(
          children: [
            // Main content as Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Account Id'),
                    Text('#${account.accountId.toString()}', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Account Name'),
                    Text(account.accountName ?? '', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Opening Balance'),
                    Text(account.openingBalance.toString(), style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Current Balance'),
                    Text(account.balance.toString(), style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Closing Balance'),
                    ColoredAmount(amount: account.closingBalance ?? 0.0),
                  ],
                ),
              ],
            ),

            // Positioned 'Default' label
            if (controller.isSelectedAccount(account.id ?? ''))
              Positioned(
                top: 0,
                right: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(AppSizes.md),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSizes.xs),
                  child: const Text('Default', style: TextStyle(fontSize: 12)),
                ),
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
              // Menu items
              _buildMenuItem(
                context,
                icon: Icons.star,
                title: "Make this default",
                onTap: () {
                  Navigator.pop(context);
                  AccountController.instance.makeAccountDefault(account: account);
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.edit,
                title: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => AddAccount(payment: account));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.delete,
                title: "Delete",
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  AccountController.instance.deleteAccount(context: context, id: account.id ?? '');
                },
              ),
              const SizedBox(height: 8),
              // Cancel button
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
