import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/models/address_model.dart';
import '../../../personalization/models/user_model.dart';
import '../../../personalization/screens/user_address/address_widgets/single_address.dart';
import '../../controller/customer/customer_controller.dart';
import '../transaction/widget/transactions_by_entity.dart';
import 'add_customer.dart';

class SingleCustomer extends StatefulWidget {
  const SingleCustomer({super.key, required this.customer});

  final UserModel customer;

  @override
  State<SingleCustomer> createState() => _SingleCustomerState();
}

class _SingleCustomerState extends State<SingleCustomer> {
  late UserModel user;
  final customerController = Get.find<CustomerController>();

  @override
  void initState() {
    super.initState();
    user = widget.customer;
  }

  Future<void> _refreshCustomer() async {
    final updatedCustomer = await customerController.getCustomerByID(id: user.id ?? '');
    setState(() {
      user = updatedCustomer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(
        title: user.name ?? 'Customer',
        widgetInActions: TextButton(
          onPressed: () => Get.to(() => AddCustomer(user: user)),
          child: Text('Edit', style: TextStyle(color: AppColors.linkColor)),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: _refreshCustomer,
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Customer ID'),
                Text('#${user.documentId}', style: TextStyle(fontSize: 14))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Customer Name'),
                Text(user.name ?? '', style: TextStyle(fontSize: 14))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Email'),
                Text(user.email ?? '', style: TextStyle(fontSize: 14))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Phone'),
                Text(user.phone ?? '', style: TextStyle(fontSize: 14))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance'),
                AmountText(amount: user.balance ?? 0.0)
              ],
            ),
            Text('Address'),
            SizedBox(height: AppSizes.xs),
            SingleAddress(
              address: user.billing ?? AddressModel.empty(),
              onTap: () {},
              hideEdit: true,
            ),

            // Delete
            Center(child: TextButton(
              onPressed: () => customerController.deleteCustomer(context: context, id: user.id ?? ''),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ))
          ],
        ),
      ),
    );
  }
}

class AmountText extends StatelessWidget {
  const AmountText({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Text(amount.toString(),
        style: TextStyle(
            fontSize: 14,
            color: amount < 0 ? Colors.red : Colors.green
        )
    );
  }
}
