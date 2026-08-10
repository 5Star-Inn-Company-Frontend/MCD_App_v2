import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/routes/app_pages.dart';

class QrcodeTransferModuleController extends GetxController {
  final box = GetStorage();
  final savedQRCodes = <Map<String, dynamic>>[].obs;

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

  void deleteSavedQRCode(int index) {
    savedQRCodes.removeAt(index);
    box.write('saved_qr_contacts', savedQRCodes.toList());
  }

  void selectSavedQRCode(Map<String, dynamic> contact) {
    Get.toNamed(
      Routes.QRCODE_TRANSFER_DETAILS_MODULE,
      arguments: {
        'username': contact['username'],
        if (contact['email'] != null && contact['email'].toString().isNotEmpty) 'email': contact['email'],
      },
    );
  }
}
