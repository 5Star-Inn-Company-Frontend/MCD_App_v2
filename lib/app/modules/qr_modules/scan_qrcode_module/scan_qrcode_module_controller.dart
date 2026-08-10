import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  final box = GetStorage();
  final savedQRCodes = <Map<String, dynamic>>[].obs;
  final saveContact = false.obs;
  final nicknameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSavedQRCodes();
  }

  void loadSavedQRCodes() {
    final List<dynamic>? stored = box.read<List<dynamic>>('saved_qr_contacts');
    if (stored != null) {
      savedQRCodes.assignAll(stored.map((e) => Map<String, dynamic>.from(e)).toList());
    }
  }

  void saveQRCode(String username, String? email, String nickname) {
    final contact = {
      'username': username,
      'email': email,
      'nickname': nickname,
      'date': DateTime.now().toIso8601String(),
    };
    savedQRCodes.insert(0, contact);
    box.write('saved_qr_contacts', savedQRCodes.toList());
  }

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
          _showConfirmationDialog(username, email);
        } catch (e) {
          // Check if it's semicolon-separated format (username;email;)
          if (scanData.code!.contains(';')) {
            final parts = scanData.code!.split(';');
            if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
              final username = parts[0].trim();
              final email = parts[1].trim();
              dev.log('Parsed semicolon-separated QR data - Username: $username, Email: $email', name: 'QRScanner');
              _showConfirmationDialog(username, email);
              return;
            }
          }
          
          // Fallback: treat as plain username (old format)
          dev.log('QR code is not JSON or semicolon format, treating as username: ${scanData.code}', name: 'QRScanner');
          String scannedUsername = scanData.code!.trim();
          _showConfirmationDialog(scannedUsername, null);
        }
      }
    });
  }

  void _showConfirmationDialog(String username, String? email) {
    saveContact.value = false;
    nicknameController.clear();

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Confirm Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please confirm the scanned user details before proceeding:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Username', style: TextStyle(color: Colors.black54)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              username, 
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if (email != null && email.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Email', style: TextStyle(color: Colors.black54)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                email,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Save this contact for later', style: TextStyle(fontSize: 14)),
                      value: saveContact.value,
                      activeColor: AppColors.primaryColor,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        saveContact.value = val ?? false;
                      },
                    )),
                Obx(() => saveContact.value
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextField(
                          controller: nicknameController,
                          decoration: InputDecoration(
                            hintText: 'Enter nickname (e.g. John Doe)',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back(); // close dialog
                          _isProcessing.value = false;
                          _result.value = null;
                          qrController?.resumeCamera();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (saveContact.value && nicknameController.text.trim().isNotEmpty) {
                            saveQRCode(username, email, nicknameController.text.trim());
                          }
                          Get.back(); // close dialog
                          Get.offNamed(
                            Routes.QRCODE_TRANSFER_DETAILS_MODULE,
                            arguments: {
                              'username': username,
                              if (email != null && email.isNotEmpty) 'email': email,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                          elevation: 0,
                        ),
                        child: const Text('Proceed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
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
