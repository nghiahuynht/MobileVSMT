import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/utils/device/device_info_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Helper class for device related operations.
///
class DeviceUtils {
  static late DeviceInfo device;
  static late PackageInfo package;

  static Future loadInfo() async {
    await Future.wait([
      loadDevice(),
      loadPackage(),
    ]);
  }

  static Future loadDevice() async {
    try {
      final DeviceInfoPlugin plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        WebBrowserInfo info = await plugin.webBrowserInfo;
        device = DeviceInfo(
          platformName: info.platform,
          platformVersion: info.appVersion,
          uid: info.appCodeName,
          name: info.appName,
          model: info.product,
          isPhysicalDevice: true,
        );
      } else if (Platform.isAndroid) {
        final AndroidDeviceInfo info = await plugin.androidInfo;
        device = DeviceInfo(
          platformName: info.version.baseOS,
          platformVersion: info.version.release,
          uid: info.id,
          name: info.device,
          model: info.model,
          isPhysicalDevice: info.isPhysicalDevice,
        );
      } else if (Platform.isIOS) {
        final IosDeviceInfo info = await plugin.iosInfo;
        device = DeviceInfo(
          platformName: info.systemName,
          platformVersion: info.systemVersion,
          uid: info.identifierForVendor,
          name: info.name,
          model: info.model,
          isPhysicalDevice: info.isPhysicalDevice,
        );
      }
    } catch (e) {
      device = DeviceInfo();
      // xLog.e(e);
    }
  }

  static Future loadPackage() async {
    package = await PackageInfo.fromPlatform();
  }

  ///
  /// hides the keyboard if its already open
  ///
  static hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  ///
  /// accepts a double [scale] and returns scaled sized based on the screen
  /// orientation
  ///
  static double getScaledSize(BuildContext context, double scale) =>
      scale *
      (MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.height);

  ///
  /// accepts a double [scale] and returns scaled sized based on the screen
  /// width
  ///
  static double getScaledWidth(BuildContext context, double scale) =>
      scale * MediaQuery.of(context).size.width;

  ///
  /// accepts a double [scale] and returns scaled sized based on the screen
  /// height
  ///
  static double getScaledHeight(BuildContext context, double scale) =>
      scale * MediaQuery.of(context).size.height;
}
