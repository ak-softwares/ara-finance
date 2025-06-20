import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/accounts/screen/account_voucher/account_vouchers.dart';
import '../../features/accounts/screen/financials/financials.dart';
import '../../features/accounts/screen/products/products.dart';
import '../../features/accounts/screen/transaction/transactions.dart';
import '../../features/personalization/screens/user_menu/user_menu_screen.dart';

import '../../utils/constants/enums.dart';
import '../../utils/constants/icons.dart';
import '../dialog_box_massages/snack_bar_massages.dart';


class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, this.route});

  final String? route;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  int _currentIndex = 0;
  DateTime? _lastBackPressedTime; // Variable to track the time of the last back button press
  final screens = [
    const Financials(),
    const AccountVouchers(voucherType: AccountVoucherType.sale),
    const Transactions(),
    const Products(),
    const UserMenuScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    // FBAnalytics.logPageView('bottom_navigation_bar1_screen');
    return PopScope(
      canPop: false, // This property disables the system-level back navigation
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if(_currentIndex != 0){
          setState(() => _currentIndex = 0);
        } else {
          // Check if _lastBackPressedTime is not null and the difference between the current time
          // and the last back pressed time is less than 2 seconds
          if (_lastBackPressedTime != null &&
              DateTime.now().difference(_lastBackPressedTime!) <= const Duration(seconds: 2)) {
            // If the conditions are met, exit the app
            SystemNavigator.pop();
          } else {
            // If not, show a toast message and update _lastBackPressedTime
            AppMassages.showToastMessage(message: "Press Back Again To Exit");
            _lastBackPressedTime = DateTime.now();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent, // Disables ripple effect
            highlightColor: Colors.transparent, // Removes highlight on tap
            hoverColor: Colors.transparent, // Ensures no hover effect
            cardColor: Colors.transparent,
          ),
          child: Container(
            // height: 60, // Adjust height as needed
            // padding: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline, // Change color as needed
                  width: 0.2, // Adjust thickness
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              iconSize: 25,
              fixedColor: Theme.of(context).colorScheme.onSurface,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              // backgroundColor: Theme.of(context).colorScheme.surface,
              // selectedFontSize: 12,
              // unselectedFontSize: 12,
              // selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              // unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
              // selectedFontSize: 10,
              // unselectedFontSize: 20,
              items: [
                BottomNavigationBarItem(
                  label: 'Financials',
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home), // Icon when selected
                ),
                BottomNavigationBarItem(
                  label: 'Sales',
                  icon: Icon(AppIcons.sales),
                ),
                BottomNavigationBarItem(
                  label: 'Transaction',
                  icon: Icon(Icons.receipt),
                ),
                BottomNavigationBarItem(
                  label: 'Product',
                  icon: Icon(AppIcons.products),
                ),
                BottomNavigationBarItem(
                  label: 'User Menu',
                  icon: Icon(AppIcons.user),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
