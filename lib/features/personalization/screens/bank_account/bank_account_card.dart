import 'package:flutter/material.dart';

import '../../../../../common/styles/spacing_style.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../models/bank_account.dart';

class BankAccountCard extends StatelessWidget {

  const BankAccountCard({
    super.key,
    required this.bankAccount,
    required this.onTap,
    this.hideEdit = false,
  });

  final BankAccountModel bankAccount;
  final bool hideEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        padding: AppSpacingStyle.defaultPagePadding,
        child: Stack(
          children: [
            !hideEdit
                ? const Positioned(
                right: 5,
                top: 0,
                child: Row(
                  spacing: AppSizes.sm,
                  children: [
                    Text('Edit', style: TextStyle(color: AppColors.linkColor),),
                    Icon(Icons.edit, size: 20, color: AppColors.linkColor),
                  ],
                )
            )
                : SizedBox.shrink(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bank Name', style: TextStyle(fontSize: 12)),
                Text(bankAccount.bankName ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Account Number', style: TextStyle(fontSize: 12)),
                Text(bankAccount.accountNumber ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('IFSC Code', style: TextStyle(fontSize: 12)),
                Text(bankAccount.ifscCode ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Swift Code', style: TextStyle(fontSize: 12)),
                Text(bankAccount.swiftCode ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

