import 'package:get_storage/get_storage.dart';
import 'dart:developer' as dev;
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:mcd/core/import/imports.dart';

class QrcodeRequestFundModuleController extends GetxController {
  final GetStorage _storage = GetStorage();

  // Global key for capturing QR code
  final qrKey = GlobalKey();

  // User data observables
  final _username = ''.obs;
  String get username => _username.value;

  final _email = ''.obs;
  String get email => _email.value;

  final _isSaving = false.obs;
  bool get isSaving => _isSaving.value;

  // QR data - embed username
  String get qrData => username;

  
  // helper to capture and save qr image, returns path
  Future<String?> _captureAndSaveQRCode() async {
    final boundary =
        qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Unable to capture QR code');
    }

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    String? savedPath;
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.photos.status;

      if (!status.isGranted) {
        status = await Permission.photos.request();

        if (!status.isGranted) {
          status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
        }
      }

      if (status.isPermanentlyDenied) {
        Get.snackbar(
          'Permission Required',
          'Please enable storage permission in Settings',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          duration: const Duration(seconds: 3),
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child:
                const Text('Settings', style: TextStyle(color: Colors.white)),
          ),
        );
        return null;
      }

      if (!status.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to save QR code',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return null;
      }

      // save to downloads folder
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File(
          '${directory.path}/MCD_QR_${username}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      savedPath = file.path;
      dev.log('QR code saved to: $savedPath', name: 'MyQRCode');
    } else {
      // for ios or other platforms
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/MCD_QR_${username}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      savedPath = file.path;
    }

    return savedPath;
  }

  // save qr code to gallery only (no share)
  Future<void> saveQRCode() async {
    try {
      _isSaving.value = true;
      dev.log('Saving QR code to gallery', name: 'MyQRCode');

      final savedPath = await _captureAndSaveQRCode();
      if (savedPath == null) return;

      Get.snackbar(
        'Success',
        'QR Code saved to Downloads',
        backgroundColor: AppColors.successBgColor,
        colorText: AppColors.textSnackbarColor,
      );

      dev.log('QR code saved successfully', name: 'MyQRCode');
    } catch (e) {
      dev.log('Error saving QR code', name: 'MyQRCode', error: e);
      Get.snackbar(
        'Error',
        'Failed to save QR code: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      _isSaving.value = false;
    }
  }
}
