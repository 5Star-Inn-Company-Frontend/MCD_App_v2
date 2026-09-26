import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:developer' as dev;

class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _cachedDeviceString;
  String? _cachedAppVersion;

  // app version - should be set during app init
  static const String appVersion = '1.0.0';

  Future<void> initialize() async {
    await _buildDeviceString();
    _cachedAppVersion = appVersion;
    dev.log(
        'DeviceInfoService initialized: device=$_cachedDeviceString, version=$_cachedAppVersion',
        name: 'DeviceInfo');
  }

  Future<String> _buildDeviceString() async {
    if (_cachedDeviceString != null) {
      return _cachedDeviceString!;
    }

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedDeviceString =
            '${androidInfo.version.release} | ${androidInfo.model} | ${androidInfo.manufacturer} | ${androidInfo.brand} | ${androidInfo.isPhysicalDevice}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _cachedDeviceString =
            '${iosInfo.systemVersion} | ${iosInfo.model} | Apple | ${iosInfo.name} | ${iosInfo.isPhysicalDevice} | ${iosInfo.identifierForVendor}';
      } else {
        _cachedDeviceString = 'Unknown Device';
      }
    } catch (e) {
      dev.log('Error getting device info: $e', name: 'DeviceInfo');
      _cachedDeviceString = 'Unknown Device';
    }

    return _cachedDeviceString!;
  }

  String get deviceString => _cachedDeviceString ?? 'Unknown Device';
  String get version => _cachedAppVersion ?? appVersion;
}
