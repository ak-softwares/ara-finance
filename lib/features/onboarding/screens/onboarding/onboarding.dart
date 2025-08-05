import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../utils/constants/local_storage_constants.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/device/device_utility.dart';
import '../../../../utils/helpers/navigation_helper.dart';
import 'widgets/onboarding_page.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  late final PageController pageController;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    currentPage = pageController.initialPage;
  }

  void skip() {
    final storage = GetStorage();
    storage.write(LocalStorageName.isFirstRun, false);
    NavigationHelper.navigateToBottomNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Horizontal scrollable page
          PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
              // print('Current Page: ${currentPage + 1}');
            },
            children: const [
              OnBoardingPage(image: Images.onBoardingImage1, title: AppTexts.onBoardingTitle1, subTitle: AppTexts.onBoardingSubTitle1),
              OnBoardingPage(image: Images.onBoardingImage2, title: AppTexts.onBoardingTitle2, subTitle: AppTexts.onBoardingSubTitle2),
              OnBoardingPage(image: Images.onBoardingImage3, title: AppTexts.onBoardingTitle3, subTitle: AppTexts.onBoardingSubTitle3),
            ],
          ),
          // Skip button
          Positioned(
            top: TDeviceUtils.getAppBarHeight(),
            right: AppSizes.defaultSpace,
            child: TextButton(
              onPressed: skip,
              child: const Text('Skip'),
            ),
          ),

          // Dot navigation smoothPageIndicator
          Positioned(
            bottom: TDeviceUtils.getBottomNavigationBarHeight() + 25,
            left: AppSizes.defaultSpace,
            child: Row(
              children: List<Widget>.generate(
                3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 7,
                    width: (index == currentPage) ? 30 : 7,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: (index == currentPage) ? Colors.deepOrange : Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),

          // Circular Next Button
          Positioned(
            bottom: TDeviceUtils.getBottomNavigationBarHeight(),
            right: AppSizes.defaultSpace,
            child: ElevatedButton(
              onPressed: () {
                if(currentPage == 2){
                  skip();
                }else {
                  setState(() {
                    pageController.animateToPage(
                      currentPage + 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: AppColors.buttonBackgroundColor,
                side: BorderSide.none,
              ),
              child: Icon(LineAwesomeIcons.arrow_right_solid),
            ),
          ),
        ],
      ),
    );
  }
}



