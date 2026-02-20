import 'package:mcd/core/import/imports.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import './scan_qrcode_module_controller.dart';

class ScanQrcodeModulePage extends GetView<ScanQrcodeModuleController> {
  ScanQrcodeModulePage({super.key});

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: TextSemiBold(
          'Scan QR Code',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: false,
      ),
      body: _scanWidget(context),
    );
  }

  Widget _scanWidget(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Scan your QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.manRope,
                  fontWeight: FontWeight.w900,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: QRView(
              key: qrKey,
              onQRViewCreated: controller.onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: const Color.fromRGBO(51, 160, 88, 1),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: screenWidth(context) * 0.7,
              ),
              onPermissionSet: (ctrl, p) {
                if (!p) {
                  Get.snackbar(
                    'Permission Denied',
                    'Camera permission is required to scan QR codes',
                    backgroundColor: AppColors.errorBgColor,
                    colorText: AppColors.textSnackbarColor,
                  );
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Obx(() => controller.isProcessing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color.fromRGBO(51, 160, 88, 1),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.manRope,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),
            ),
          )
        ],
      ),
    );
  }
}
