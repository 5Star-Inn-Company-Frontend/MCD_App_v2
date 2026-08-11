import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:logger/logger.dart';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  final Logger _logger = Logger();
  final String _appId = "db4e01e4-7457-41c5-8a25-942224b56f22";

  Future<void> init() async {
    try {
      // Remove this method to stop OneSignal Debugging
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize(_appId);

      // The promptForPushNotificationsWithUserResponse will show the native iOS or Android notification permission prompt.
      // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
      OneSignal.Notifications.requestPermission(true);

      _logger.i("OneSignal initialized successfully");
    } catch (e) {
      _logger.e("Error initializing OneSignal: $e");
    }
  }

  void setExternalUserId(String userId) {
    OneSignal.login(userId);
  }

  void logout() {
    OneSignal.logout();
  }
}
