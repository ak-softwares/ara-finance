import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/formatters/formatters.dart';
import '../../controller/purchase_list_controller/purchase_list_controller.dart';
import '../../models/purchase_item_model.dart';
import 'orders_by_status.dart';
import 'widget/purchase_list_item.dart';
import 'widget/purchase_list_shimmer.dart';
import 'widget/sale_tile.dart';

class PurchaseList extends StatelessWidget {
  const PurchaseList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PurchaseListController());

    return Scaffold(
      appBar: AppAppBar(
        title: 'Purchase Product List',
        widgetInActions: Obx(() => Padding(
            padding: const EdgeInsets.only(right: AppSizes.xl),
            child: !controller.isFetching.value
                ? InkWell(
                    onTap: () => controller.showDialogForSelectOrderStatus(),
                    child: Row(
                      spacing: AppSizes.xs,
                      children: [
                        Icon(Icons.refresh, color: Colors.blue, size: 17),
                        Text('Sync', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  )
                : Center(
                    child: SizedBox(
                      height: 15,
                      width: 15,
                      // child: Text('Fetching Orders...,', style: TextStyle(fontSize: 12)),
                      child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 2),
                    ),
                  ),
          )),
      ),
      bottomSheet: Obx(() => Container(
        color:  Theme.of(context).colorScheme.background,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                  'Last Sync - ${AppFormatter.formatStringDate(controller.purchaseListMetaData.value.lastSyncDate.toString())}',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Text('Total - ${controller.products.length}',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),),
              Text('Purchased - ${controller.purchaseListMetaData.value.purchasedProductIds?.length ?? 0}',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
      )),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async {
          controller.refreshOrders();
        },
        child: ListView(
          padding: AppSpacingStyle.defaultPagePadding,
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status'),
                        InkWell(
                          onTap: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Orders'),
                              const Icon(Icons.arrow_right, size: 25, color: Colors.blue),
                            ],
                          ),
                        )                      ],
                    ),
                    PurchaseListShimmer(),
                  ],
                );
              } else if (controller.products.isEmpty) {
                return AnimationLoaderWidgets(
                  text: 'Whoops! No Orders Found...',
                  animation: Images.pencilAnimation,
                  showAction: true,
                  actionText: 'Sync Products',
                  onActionPress: () => controller.showDialogForSelectOrderStatus(),
                );
              } else {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(controller.purchaseListMetaData.value.orderStatus?.map((e) => e.prettyName).join(', ') ?? '',),
                        InkWell(
                          onTap: () => Get.to(() => OrdersByStatus(orders: controller.orders, orderStatus: controller.purchaseListMetaData.value.orderStatus ?? [OrderStatus.unknown],)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Orders'),
                              const Icon(Icons.arrow_right, size: 25, color: Colors.blue),
                            ],
                          ),
                        )                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.vendorNames.length,
                      itemBuilder: (context, index) {
                        final companyName = controller.vendorNames[index];
                        final allVendorProducts = controller.filterProductsByVendor(vendorName: companyName);
                        // Initialize expanded states if not already present
                        controller.initializeExpansionState(companyName); // Ensure companyName exists
                        final purchasedProductIds = controller.purchaseListMetaData.value.purchasedProductIds ?? [];
                        final notAvailableProductIds = controller.purchaseListMetaData.value.notAvailableProductIds ?? [];
                        final purchasableProducts = allVendorProducts.where((product) =>
                        !purchasedProductIds.contains(product.id) &&
                            !notAvailableProductIds.contains(product.id)
                        ).toList();

                        return allVendorProducts.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: AppSizes.sm),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Vendor Header
                                    InkWell(
                                      onTap: () {
                                        // Toggle the expansion state for a specific section
                                        controller.expandedSections[companyName]![PurchaseListType.vendors] =
                                              !controller.expandedSections[companyName]![PurchaseListType.vendors]!;

                                        // Refresh the UI
                                        controller.expandedSections.refresh();
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(AppSizes.defaultSpace),
                                            decoration: BoxDecoration(
                                              color: purchasableProducts.isNotEmpty
                                                  ? Theme.of(context).colorScheme.surface
                                                  : Colors.grey,
                                              borderRadius: BorderRadius.circular(AppSizes.purchaseItemTileRadius),
                                              border: Border.all(
                                                width: 1,
                                                color: Theme.of(context).colorScheme.outline,
                                              ),
                                            ),
                                            child: Obx(() => Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('$companyName ${allVendorProducts.length}'),
                                                Icon((controller.expandedSections[companyName]?[PurchaseListType.vendors] ?? false) ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                                              ],
                                            )),
                                          ),
                                          if(purchasableProducts.isEmpty)
                                            Positioned(
                                            top: 25,
                                            // bottom: 4,
                                            left: 0,
                                            right: 0,
                                            child: Container(height: 1,
                                              color: Theme.of(context).colorScheme.outline,
                                            )
                                          )
                                        ],
                                      ),
                                    ),

                                    // Vendor Products List
                                    Obx(() {
                                      if (controller.expandedSections[companyName]?[PurchaseListType.vendors] ?? false) {
                                        // Ensure that the Obx is observing the reactive properties
                                        final purchasedProductIds = controller.purchaseListMetaData.value.purchasedProductIds ?? [];
                                        final notAvailableProductIds = controller.purchaseListMetaData.value.notAvailableProductIds ?? [];

                                        return Column(
                                          children: [
                                            _buildProductListSection(
                                              context: context,
                                              companyName: companyName,
                                              title: 'Purchasable',
                                              purchaseListType: PurchaseListType.purchasable,
                                              backgroundColor: Colors.green,
                                              filterCondition: (product) => !purchasedProductIds.contains(product.id) && !notAvailableProductIds.contains(product.id),
                                            ),
                                            _buildProductListSection(
                                              context: context,
                                              companyName: companyName,
                                              title: 'Purchased',
                                              purchaseListType: PurchaseListType.purchased,
                                              backgroundColor: Colors.blue,
                                              filterCondition: (product) => purchasedProductIds.contains(product.id),
                                            ),
                                            _buildProductListSection(
                                              context: context,
                                              companyName: companyName,
                                              title: 'Not Available',
                                              purchaseListType: PurchaseListType.notAvailable,
                                              backgroundColor: Colors.red,
                                              filterCondition: (product) => notAvailableProductIds.contains(product.id),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }),
                                  ],
                                ),
                              )
                            : SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: controller.extraNoteController,
                      // initialValue: controller.purchaseListMetaData.value.extraNote ?? '',
                      maxLines: 3, // Allows text input to expand
                      decoration: InputDecoration(
                        hintText: 'Extra Notes...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant), // Ensure hint is visible
                        // isDense: true, // Prevent excessive padding
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Prevent squeezing
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.defaultRadius), // Set border radius
                          borderSide: BorderSide(color: Colors.transparent), // Transparent border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.defaultRadius),
                          borderSide: BorderSide(
                              color:Theme.of(context).colorScheme.outlineVariant,
                              width: AppSizes.defaultBorderWidth
                          ), // Light grey border when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.defaultRadius),
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outlineVariant,
                              width: AppSizes.defaultBorderWidth), // Blue border when focused
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          controller.saveExtraNote(controller.extraNoteController.text);
                        },
                        child: Obx(() => controller.isExtraTextUpdating.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.linkColor),
                              )
                            : Text('Save', style: TextStyle(color: Colors.blue, fontSize: 15, fontWeight: FontWeight.w500)))
                    ),
                    SizedBox(height: 50),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListSection({
    required BuildContext context, // Added BuildContext
    required String companyName,
    required String title,
    required PurchaseListType purchaseListType,
    required Color backgroundColor,
    required bool Function(PurchaseItemModel) filterCondition,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(PurchaseListController());
    final double purchaseItemTileRadius = AppSizes.purchaseItemTileRadius;

    final allVendorProducts = controller.filterProductsByVendor(vendorName: companyName);
    final filteredProducts = allVendorProducts.where(filterCondition).toList();

    final RxBool isExpanded = (controller.expandedSections[companyName]?[purchaseListType] ?? false).obs;

    if (filteredProducts.isEmpty) return SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSizes.spaceBtwItems),
          child: InkWell(
            onTap: () {
              controller.expandedSections[companyName]?[purchaseListType] = !isExpanded.value;
              isExpanded.value = !isExpanded.value; // Ensure UI updates
            },
            child: Container(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.surface : backgroundColor is MaterialColor ? backgroundColor.shade50 : backgroundColor.withOpacity(0.3), // Use surface for a neutral background
                borderRadius: BorderRadius.circular(AppSizes.purchaseItemTileRadius),
                border: Border.all(
                  width: 1,
                  color: backgroundColor is MaterialColor ? backgroundColor.shade200 : backgroundColor.withOpacity(0.5), // Border color
                ),
              ),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$title ${filteredProducts.length}'),
                  Icon(isExpanded.value
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  ),
                ],
              )),
            ),
          ),
        ),
        if (isExpanded.value) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              if (((product.stock ?? 0) - (product.totalQuantity ?? 0)) > 0) {
                return SizedBox.shrink();
              } else{
                return Dismissible(
                  key: Key(product.id.toString()),
                  direction: purchaseListType == PurchaseListType.purchasable
                      ? DismissDirection.horizontal
                      : DismissDirection.endToStart,
                  onDismissed: (direction) {
                    controller.handleProductListUpdate(
                      productId: product.id ?? 0,
                      purchaseListType: purchaseListType,
                      direction: direction,
                    );
                  },
                  background: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade900  // Dark grey for night mode
                                : Colors.grey.shade300, // Light grey for day mode
                            borderRadius: BorderRadius.circular(purchaseItemTileRadius),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).colorScheme.outline, // Border color
                            )
                        ),
                        child: purchaseListType == PurchaseListType.purchasable
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Not Available'),
                            Text('Purchased'),
                            // Icon(Icons.delete, color: Colors.white),
                          ],
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox.shrink(),
                            Text('Restore'),
                            Icon(Icons.restore, color: Theme.of(context).colorScheme.onSurface),
                          ],
                        )
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: InkWell(
                      onTap: () => _showRelatedOrders(context: context, productId: product.id ?? 0),
                      child: PurchaseListItem(product: product, isDeleted: purchaseListType != PurchaseListType.purchasable),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ],
    );
  }

  void _showRelatedOrders({required BuildContext context,  required int productId}) {
    final controller = Get.find<PurchaseListController>();

    // Filter orders that contain the selected product
    final relatedOrders = controller.orders.where((order) {
      return order.lineItems!.any((item) => item.productId == productId);
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900  // Dark mode background
          : Colors.white,          // Light mode background
      builder: (context) {
        return relatedOrders.isNotEmpty
            ? SingleChildScrollView(
                padding: AppSpacingStyle.defaultPagePadding,
                child: GridLayout(
                  itemCount: relatedOrders.length,
                  crossAxisCount: 1,
                  mainAxisExtent: AppSizes.saleTileHeight,
                  itemBuilder: (context, index) {
                    return SaleTile(sale: relatedOrders[index]);
                  },
                ),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No related orders found"),
                ),
              );
      },
    );
  }

}
