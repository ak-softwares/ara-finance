import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../dialog_box_massages/snack_bar_massages.dart';

//manages the network connectivity status and provides method to checl and handel connectivity changes
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Initialize the network manager and set up a stream to continually check the connection status.
  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  //Dispose or close the active connectivity stream
  @override
  dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  ///update the connection status based on changes in connectivity and show a relevant popup for no internet connection
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {

    if (result.contains(ConnectivityResult.none)) {
      AppMassages.warningSnackBar(title: 'No Internet Connection');
    }
    // final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    // This condition is for demo purposes only to explain every connection type.
// Use conditions which work for your requirements.
//     if (connectivityResult.contains(ConnectivityResult.mobile)) {
//       // Mobile network available.
//     } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
//       // Wi-fi is available.
//       // Note for Android:
//       // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
//     } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
//       // Ethernet connection available.
//     } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
//       // Vpn connection active.
//       // Note for iOS and macOS:
//       // There is no separate network interface type for [vpn].
//       // It returns [other] on any device (also simulator)
//     } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
//       // Bluetooth connection available.
//     } else if (connectivityResult.contains(ConnectivityResult.other)) {
//       // Connected to a network which is not in the above mentioned networks.
//     } else if (connectivityResult.contains(ConnectivityResult.none)) {
//       // No available network types
//     }
  }

  ///check the internet connection status
  ///return 'true' if connected, 'false' otherwise.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if(result == ConnectivityResult.none) {
        return false;
      } else {
        return true;
      }
    } on PlatformException catch (_) {
      return false;
    }
  }
}