import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/common/colored_amount.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/account/account_controller.dart';
import '../../models/account_model.dart';
import '../transaction/widget/transactions_by_entity.dart';
import 'add_account.dart';

class SingleAccount extends StatefulWidget {
  const SingleAccount({super.key, required this.account});

  final AccountModel account;

  @override
  State<SingleAccount> createState() => _SingleAccountState();
}

class _SingleAccountState extends State<SingleAccount> {
  late AccountModel payment;
  final controller = Get.put(AccountController());

  @override
  void initState() {
    super.initState();
    payment = widget.account; // Initialize with the passed purchase
  }

  Future<void> _refreshPayment() async {
    final updatedPayment = await controller.getPaymentByID(id: payment.id ?? '');
    setState(() {
      payment = updatedPayment; // Update the purchase data
    });
  }

  @override
  Widget build(BuildContext context) {
    const double paymentTileHeight = AppSizes.paymentTileHeight;
    const double paymentTileWidth = AppSizes.paymentTileWidth;
    const double paymentTileRadius = AppSizes.paymentTileRadius;
    const double paymentImageHeight = AppSizes.paymentImageHeight;
    const double paymentImageWidth = AppSizes.paymentImageWidth;

    return Scaffold(
        appBar: AppAppBar(
          title: payment.accountName ?? 'Account',
          widgetInActions: TextButton(
              onPressed: () => Get.to(() => AddAccount(payment: payment)),
              child: Text('Edit', style: TextStyle(color: AppColors.linkColor),)
          )
        ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => _refreshPayment(),
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
                width: paymentTileWidth,
                padding: const EdgeInsets.all(AppSizes.defaultSpace),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(paymentTileRadius),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Accounts Id'),
                        Text('#${payment.accountId.toString()}', style: TextStyle(fontSize: 14))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Accounts Method'),
                        Text(payment.accountName ?? '', style: TextStyle(fontSize: 14))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Opening Balance'),
                        Text(payment.openingBalance.toString(), style: TextStyle(fontSize: 14))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Balance'),
                        ColoredAmount(amount: payment.balance ?? 0.0)
                      ],
                    ),
                  ],
                )
            ),

            // Transaction
            SizedBox(height: AppSizes.spaceBtwItems),
            Heading(title: 'Transaction'),
            SizedBox(height: AppSizes.spaceBtwItems),
            SizedBox(
                height: 350,
                child: TransactionsByEntity(entityType: EntityType.account, entityId: payment.id ?? '')
            ),

            // Delete
            Center(child: TextButton(
                onPressed: () => controller.deleteAccount(context: context, id: payment.id ?? ''),
                child: Text('Delete', style: TextStyle(color: Colors.red),))
            )
          ],
        ),
      ),
    );
  }

}
