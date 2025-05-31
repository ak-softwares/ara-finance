import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../../../common/layout_models/sales_grid_layout.dart';
import '../../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../../common/styles/spacing_style.dart';
import '../../../../../../common/text/section_heading.dart';
import '../../../../../../common/widgets/shimmers/product_voucher_shimmer.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/image_strings.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../controller/search_controller/search_controller.dart';
import '../../../accounts/widget/account_tile.dart';
import '../../../accounts/widget/account_tile_simmer.dart';
import '../../../customers/widget/customer_tile.dart';
import '../../../customers/widget/customer_tile_simmer.dart';
import '../../../products/widget/product_tile.dart';
import '../../../vendor/widget/vendor_tile.dart';
import '../../../vendor/widget/vendor_tile_simmer.dart';

class SearchScreen3 extends StatelessWidget {
  const SearchScreen3({
    super.key,
    required this.title,
    required this.searchQuery,
    required this.searchType,
    this.selectedItems,
  });

  final String title;
  final String searchQuery;
  final SearchType searchType;
  final dynamic selectedItems;

  @override
  Widget build(BuildContext context) {

    final ScrollController scrollController = ScrollController();
    final searchVoucherController = Get.put(SearchVoucherController());

    // Schedule the search refresh to occur after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!searchVoucherController.isLoading.value) {
        searchVoucherController.refreshSearch(query: searchQuery, searchType: searchType);
      }
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!searchVoucherController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (searchVoucherController.products.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          searchVoucherController.isLoadingMore(true);
          searchVoucherController.currentPage++; // Increment current page
          await searchVoucherController.getItemsBySearchQuery(query: searchQuery, searchType: searchType, page: searchVoucherController.currentPage.value);
          searchVoucherController.isLoadingMore(false);
        }
      }
    });

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: ElevatedButton(
            onPressed: () => searchVoucherController.confirmSelection(context: context, searchType: searchType),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Done '),
                Text(searchVoucherController.getItemsCount(searchType: searchType).toString())
              ],
            )),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => searchVoucherController.refreshSearch(query: searchQuery, searchType: searchType),
        child: ListView(
          controller: scrollController,
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SectionHeading(title: title),
            switch (searchType) {
              SearchType.products => Obx(() {
                    if (searchVoucherController.isLoading.value) {
                      return  ProductVoucherShimmer(itemCount: 2);
                    } else if(searchQuery.isEmpty) {
                        final products = searchVoucherController.selectedProducts;
                        return GridLayout(
                          itemCount: searchVoucherController.selectedProducts.length,
                          crossAxisCount: 1,
                          mainAxisExtent: AppSizes.productVoucherTileHeight,
                          itemBuilder: (context, index) {
                            if (index < products.length) {
                              return Obx(() {
                                final product = searchVoucherController.selectedProducts[index];
                                final isSelected = searchVoucherController.selectedProducts.contains(product);
                                return Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ProductTile(
                                        product: products[index],
                                        onTap: () => searchVoucherController.toggleProductSelection(product),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(Icons.check_circle,
                                            color: Colors
                                                .blue), // Selection indicator
                                      ),
                                  ],
                                );
                              });
                            } else {
                              return ProductVoucherShimmer();
                            }
                          }
                      );
                    } else if(searchVoucherController.products.isEmpty) {
                      return const AnimationLoaderWidgets(text: 'Whoops! No products found...', animation: Images.pencilAnimation);
                    } else {
                      final products = searchVoucherController.products;
                      return GridLayout(
                          itemCount: searchVoucherController.isLoadingMore.value ? products.length + 2 : products.length,
                          crossAxisCount: 1,
                          mainAxisExtent: AppSizes.productVoucherTileHeight,
                          itemBuilder: (context, index) {
                            if (index < products.length) {
                              return Obx(() {
                                final product = searchVoucherController.products[index];
                                final isSelected = searchVoucherController.selectedProducts.contains(product);
                                return Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ProductTile(
                                        product: products[index],
                                        onTap: () => searchVoucherController.toggleProductSelection(product),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Icon(Icons.check_circle,
                                            color: Colors
                                                .blue), // Selection indicator
                                      ),
                                  ],
                                );
                              });
                            } else {
                              return ProductVoucherShimmer();
                            }
                          }
                      );
                    }
                  }),
              SearchType.customer => Obx(() {
                const double customerVoucherTileHeight = AppSizes.customerVoucherTileHeight; // Updated constant
                if (searchVoucherController.isLoading.value) {
                  return CustomersTileShimmer(itemCount: 2);
                } else if(searchQuery.isEmpty) {
                  return searchVoucherController.selectedVendor.value.companyName != null
                      ? Obx(() {
                          final customer = searchVoucherController.selectedCustomer.value;
                          return Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: InkWell(
                                  onTap: () => searchVoucherController.toggleCustomerSelection(customer),
                                  child: CustomerTile(customer: customer),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(Icons.check_circle, color: Colors.blue), // Selection indicator
                              ),
                            ],
                          );
                        })
                      : SizedBox.shrink();
                } else if(searchVoucherController.customers.isEmpty) {
                  return const AnimationLoaderWidgets(text: 'Whoops! No Customer found...', animation: Images.pencilAnimation);
                } else {
                  final customers = searchVoucherController.customers;
                  return GridLayout(
                      itemCount: searchVoucherController.isLoadingMore.value ? customers.length + 2 : customers.length,
                      crossAxisCount: 1,
                      mainAxisExtent: customerVoucherTileHeight,
                      itemBuilder: (context, index) {
                        if (index < customers.length) {
                          return Obx(() {
                            final customer = searchVoucherController.customers[index];
                            final isSelected = searchVoucherController.customers.contains(searchVoucherController.selectedCustomer.value);
                            return Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomerTile(
                                    customer: customer,
                                    onTap: () => searchVoucherController.toggleCustomerSelection(customer),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(Icons.check_circle,
                                        color: Colors
                                            .blue), // Selection indicator
                                  ),
                              ],
                            );
                          });
                        } else {
                          return CustomersTileShimmer();
                        }
                      }
                  );
                }
              }),
              SearchType.sale => SalesGridLayout(
                controller: searchVoucherController,
              ),
              SearchType.vendor => Obx(() {
                const double vendorTileHeight = AppSizes.vendorTileHeight; // Updated constant
                if (searchVoucherController.isLoading.value) {
                  return VendorTileSimmer(itemCount: 2);
                } else if(searchQuery.isEmpty) {
                  return searchVoucherController.selectedVendor.value.companyName != null
                      ? Obx(() {
                          final vendor = searchVoucherController.selectedVendor.value;
                          return Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: InkWell(
                                  onTap: () => searchVoucherController.toggleVendorSelection(vendor),
                                  child: VendorTile(
                                    vendor: vendor,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(Icons.check_circle,
                                    color: Colors
                                        .blue), // Selection indicator
                              ),
                            ],
                          );
                        })
                      : SizedBox.shrink();
                } else if(searchVoucherController.vendors.isEmpty) {
                  return const AnimationLoaderWidgets(text: 'Whoops! No Vendor found...', animation: Images.pencilAnimation);
                } else {
                  final vendors = searchVoucherController.vendors;
                  return GridLayout(
                      itemCount: searchVoucherController.isLoadingMore.value ? vendors.length + 2 : vendors.length,
                      crossAxisCount: 1,
                      mainAxisExtent: vendorTileHeight,
                      itemBuilder: (context, index) {
                        if (index < vendors.length) {
                          return Obx(() {
                            final vendor = searchVoucherController.vendors[index];
                            final isSelected = searchVoucherController.vendors.contains(searchVoucherController.selectedVendor.value);
                            return Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: VendorTile(
                                    vendor: vendor,
                                    onTap: () => searchVoucherController.toggleVendorSelection(vendor),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(Icons.check_circle,
                                        color: Colors
                                            .blue), // Selection indicator
                                  ),
                              ],
                            );
                          });
                        } else {
                          return VendorTileSimmer();
                        }
                      }
                  );
                }
              }),
              SearchType.account => Obx(() {
                const double accountTileHeight = AppSizes.accountTileHeight; // Updated constant
                if (searchVoucherController.isLoading.value) {
                  return  AccountTileSimmer(itemCount: 2);
                } else if(searchQuery.isEmpty) {
                  return searchVoucherController.selectedAccounts.value.accountName != null
                      ? Obx(() {
                          final selectedAccount = searchVoucherController.selectedAccounts.value;
                          return Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: AccountTile(
                                  account: selectedAccount,
                                  onTap: () => searchVoucherController.toggleAccountSelection(selectedAccount),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(Icons.check_circle, color: Colors.blue), // Selection indicator
                              ),
                            ],
                          );
                        })
                      : SizedBox.shrink();
                } else if(searchVoucherController.accounts.isEmpty) {
                  return const AnimationLoaderWidgets(text: 'Whoops! No Payment Method Method found...', animation: Images.pencilAnimation);
                } else {
                  final accounts = searchVoucherController.accounts;
                  return GridLayout(
                      itemCount: searchVoucherController.isLoadingMore.value ? accounts.length + 2 : accounts.length,
                      crossAxisCount: 1,
                      mainAxisExtent: accountTileHeight,
                      itemBuilder: (context, index) {
                        if (index < accounts.length) {
                          return Obx(() {
                            final account = searchVoucherController.accounts[index];
                            final isSelected = searchVoucherController.accounts.contains(searchVoucherController.selectedAccounts.value);
                            return Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: AccountTile(
                                      account: account,
                                      onTap: () => searchVoucherController.toggleAccountSelection(account),
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(Icons.check_circle, color: Colors.blue), // Selection indicator
                                  ),
                              ],
                            );
                          });
                        } else {
                          return AccountTileSimmer();
                        }
                      }
                  );
                }
              }),
              // TODO: Handle this case.
              SearchType.purchase => throw UnimplementedError(),
            }
          ],
        ),
      ),
    );
  }
}