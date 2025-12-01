import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'package:pass_rate/core/utils/logger_utils.dart';

class DeviceIdService {
  static Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // iOS Vendor ID
      }
    } catch (e) {
      LoggerUtils.debug('Error getting device ID: $e');
    }

    return null;
  }
}