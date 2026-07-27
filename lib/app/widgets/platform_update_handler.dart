import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';

import 'package:mcd/app/widgets/custom_upgrade_alert.dart';

class PlatformUpdateHandler extends StatefulWidget {
  final Widget child;

  const PlatformUpdateHandler({super.key, required this.child});

  @override
  State<PlatformUpdateHandler> createState() => _PlatformUpdateHandlerState();
}

class _PlatformUpdateHandlerState extends State<PlatformUpdateHandler> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _checkForAndroidUpdate();
    }
  }

  Future<void> _checkForAndroidUpdate() async {
    try {
      dev.log('Checking for Android in-app update...', name: 'UpdateHandler');
      final updateInfo = await InAppUpdate.checkForUpdate();
      
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          dev.log('Update available! Prompting immediate update.', name: 'UpdateHandler');
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
           dev.log('Update available! Prompting flexible update.', name: 'UpdateHandler');
           await InAppUpdate.startFlexibleUpdate();
           await InAppUpdate.completeFlexibleUpdate();
        }
      } else {
        dev.log('No update available or update not possible.', name: 'UpdateHandler');
      }
    } on PlatformException catch (e) {
      dev.log('InAppUpdate PlatformException (expected on emulators): ${e.message}', name: 'UpdateHandler');
    } catch (e) {
      dev.log('Error checking for Android update: $e', name: 'UpdateHandler');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CustomUpgradeAlert(
        navigatorKey: Get.key,
        upgrader: Upgrader(),
        child: widget.child,
      );
    }
    
    // for Android or other platforms, we return the child directly as updates are handled through the InAppUpdate in the initState method
    return widget.child;
  }
}
