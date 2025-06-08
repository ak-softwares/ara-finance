import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../../common/layout_models/sales_grid_layout.dart';
import '../../../../../common/layout_models/product_grid_layout.dart';
import '../../../../../common/styles/spacing_style.dart';
import '../../../../../common/text/section_heading.dart';
import '../../../../../common/widgets/shimmers/product_voucher_shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controller/search_controller/search_controller.dart';
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
    final searchVoucherController = Get.put(SearchVoucherController());

    // Schedule the search refresh to occur after the current frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!searchVoucherController.isLoading.value) {
        searchVoucherController.refreshSearch(query: searchQuery, voucherType: this.voucherType);
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
          await searchVoucherController.getItemsBySearchQuery(query: searchQuery, voucherType: this.voucherType, page: searchVoucherController.currentPage.value);
          searchVoucherController.isLoadingMore(false);
        }
      }
    });

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: ElevatedButton(
            onPressed: () => searchVoucherController.confirmSelection(context: context, voucherType: this.voucherType),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Done '),
                Text(searchVoucherController.getItemsCount(voucherType: voucherType).toString())
              ],
            )),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.refreshIndicator,
        onRefresh: () async => searchVoucherController.refreshSearch(query: searchQuery, voucherType: this.voucherType),
        child: ListView(
          controller: scrollController,
          padding: AppSpacingStyle.defaultPagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SectionHeading(title: title),
            if(voucherType == AccountVoucherType.product)
              Obx(() {
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
              })
            else
              Obx(() {
                const double accountTileHeight = AppSizes.accountTileHeight; // Updated constant
                if (searchVoucherController.isLoading.value) {
                  return  AccountVoucherTileShimmer(itemCount: 2);
                } else if(searchQuery.isEmpty) {
                  return searchVoucherController.selectedVoucher.value.id != null
                      ? Obx(() {
                          final selectedVoucher = searchVoucherController.selectedVoucher.value;
                          return Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: AccountVoucherTile(
                                  voucherType: voucherType,
                                  accountVoucher: selectedVoucher,
                                  onTap: () => searchVoucherController.toggleAccountVoucherSelection(voucher: selectedVoucher),
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
                } else if(searchVoucherController.accountVouchers.isEmpty) {
                  return const AnimationLoaderWidgets(text: 'Whoops! No Payment Method Method found...', animation: Images.pencilAnimation);
                } else {
                  final customers = searchVoucherController.accountVouchers;
                  return GridLayout(
                      itemCount: searchVoucherController.isLoadingMore.value ? customers.length + 2 : customers.length,
                      crossAxisCount: 1,
                      mainAxisExtent: accountTileHeight,
                      itemBuilder: (context, index) {
                        if (index < customers.length) {
                          return Obx(() {
                            final accountVouchers = searchVoucherController.accountVouchers[index];
                            final isSelected = searchVoucherController.accountVouchers.contains(searchVoucherController.selectedVoucher.value);
                            return Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: AccountVoucherTile(
                                    accountVoucher: accountVouchers,
                                    voucherType: voucherType,
                                    onTap: () => searchVoucherController.toggleAccountVoucherSelection(voucher: accountVouchers),
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