import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/modules/login_screen_module/login_screen_controller.dart';
import 'dart:developer' as dev;

/// service to handle auto-logout when app is minimized for too long
class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  static const int sessionTimeoutMinutes = 10;

  final _box = GetStorage();
  DateTime? _pausedAt;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    dev.log('AppLifecycleService initialized', name: 'Lifecycle');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    dev.log('App lifecycle state: $state', name: 'Lifecycle');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // app going to background
        _pausedAt = DateTime.now();
        dev.log('App paused at: $_pausedAt', name: 'Lifecycle');
        break;

      case AppLifecycleState.resumed:
        // app coming back to foreground
        _checkSessionTimeout();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // app being terminated or hidden
        break;
    }
  }

  void _checkSessionTimeout() {
    if (_pausedAt == null) return;

    final now = DateTime.now();
    final diff = now.difference(_pausedAt!);

    dev.log('App resumed. Was paused for ${diff.inMinutes} minutes',
        name: 'Lifecycle');

    if (diff.inMinutes >= sessionTimeoutMinutes) {
      dev.log('Session timeout exceeded, logging out...', name: 'Lifecycle');
      _handleSessionTimeout();
    }

    _pausedAt = null;
  }

  void _handleSessionTimeout() {
    // check if user is logged in
    final token = _box.read('token');
    if (token == null || token.toString().isEmpty) {
      dev.log('No active session, skipping logout', name: 'Lifecycle');
      return;
    }

    try {
      Get.find<LoginScreenController>().logout();
      dev.log('Session cleared via LoginScreenController', name: 'Lifecycle');
    } catch (e) {
      dev.log('Error calling logout: $e', name: 'Lifecycle');
      _box.remove('token');
      _box.remove('cached_profile');
      _box.remove('biometric_username_real');
      _box.remove('user_email');
    }

    // navigate to login screen
    Get.offAllNamed(Routes.LOGIN_SCREEN);

    Get.snackbar(
      'Session Expired',
      'Please log in again to continue',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
