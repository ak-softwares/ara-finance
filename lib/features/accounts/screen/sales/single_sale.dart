import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../common/text/section_heading.dart';
import '../../../../utils/constants/api_constants.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../../personalization/models/address_model.dart';
import '../../../personalization/screens/user_address/address_widgets/single_address.dart';
import '../../../settings/app_settings.dart';
import '../../controller/sales_controller/sales_controller.dart';
import '../../models/order_model.dart';
import '../../models/transaction_model.dart';
import '../products/widget/product_cart_tile.dart';
import '../transaction/widget/transaction_tile.dart';
import '../transaction/widget/transactions_by_entity.dart';
import 'add_sale.dart';

class SingleSaleScreen extends StatefulWidget {
  const SingleSaleScreen({super.key, required this.sale});

  final OrderModel sale;

  @override
  State<SingleSaleScreen> createState() => _SingleSaleScreenState();
}

class _SingleSaleScreenState extends State<SingleSaleScreen> {
  final localStorage = GetStorage();
  final saleController = Get.put(SaleController());
  late OrderModel sale;

  @override
  void initState() {
    super.initState();
    sale = widget.sale;
  }

  Future<void> _refreshCustomer() async {
    final updatedSale = await saleController.getSaleById(saleId: sale.id ?? '');
    setState(() {
      sale = updatedSale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppAppBar(
          title: "Order #",
          widgetInActions: TextButton(
              onPressed: () => Get.to(() => AddNewSale(previousSale: widget.sale)),
              child: Text('Edit', style: TextStyle(color: AppColors.linkColor),)
          ),
        ),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: _refreshCustomer,
          child: Obx(() {
            if(saleController.isLoading.value){
              return Center(child: CircularProgressIndicator(strokeWidth: 3 ));
            }else{
              // final currentOrder = orderController.currentOrder.value;
              final currentOrder = widget.sale;
              return ListView(
                padding: AppSpacingStyle.defaultPageVertical,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Column(
                    spacing: AppSizes.spaceBtwSection,
                    children: [
                      // Order Items
                      Column(
                        spacing: AppSizes.spaceBtwItems,
                        children: [
                          Heading(title: 'Order Items', paddingLeft: AppSizes.defaultSpace),
                          GridLayout(
                            crossAxisCount: 1,
                            mainAxisExtent: 90,
                            itemCount: currentOrder.lineItems!.length,
                            itemBuilder: (_, index) => Stack(children: [
                              ProductCartTile(cartItem: currentOrder.lineItems![index]),
                            ]),
                          ),
                        ],
                      ),

                      // Order Detail Section
                      Padding(
                        padding: AppSpacingStyle.defaultPageHorizontal,
                        child: Column(
                          children: [
                            Heading(
                              title: 'Order Details',
                              paddingLeft: AppSizes.md,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order'),
                                Text('#${currentOrder.orderId}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total'),
                                // Text(AppSettings.appCurrencySymbol + currentOrder.total!),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Status'),
                                Text(currentOrder.status?.prettyName ?? ''),
                              ],
                            ),
                            if(currentOrder.dateCreated != null)
                              Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order Date'),
                                Text(AppFormatter.formatDate(currentOrder.dateCreated)),
                              ],
                            ),
                            if(currentOrder.dateShipped != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Ship Date'),
                                  Text(AppFormatter.formatDate(currentOrder.dateShipped)),
                                ],
                              ),
                            if(currentOrder.datePaid != null)
                              Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Payment Date'),
                                Text(AppFormatter.formatDate(currentOrder.datePaid)),
                              ],
                            ),
                            if(currentOrder.dateReturned != null)
                              Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Return Date'),
                                Text(AppFormatter.formatDate(currentOrder.dateReturned)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Billing Section
                      if(currentOrder.billing != null)
                        Column(
                        children: [
                          Heading(title: 'Billing & address'),
                          SizedBox(
                            height: AppSizes.sm,
                          ),
                          SingleAddress(
                            address: currentOrder.billing ?? AddressModel.empty(),
                            onTap: () {},
                            hideEdit: true,
                          ),
                          SizedBox(height: AppSizes.sm),
                          Padding(
                            padding: AppSpacingStyle.defaultPageHorizontal,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Subtotal'),
                                    Text(
                                        '${AppSettings.currencySymbol}${currentOrder.calculateTotalSum()}'),
                                  ],
                                ),
                                if (currentOrder.discountTotal != '0' &&
                                    currentOrder.discountTotal!.isNotEmpty)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Discount'),
                                          Text(
                                              '- ${AppSettings.currencySymbol}${currentOrder.discountTotal!}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                if (currentOrder.shippingTotal != '0' && currentOrder.shippingTotal!.isNotEmpty)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Shipping'),
                                          Text(AppSettings.currencySymbol +
                                              currentOrder.shippingTotal!),
                                        ],
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text(AppSettings.currencySymbol + currentOrder.total.toString(),
                                        style: TextStyle(fontWeight: FontWeight.w500)
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Payment Method  ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                    // Text(order.paymentMethodTitle ?? '', style: Theme.of(context).textTheme.bodyMedium),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            currentOrder.paymentMethodTitle ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Track order section
                      Column(
                        children: [
                          // Transaction
                          if(currentOrder.transaction?.id != null)
                            Column(
                            children: [
                              SizedBox(height: AppSizes.spaceBtwItems),
                              Heading(title: 'Transaction'),
                              SizedBox(height: AppSizes.spaceBtwItems),
                              // TextButton(
                              //     onPressed: () => saleController.reversePaymentStatus(sale: sale),
                              //     child: Text('Reverse Transactions', style: TextStyle(color: AppColors.linkColor),)
                              // ),
                              TransactionTile(transaction: currentOrder.transaction ?? TransactionModel()),
                            ],
                          ),

                          Center(child: TextButton(
                              onPressed: () => saleController.deleteSale(sale: widget.sale ?? OrderModel(), context: context),
                              child: Text('Delete', style: TextStyle(color: Colors.red),))
                          )
                        ],
                      )
                    ],
                  ),
                ],
              );
            }
          }),
        )
    );
  }
}
