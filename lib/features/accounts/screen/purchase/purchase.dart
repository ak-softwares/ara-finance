import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/navigation_bar/appbar.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/purchase/purchase_controller.dart';
import 'add_new_purchase.dart';
import 'widget/purchase_shimmer.dart';
import 'widget/purchase_tile.dart';

class Purchase extends StatelessWidget {
  const Purchase({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final purchaseController = Get.put(PurchaseController());
    final double purchaseTileHeight = AppSizes.purchaseTileHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      purchaseController.refreshPurchases();
    });

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!purchaseController.isLoadingMore.value){
          const int itemsPerPage = 10;
          if (purchaseController.purchases.length % itemsPerPage != 0) {
            return;
          }
          purchaseController.isLoadingMore(true);
          purchaseController.currentPage++;
          await purchaseController.getPurchases();
          purchaseController.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Purchase Found...',
      animation: Images.pencilAnimation,
    );

    return Scaffold(
        appBar: const AppAppBar(title: 'Purchases Voucher', searchType: SearchType.purchase),
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          backgroundColor: Colors.blue,
          onPressed: () => Get.to(() => AddNewPurchase()),
          tooltip: 'Send WhatsApp Message',
          child: Icon(LineIcons.plus, size: 30, color: Colors.white,),
        ),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async => purchaseController.refreshPurchases(),
          child: ListView(
            controller: scrollController,
            padding: AppSpacingStyle.defaultPagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Obx(() {
                if (purchaseController.isLoading.value) {
                  return PurchaseShimmer(itemCount: 2);
                } else if(purchaseController.purchases.isEmpty) {
                  return emptyWidget;
                } else {
                  final purchases = purchaseController.purchases;
                  return Column(
                    children: [
                      GridLayout(
                          itemCount: purchaseController.isLoadingMore.value ? purchases.length + 2 : purchases.length,
                          crossAxisCount: 1,
                          mainAxisExtent: purchaseTileHeight,
                          itemBuilder: (context, index) {
                            if (index < purchases.length) {
                              return PurchaseTile(purchase: purchases[index]);
                            } else {
                              return PurchaseShimmer();
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
