import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/app.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/services/ads_service.dart';
import 'package:mcd/core/services/device_info_service.dart';
import 'package:mcd/core/services/connectivity_service.dart';
import 'package:mcd/core/services/app_lifecycle_service.dart';
import 'package:mcd/core/controllers/service_status_controller.dart';
import 'package:mcd/core/controllers/payment_config_controller.dart';
import 'package:mcd/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  dev.log('Handling background message: ${message.messageId}', name: 'FCM');

  if (message.notification != null) {
    dev.log('Background notification: ${message.notification!.title}',
        name: 'FCM');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  if (Platform.isAndroid || Platform.isIOS) {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  await GetStorage.init();
  await DeviceInfoService().initialize();
  await AdsService().initialize(testMode: false);

  await Get.putAsync(() async => ConnectivityService());

  Get.put(ServiceStatusController());
  Get.put(PaymentConfigController());
  Get.put(LoginScreenController());

  // Initialize app lifecycle service for auto-logout
  Get.put(AppLifecycleService());
  if (Platform.isAndroid || Platform.isIOS) {
    // Set up foreground message handling
    _setupForegroundMessageHandler();
  }

  runApp(McdApp());
}

/// Setup foreground message handler
void _setupForegroundMessageHandler() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    dev.log('Foreground message received: ${message.messageId}', name: 'FCM');

    if (message.notification != null) {
      dev.log(
          'Notification: ${message.notification!.title} - ${message.notification!.body}',
          name: 'FCM');

      // Show in-app notification
      Get.snackbar(
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? '',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(10),
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
        icon: const Icon(Icons.notifications, color: Colors.white),
      );
    }

    // Handle data payload
    if (message.data.isNotEmpty) {
      dev.log('Data: ${message.data}', name: 'FCM');
      _handleNotificationData(message.data);
    }
  });

  // Handle notification tap when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    dev.log('Notification tapped (app in background): ${message.messageId}',
        name: 'FCM');

    if (message.data.isNotEmpty) {
      _handleNotificationData(message.data);
    }
  });

  // Check if app was opened from a terminated state via notification
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      dev.log(
          'App opened from terminated state via notification: ${message.messageId}',
          name: 'FCM');

      if (message.data.isNotEmpty) {
        _handleNotificationData(message.data);
      }
    }
  });
}

/// Handle notification data and navigate accordingly
void _handleNotificationData(Map<String, dynamic> data) {
  try {
    final type = data['type'];

    if (type == 'giveaway') {
      // Navigate to giveaway page
      final giveawayId = data['giveaway_id'];
      dev.log('Navigating to giveaway: $giveawayId', name: 'FCM');

      // Use Get.toNamed when your route is ready
      // Get.toNamed(Routes.GIVEAWAY_MODULE, arguments: {'id': giveawayId});
    }
  } catch (e) {
    dev.log('Error handling notification data', error: e, name: 'FCM');
  }
}
