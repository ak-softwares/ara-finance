import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/account/account_controller.dart';
import 'add_account.dart';
import 'single_account.dart';
import 'widget/account_tile.dart';
import 'widget/account_tile_simmer.dart';

class Accounts extends StatelessWidget {
  const Accounts({super.key});

  @override
  Widget build(BuildContext context) {
    const double paymentTileHeight = AppSizes.accountTileHeight;

    final ScrollController scrollController = ScrollController();
    final paymentController = Get.put(AccountController());

    paymentController.refreshAccounts();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!paymentController.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (paymentController.accounts.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          paymentController.isLoadingMore(true);
          paymentController.currentPage++; // Increment current page
          await paymentController.getAccounts();
          paymentController.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Accounts Method Found...',
      animation: Images.pencilAnimation,
    );

    return Scaffold(
        appBar: const AppAppBar(title: 'Accounts'),
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () => Get.to(() => AddAccount()),
          tooltip: 'Add Accounts',
          child: Icon(LineIcons.plus, size: 30, color: Colors.white,),
        ),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async => paymentController.refreshAccounts(),
          child: ListView(
            controller: scrollController,
            padding: AppSpacingStyle.defaultPagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Obx(() {
                if (paymentController.isLoading.value) {
                  return  AccountTileSimmer(itemCount: 2);
                } else if(paymentController.accounts.isEmpty) {
                  return emptyWidget;
                } else {
                  final paymentMethods = paymentController.accounts;
                  return Column(
                    children: [
                      GridLayout(
                          itemCount: paymentController.isLoadingMore.value ? paymentMethods.length + 2 : paymentMethods.length,
                          crossAxisCount: 1,
                          mainAxisExtent: paymentTileHeight,
                          itemBuilder: (context, index) {
                            if (index < paymentMethods.length) {
                              return AccountTile(
                                onTap: () => Get.to(() => SingleAccount(account: paymentMethods[index])),
                                account: paymentMethods[index],
                              );
                            } else {
                              return AccountTileSimmer();
                            }
                          }
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        )
    );
  }
}