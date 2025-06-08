import '../../../../common/dialog_box_massages/animation_loader.dart';
import '../../../../common/layout_models/product_grid_layout.dart';
import '../../../../common/styles/spacing_style.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/navigation_bar/appbar.dart';
import '../controllers/app_user_list_controller.dart';
import 'widget/user_shimmer.dart';
import 'widget/user_tile.dart';

class AppUserList extends StatelessWidget {
  const AppUserList({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final controller = Get.put(AppUserListController());
    const double userTileHeight = AppSizes.userTileHeight;

    controller.refreshUsers();

    scrollController.addListener(() async {
      if (scrollController.position.extentAfter < 0.2 * scrollController.position.maxScrollExtent) {
        if(!controller.isLoadingMore.value){
          // User has scrolled to 80% of the content's height
          const int itemsPerPage = 10; // Number of items per page
          if (controller.users.length % itemsPerPage != 0) {
            // If the length of orders is not a multiple of itemsPerPage, it means all items have been fetched
            return; // Stop fetching
          }
          controller.isLoadingMore(true);
          controller.currentPage++; // Increment current page
          await controller.getAllUsers();
          controller.isLoadingMore(false);
        }
      }
    });

    final Widget emptyWidget = AnimationLoaderWidgets(
      text: 'Whoops! No Users Found...',
      animation: Images.pencilAnimation,
    );

    return Scaffold(
        appBar: AppAppBar(title: 'App Users'),
        body: RefreshIndicator(
          color: AppColors.refreshIndicator,
          onRefresh: () async => controller.refreshUsers(),
          child: ListView(
            controller: scrollController,
            padding: AppSpacingStyle.defaultPagePadding,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Obx(() {
                if (controller.isLoading.value) {
                  return  UserShimmer();
                } else if(controller.users.isEmpty) {
                  return emptyWidget;
                } else {
                  final customers = controller.users;
                  return Column(
                    children: [
                      GridLayout(
                          itemCount: controller.isLoadingMore.value ? customers.length + 2 : customers.length,
                          crossAxisCount: 1,
                          mainAxisExtent: userTileHeight,
                          itemBuilder: (context, index) {
                            if (index < customers.length) {
                              return UserTile(user: customers[index]);
                            } else {
                              return UserShimmer();
                            }
                          }
                      ),
                    ],
                  );
                }
              })
            ],
          ),
        )
    );
  }
}


