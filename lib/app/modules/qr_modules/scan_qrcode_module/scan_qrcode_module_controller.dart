import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:developer' as dev;
import 'package:mcd/app/styles/app_colors.dart';

class ScanQrcodeModuleController extends GetxController {
  QRViewController? qrController;

  final _result = Rxn<String>();
  String? get result => _result.value;

  final _isProcessing = false.obs;
  bool get isProcessing => _isProcessing.value;

  void onQRViewCreated(QRViewController controller) {
    qrController = controller;

    
    controller.resumeCamera();

    controller.scannedDataStream.listen((scanData) {
      
      if (_isProcessing.value) return;

      
      if (scanData.code != null && scanData.code!.isNotEmpty) {
        _isProcessing.value = true;
        _result.value = scanData.code;
        qrController?.pauseCamera();

        dev.log('QR Code scanned: ${scanData.code}', name: 'QRScanner');

        try {
          // Try to parse as JSON (new format with username and email)
          final data = jsonDecode(scanData.code!);
          final username = data['username'];
          final email = data['email'];

          dev.log('Parsed QR data - Username: $username, Email: $email', name: 'QRScanner');

          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offNamed(
              Routes.QRCODE_TRANSFER_DETAILS_MODULE,
              arguments: {
                'username': username,
                'email': email,
              },
            );
          });
        } catch (e) {
          // Check if it's semicolon-separated format (username;email;)
          if (scanData.code!.contains(';')) {
            final parts = scanData.code!.split(';');
            if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
              final username = parts[0].trim();
              final email = parts[1].trim();
              dev.log('Parsed semicolon-separated QR data - Username: $username, Email: $email', name: 'QRScanner');

              Future.delayed(const Duration(milliseconds: 500), () {
                Get.offNamed(
                  Routes.QRCODE_TRANSFER_DETAILS_MODULE,
                  arguments: {
                    'username': username,
                    'email': email,
                  },
                );
              });
              return;
            }
          }
          
          // Fallback: treat as plain username (old format)
          dev.log('QR code is not JSON or semicolon format, treating as username: ${scanData.code}', name: 'QRScanner');
          String scannedUsername = scanData.code!.trim();

          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offNamed(
              Routes.QRCODE_TRANSFER_DETAILS_MODULE,
              arguments: {
                'username': scannedUsername,
              },
            );
          });
        }
      }
    });
  }

  void reassemble() {
    if (Platform.isAndroid) {
      qrController?.pauseCamera();
    }
    qrController?.resumeCamera();
  }

  @override
  void onClose() {
    qrController?.dispose();
    super.onClose();
  }
}
