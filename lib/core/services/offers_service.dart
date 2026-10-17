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

  final isFetchingFeaturedOffer = false.obs;
  final featuredOfferData = Rxn<Map<String, dynamic>>();

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

      final baseUrl = transactionUrl.toString().endsWith('/')
          ? transactionUrl.toString()
          : '$transactionUrl/';
      final url = '${baseUrl}offers/preview';
      final payload = {
        "product": product,
        "provider": provider,
        "amount": amount,
        "offer_code": offerCode,
      };

      final response = await _apiService.postrequest(url, payload);

      response.fold(
        (failure) {
          offerPreviewData.value = null;
          errorMessage.value = failure.message;
          dev.log('Failed to preview offer: ${failure.message}', name: 'OffersService');
        },
        (data) {
          if (data is Map<String, dynamic>) {
            final dynamic successVal = data['success'];
            final dynamic statusVal = data['status'];
            final bool isSuccess = successVal == 1 ||
                successVal == '1' ||
                successVal == true ||
                statusVal == true ||
                statusVal == 'success' ||
                statusVal == 1;

            final String msg = (data['message'] ?? data['error'] ?? '').toString();
            final String lowerMsg = msg.toLowerCase();
            final bool hasFailureKeyword = lowerMsg.contains('not qualify') ||
                lowerMsg.contains('invalid') ||
                lowerMsg.contains('failed') ||
                lowerMsg.contains('cannot use') ||
                lowerMsg.contains('not found') ||
                lowerMsg.contains('expired');

            if (isSuccess && !hasFailureKeyword) {
              offerPreviewData.value = data;
              errorMessage.value = '';
              dev.log('Successfully previewed offer', name: 'OffersService');
            } else {
              offerPreviewData.value = null;
              errorMessage.value = msg.isNotEmpty
                  ? msg
                  : 'Your transaction does not qualify for this offer.';
              dev.log('Offer rejected: ${errorMessage.value}', name: 'OffersService');
            }
          } else {
            offerPreviewData.value = null;
            errorMessage.value = 'Invalid response from offer service';
          }
        },
      );
    } catch (e) {
      errorMessage.value = e.toString();
      offerPreviewData.value = null;
      dev.log('Error previewing offer: $e', name: 'OffersService');
    } finally {
      isPreviewing.value = false;
    }
  }

  void clearPreview() {
    offerPreviewData.value = null;
    errorMessage.value = '';
  }

  Future<void> fetchFeaturedOffer() async {
    try {
      await Future.microtask(() => isFetchingFeaturedOffer.value = true);
      final transactionUrlV2 = _storage.read('transaction_service_url');
      if (transactionUrlV2 == null) {
        dev.log('Transaction URL v2 not found', name: 'OffersService');
        return;
      }
      final url = '${transactionUrlV2}offers/featured';
      final response = await _apiService.getrequest(url);
      response.fold(
        (failure) {
          dev.log('Failed to fetch featured offer: ${failure.message}', name: 'OffersService');
        },
        (data) {
          featuredOfferData.value = data;
          dev.log('Successfully fetched featured offer: $data', name: 'OffersService');
        },
      );
    } catch (e) {
      dev.log('Error fetching featured offer: $e', name: 'OffersService');
    } finally {
      Future.microtask(() => isFetchingFeaturedOffer.value = false);
    }
  }

  // --- OTHER OFFER ENDPOINTS ---

  Future<dynamic> fetchEligibleOffers() async {
    try {
      final transactionUrlV2 = _storage.read('transaction_service_url');
      if (transactionUrlV2 == null) return null;
      
      final url = '${transactionUrlV2}offers/eligible';
      final response = await _apiService.getrequest(url);
      
      return response.fold(
        (failure) {
          dev.log('Failed to fetch eligible offers: ${failure.message}', name: 'OffersService');
          return null;
        },
        (data) => data,
      );
    } catch (e) {
      dev.log('Error fetching eligible offers: $e', name: 'OffersService');
      return null;
    }
  }

  Future<dynamic> fetchAllOffers() async {
    try {
      final transactionUrlV2 = _storage.read('transaction_service_url');
      if (transactionUrlV2 == null) return null;
      
      final url = '${transactionUrlV2}offers';
      final response = await _apiService.getrequest(url);
      
      return response.fold(
        (failure) {
          dev.log('Failed to fetch all offers: ${failure.message}', name: 'OffersService');
          return null;
        },
        (data) => data,
      );
    } catch (e) {
      dev.log('Error fetching all offers: $e', name: 'OffersService');
      return null;
    }
  }

  Future<dynamic> fetchOfferByCode(String code) async {
    try {
      final transactionUrlV2 = _storage.read('transaction_service_url');
      if (transactionUrlV2 == null) return null;
      
      final url = '${transactionUrlV2}offers/$code';
      final response = await _apiService.getrequest(url);
      
      return response.fold(
        (failure) {
          dev.log('Failed to fetch offer by code: ${failure.message}', name: 'OffersService');
          return null;
        },
        (data) => data,
      );
    } catch (e) {
      dev.log('Error fetching offer by code: $e', name: 'OffersService');
      return null;
    }
  }

  Future<dynamic> fetchOffersHistory() async {
    try {
      final transactionUrlV2 = _storage.read('transaction_service_url');
      if (transactionUrlV2 == null) return null;
      
      final url = '${transactionUrlV2}user/offers/history';
      final response = await _apiService.getrequest(url);
      
      return response.fold(
        (failure) {
          dev.log('Failed to fetch offers history: ${failure.message}', name: 'OffersService');
          return null;
        },
        (data) => data,
      );
    } catch (e) {
      dev.log('Error fetching offers history: $e', name: 'OffersService');
      return null;
    }
  }

  Future<dynamic> validateOffer({
    required String product,
    required String provider,
    required String amount,
    required String offerId, // Updated to offerId based on validation error
  }) async {
    try {
      final transactionUrlV2 = _storage.read('transaction_service_url');
      if (transactionUrlV2 == null) return null;
      
      final url = '${transactionUrlV2}offers/validate';
      final payload = {
        "product": product,
        "provider": provider,
        "amount": amount,
        "offer_id": offerId,
      };
      
      final response = await _apiService.postrequest(url, payload);
      
      return response.fold(
        (failure) {
          dev.log('Failed to validate offer: ${failure.message}', name: 'OffersService');
          return null;
        },
        (data) => data,
      );
    } catch (e) {
      dev.log('Error validating offer: $e', name: 'OffersService');
      return null;
    }
  }
}
