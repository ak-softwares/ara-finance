import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/text/section_heading.dart';
import '../../../../../common/widgets/shimmers/product_voucher_shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/search_controller/search_controller.dart';
import '../../../controller/search_controller/search_controller3.dart';
import '../../account_voucher/widget/account_voucher_simmer.dart';
import '../../account_voucher/widget/account_voucher_tile.dart';
import '../../products/widget/product_tile.dart';

class SearchScreen3 extends StatelessWidget {
  const SearchScreen3({
    super.key,
    required this.title,
    required this.searchQuery,
    required this.voucherType,
    this.selectedItems,
  });

  final String title;
  final String searchQuery;
  final AccountVoucherType voucherType;
  final dynamic selectedItems;

  @override
  Widget build(BuildContext context) {

    final ScrollController scrollController = ScrollController();
    final searchController = Get.put(SearchController3());

    // Schedule the search refresh to occur after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!searchController.isLoading.value) {
        searchController.refreshSearch(query: searchQuery, voucherType: this.voucherType);
      }
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!searchController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (searchController.products.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          searchController.isLoadingMore(true);
          searchController.currentPage++; // Increment current page
          await searchController.getItemsBySearchQuery(query: searchQuery, voucherType: this.voucherType, page: searchController.currentPage.value);
          searchController.isLoadingMore(false);
        }
      }
    });

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: ElevatedButton(
            onPressed: () => searchController.confirmSelection(context: context, voucherType: voucherType),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Done '),
                Text(searchController.getItemsCount(voucherType: voucherType).toString())
              ],
            )),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => searchController.refreshSearch(query: searchQuery, voucherType: this.voucherType),
        child: ListView(
          controller: scrollController,
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SectionHeading(title: title),
            if(voucherType == AccountVoucherType.product)
              Obx(() {
                  if (searchController.isLoading.value) {
                    return  ProductVoucherShimmer(itemCount: 2);
                  } else if(searchQuery.isEmpty) {
                    final products = searchController.selectedProducts;
                    return GridLayout(
                        itemCount: searchController.selectedProducts.length,
                        crossAxisCount: 1,
                        mainAxisExtent: AppSizes.productVoucherTileHeight,
                        itemBuilder: (context, index) {
                          if (index < products.length) {
                            return Obx(() {
                              final product = searchController.selectedProducts[index];
                              final isSelected = searchController.selectedProducts.contains(product);
                              return Stack(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ProductTile(
                                      product: products[index],
                                      onTap: () => searchController.toggleProductSelection(product),
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
                  } else if(searchController.products.isEmpty) {
                    return const AnimationLoaderWidgets(text: 'Whoops! No products found...', animation: Images.pencilAnimation);
                  } else {
                    final products = searchController.products;
                    return GridLayout(
                        itemCount: searchController.isLoadingMore.value ? products.length + 2 : products.length,
                        crossAxisCount: 1,
                        mainAxisExtent: AppSizes.productVoucherTileHeight,
                        itemBuilder: (context, index) {
                          if (index < products.length) {
                            return Obx(() {
                              final product = searchController.products[index];
                              final isSelected = searchController.selectedProducts.contains(product);
                              return Stack(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ProductTile(
                                      product: products[index],
                                      onTap: () => searchController.toggleProductSelection(product),
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
              })
            else
              Obx(() {
                const double accountTileHeight = AppSizes.accountTileHeight; // Updated constant
                if (searchController.isLoading.value) {
                  return  AccountVoucherTileShimmer(itemCount: 2);
                } else if(searchQuery.isEmpty) {
                  return searchController.selectedVoucher.value.id != null
                      ? Obx(() {
                          final selectedVoucher = searchController.selectedVoucher.value;
                          return Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: AccountVoucherTile(
                                  voucherType: voucherType,
                                  accountVoucher: selectedVoucher,
                                  onTap: () => searchController.toggleAccountVoucherSelection(voucher: selectedVoucher),
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
                } else if(searchController.accountVouchers.isEmpty) {
                  return const AnimationLoaderWidgets(text: 'Whoops! No Payment Method Method found...', animation: Images.pencilAnimation);
                } else {
                  final customers = searchController.accountVouchers;
                  return GridLayout(
                      itemCount: searchController.isLoadingMore.value ? customers.length + 2 : customers.length,
                      crossAxisCount: 1,
                      mainAxisExtent: accountTileHeight,
                      itemBuilder: (context, index) {
                        if (index < customers.length) {
                          return Obx(() {
                            final accountVouchers = searchController.accountVouchers[index];
                            final isSelected = searchController.accountVouchers.contains(searchController.selectedVoucher.value);
                            return Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: AccountVoucherTile(
                                    accountVoucher: accountVouchers,
                                    voucherType: voucherType,
                                    onTap: () => searchController.toggleAccountVoucherSelection(voucher: accountVouchers),
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
                          return AccountVoucherTileShimmer();
                        }
                      }
                  );
                }
              }),
          ],
        ),
      ),
    );
  }
}