import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/icons.dart';
import '../../../../accounts/screen/accounts/accounts.dart';
import '../../../../accounts/screen/customers/customers.dart';
import '../../../../accounts/screen/expenses/expenses.dart';
import '../../../../accounts/screen/products/products.dart';
import '../../../../accounts/screen/purchase/purchase.dart';
import '../../../../accounts/screen/purchase_list/purchase_list.dart';
import '../../../../accounts/screen/sales/sales.dart';
import '../../../../accounts/screen/transaction/transactions.dart';
import '../../../../accounts/screen/vendor/vendors.dart';
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
          onTap: () => Get.to(() => const CustomersVoucher()),
          leading: Icon(AppIcons.customers, size: 25),
          title: Text('Customers',),
          subtitle: Text('List of customers',),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => const Sales()),
          leading: Icon(AppIcons.sales, size: 20),
          title: Text('Sales'),
          subtitle: Text('List of sales'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => const Purchase()),
          leading: Icon(AppIcons.purchase, size: 20),
          title: Text('Purchase'),
          subtitle: Text('List of purchase'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => const Accounts()),
          leading: Icon(Icons.money,size: 20),
          title: Text('Accounts'),
          subtitle: Text('All Accounts list'),
          trailing: Icon(Icons.arrow_forward_ios, size: 20,),
        ),
        ListTile(
          onTap: () => Get.to(() => const ExpensesScreen()),
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
          onTap: () => Get.to(() => const Vendors()),
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
      ],
    );
  }
}
