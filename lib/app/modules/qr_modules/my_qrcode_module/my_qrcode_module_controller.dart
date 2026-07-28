import 'package:get_storage/get_storage.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';

import 'package:mcd/core/import/imports.dart';

import '../../../../core/services/storage_service.dart';

class MyQrcodeModuleController extends GetxController {
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

  // QR data - embed username and email as JSON
  String get qrData {
    final data = {
      'username': username,
      'email': email,
    };
    return jsonEncode(data);
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    try {
      // Load from StorageService or fallback to direct storage
      final storage = StorageService.to;
      _username.value = storage.username ?? _storage.read('username') ?? 'User';
      _email.value = storage.userEmail ?? _storage.read('email') ?? 'user@example.com';
      dev.log(
          'Loaded user data from storage - Username: ${_username.value}, Email: ${_email.value}');
    } catch (e) {
      dev.log('Error loading user data from storage: $e');
      // Final fallback to storage
      _username.value = _storage.read('username') ?? 'User';
      _email.value = _storage.read('email') ?? 'user@example.com';
    }
  }

  final _isSharing = false.obs;
  bool get isSharing => _isSharing.value;

  // helper to capture and save qr image, returns path
  Future<String?> _captureAndSaveQRCode({bool forGallery = false}) async {
    final boundary =
        qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Unable to capture QR code');
    }

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    if (forGallery) {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'MCD_QR_${username}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      
      await Gal.putImage(file.path);
      dev.log('QR code saved to gallery', name: 'MyQRCode');
      return 'gallery';
    } else {
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/MCD_QR_${username}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);
      return file.path;
    }
  }

  // save qr code to gallery only (no share)
  Future<void> saveQRCode() async {
    try {
      _isSaving.value = true;
      dev.log('Saving QR code to gallery', name: 'MyQRCode');

      final savedPath = await _captureAndSaveQRCode(forGallery: true);
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

  // save and share qr with custom message for fund request
  Future<void> shareQRCodeWithMessage() async {
    try {
      _isSharing.value = true;
      dev.log('Sharing QR code with message', name: 'MyQRCode');

      final savedPath = await _captureAndSaveQRCode(forGallery: false);
      if (savedPath == null) return;

      // share with fund request message
      await Share.shareXFiles(
        [XFile(savedPath)],
        text: 'Kindly credit me any amount, thanks.',
      );

      dev.log('QR code shared successfully', name: 'MyQRCode');
    } catch (e) {
      dev.log('Error sharing QR code', name: 'MyQRCode', error: e);
      Get.snackbar(
        'Error',
        'Failed to share QR code: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      _isSharing.value = false;
    }
  }
}
