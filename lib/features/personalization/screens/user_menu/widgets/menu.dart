import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/icons.dart';
import '../../../../accounts/screen/account_voucher/account_vouchers.dart';
import '../../../../accounts/screen/gst_report/gst_report.dart';
import '../../../../accounts/screen/products/products.dart';
import '../../../../accounts/screen/purchase_list/purchase_list.dart';
import '../../../../accounts/screen/transaction/transactions.dart';
import '../../../../setup/screens/platform_selection_screen.dart';

class Menu extends StatelessWidget {
  const Menu({
    super.key, this.showHeading = true,
  });

  final bool showHeading;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        ListTile(
          onTap: () => Get.to(() => Products()),
          leading: Icon(AppIcons.products, size: 25),
          title: Text('Products'),
          subtitle: Text('List of products'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => AccountVouchers(voucherType: AccountVoucherType.customer)),
          leading: Icon(AppIcons.customers, size: 25),
          title: Text('Customers',),
          subtitle: Text('List of customers',),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => AccountVouchers(voucherType: AccountVoucherType.sale)),
          leading: Icon(AppIcons.sales, size: 20),
          title: Text('Sales'),
          subtitle: Text('List of sale vouchers'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => AccountVouchers(voucherType: AccountVoucherType.purchase)),
          leading: Icon(AppIcons.purchase, size: 20),
          title: Text('Purchase'),
          subtitle: Text('List of purchase vouchers'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => AccountVouchers(voucherType: AccountVoucherType.bankAccount)),
          leading: Icon(Icons.money,size: 20),
          title: Text('Bank Accounts'),
          subtitle: Text('All Bank Accounts list'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => AccountVouchers(voucherType: AccountVoucherType.expense)),
          leading: Icon(Icons.money,size: 20),
          title: Text('Expenses'),
          subtitle: Text('All Expenses list'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => const Transactions()),
          leading: Icon(Icons.list_alt,size: 20),
          title: Text('Transactions'),
          subtitle: Text('All Transactions list'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => AccountVouchers(voucherType: AccountVoucherType.vendor)),
          leading: Icon(AppIcons.customers,size: 20),
          title: Text('Vendors'),
          subtitle: Text('All Vendors list'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => const PurchaseList()),
          leading: Icon(AppIcons.products, size: 20),
          title: Text('Purchase Item List'),
          subtitle: Text('Purchase Item List'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => PlatformSelectionScreen()),
          leading: Icon(Icons.store, size: 20),
          title: Text('Connect Store'),
          subtitle: Text('List of products'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => GstReport()),
          leading: Icon(Icons.receipt, size: 20),
          title: Text('GST Report'),
          subtitle: Text('GST report by month'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
      ],
    );
  }
}
