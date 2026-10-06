import 'dart:convert';
import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/network/dio_api_service.dart';

class OffersService extends GetxService {
  static OffersService get to => Get.find<OffersService>();

  final DioApiService _apiService = DioApiService();
  final GetStorage _storage = GetStorage();

  final isPreviewing = false.obs;
  final offerPreviewData = Rxn<Map<String, dynamic>>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> previewOffer({
    required String product,
    required String provider,
    required String amount,
    required String offerCode,
  }) async {
    try {
      isPreviewing.value = true;
      errorMessage.value = '';
      offerPreviewData.value = null;

      dev.log('Previewing offer: $offerCode for $product', name: 'OffersService');

      final transactionUrl = _storage.read('transaction_service_url');
      if (transactionUrl == null) {
        errorMessage.value = 'Transaction URL not found';
        dev.log(errorMessage.value, name: 'OffersService');
        return;
      }

      final url = '${transactionUrl}offers/preview';
      final payload = {
        "product": product,
        "provider": provider,
        "amount": amount,
        "offer_code": offerCode,
      };

      final response = await _apiService.postrequest(url, payload);

      response.fold(
        (failure) {
          errorMessage.value = failure.message;
          dev.log('Failed to preview offer: ${failure.message}', name: 'OffersService');
        },
        (data) {
          offerPreviewData.value = data;
          dev.log('Successfully previewed offer', name: 'OffersService');
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      dev.log('Error previewing offer: $e', name: 'OffersService');
    } finally {
      isPreviewing.value = false;
    }
  }

  void clearPreview() {
    offerPreviewData.value = null;
    errorMessage.value = '';
  }
}
