import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../common/widgets/common/colored_amount.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/models/address_model.dart';
import '../../../personalization/models/user_model.dart';
import '../../../personalization/screens/user_address/address_widgets/single_address.dart';
import '../../controller/vendor/vendor_controller.dart';
import '../transaction/widget/transactions_by_entity.dart';
import 'add_new_vendor.dart';

class SingleVendor extends StatefulWidget {
  const SingleVendor({super.key, required this.vendor});

  final UserModel vendor;

  @override
  State<SingleVendor> createState() => _SingleVendorState();
}

class _SingleVendorState extends State<SingleVendor> {
  late UserModel vendor;
  final vendorController = Get.find<VendorController>();

  @override
  void initState() {
    super.initState();
    vendor = widget.vendor; // Initialize with the passed purchase
  }

  Future<void> _refreshVendor() async {
    final updatedPurchase = await vendorController.getVendorByID(id: vendor.id ?? '');
    setState(() {
      vendor = updatedPurchase; // Update the purchase data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppAppBar(
          title: vendor.companyName ?? 'Vendor',
          widgetInActions: TextButton(
              onPressed: () => Get.to(() => AddVendorPage(vendor: vendor)),
              child: Text('Edit', style: TextStyle(color: AppColors.linkColor),)
          )
        ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => _refreshVendor(),
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vendor ID'),
                Text('#${vendor.documentId}', style: TextStyle(fontSize: 14))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vendor'),
                Text(vendor.companyName ?? '', style: TextStyle(fontSize: 14))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('GST'),
                Text(vendor.gstNumber ?? '', style: TextStyle(fontSize: 14))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Opening Balance'),
                Text((vendor.openingBalance ?? 0).toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance'),
                ColoredAmount(amount: vendor.balance ?? 0.0)
              ],
            ),
            Text('Address'),
            SizedBox(height: AppSizes.xs),
            SingleAddress(
              address: vendor.billing ?? AddressModel.empty(),
              onTap: () {},
              hideEdit: true,
            ),
            // Delete
            // SizedBox(height: 50),
            Center(child: TextButton(
                onPressed: () => vendorController.deleteVendor(context: context, id: vendor.id ?? ''),
                child: Text('Delete', style: TextStyle(color: Colors.red),))
            ),

            // Related Transactions Section
            const SectionHeading(title: 'Related Transactions'),
            const SizedBox(height: AppSizes.spaceBtwItems),
            TransactionsByEntity(
              entityType: EntityType.vendor,
              entityId: vendor.id ?? '0',
            ),
            const SizedBox(height: AppSizes.spaceBtwSection),
          ],
        ),
      ),
    );
  }
}
