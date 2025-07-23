import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission(BuildContext context) async {
  debugPrint('Checking if storage permission is already granted...');

  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

  if (build.version.sdkInt >= 30) {
    if (await Permission.manageExternalStorage.isGranted) {
      debugPrint('Storage permission is already granted.');
      return true;
    }

    debugPrint('Requesting storage permission...');
    // Request permission
    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      debugPrint('Storage permission granted.');
      return true;
    }
  } else {
    debugPrint('Android version < 30, using standard storage permission...');
    if (await Permission.storage.isGranted) {
      debugPrint('Storage permission is already granted.');
      return true;
    }

    debugPrint('Requesting storage permission...');
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      debugPrint('Storage permission granted.');
      return true;
    }
  }

  return false;
}
