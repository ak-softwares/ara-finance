import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class RequestPermissions {

  static Future<bool> checkPermission(Permission permission) async {
    PermissionStatus permissionStatus = await permission.request();
    return permissionStatus.isGranted;
  }

  static void showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Permission to access photos is required to perform this action."),
        actions: <Widget>[
          TextButton(
            child: const Text("Open Settings"),
            onPressed: () {
              openAppSettings(); // Opens app settings so the user can grant the permission
            },
          ),
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
        ],
      ),
    );
  }

  static Future<bool> permissionsForSMS() async {
    PermissionStatus permissionStatus = await Permission.sms.request();
    return permissionStatus.isGranted;
  }

  static Future<bool> permissionsForMediaImages() async {
    PermissionStatus permissionStatus = await Permission.mediaLibrary.request();
    return permissionStatus.isGranted;
  }

  static Future<bool> permissionsForMediaVideos() async {
    PermissionStatus permissionStatus = await Permission.mediaLibrary.request();
    return permissionStatus.isGranted;
  }

  static Future<bool> permissionsForFullScreenIntent() async {
    PermissionStatus permissionStatus = await Permission.notification.request();
    return permissionStatus.isGranted;
  }

}
