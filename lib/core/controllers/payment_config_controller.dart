import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/network/dio_api_service.dart';

class PaymentConfigController extends GetxController {
  final DioApiService apiService = DioApiService();
  final storage = GetStorage();

  final paymentMethodStatus = <String, String>{}.obs;
  final paymentMethodDetails = <String, String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedPaymentConfig();

    // always attempt background refresh if we have a URL
    final url = storage.read('transaction_service_url');
    if (url != null) {
      fetchPaymentMethods();
    }
  }

  Future<void> fetchPaymentMethods() async {
    // only show loader if we have no cached data
    if (paymentMethodStatus.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = '';
    dev.log('Fetching payment methods configuration', name: 'PaymentConfig');

    final transactionUrl = storage.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found, will retry when available', name: 'PaymentConfig');
      _loadCachedPaymentConfig();
      isLoading.value = false;
      return;
    }

    final result = await apiService.getrequest('${transactionUrl}payment-methods');

    result.fold(
      (failure) {
        dev.log('Failed to fetch payment methods', name: 'PaymentConfig', error: failure.message);
        errorMessage.value = failure.message;
        _loadCachedPaymentConfig();
      },
      (data) {
        if (data['success'] == 1 && data['data'] != null) {
          dev.log('Payment methods fetched successfully', name: 'PaymentConfig');
          
          // Store payment method status
          if (data['data']['status'] != null) {
            final status = data['data']['status'] as Map<String, dynamic>;
            paymentMethodStatus.value = status.map((key, value) => MapEntry(key, value.toString()));
            dev.log('Payment method status: $paymentMethodStatus', name: 'PaymentConfig');
          }
          
          // Store payment method details (keys, etc.)
          if (data['data']['details'] != null) {
            final details = data['data']['details'] as Map<String, dynamic>;
            paymentMethodDetails.value = details.map((key, value) => MapEntry(key, value.toString()));
            
            // Store Paystack public key
            if (details['paystack_public'] != null) {
              storage.write('paystack_public_key', details['paystack_public']);
              dev.log('Paystack public key found', name: 'PaymentConfig');
            }
            
            // Store other payment gateway keys if needed
            if (details['rave_public'] != null) {
              storage.write('rave_public_key', details['rave_public']);
            }
            if (details['rave_enckey'] != null) {
              storage.write('rave_encryption_key', details['rave_enckey']);
            }
            if (details['monnify_apikey'] != null) {
              storage.write('monnify_api_key', details['monnify_apikey']);
            }
            if (details['monnify_contractcode'] != null) {
              storage.write('monnify_contract_code', details['monnify_contractcode']);
            }
            
            dev.log('Payment gateway keys stored successfully', name: 'PaymentConfig');
          }
          
          // Cache the entire response
          storage.write('cached_payment_methods', data);
        } else {
          dev.log('Payment methods fetch failed', name: 'PaymentConfig', error: data['message']);
          errorMessage.value = data['message'] ?? 'Failed to fetch payment methods';
          _loadCachedPaymentConfig();
        }
      },
    );
 
    isLoading.value = false;
  }

  // Load cached payment configuration
  void _loadCachedPaymentConfig() {
    final cached = storage.read('cached_payment_methods');
    if (cached != null) {
      dev.log('Loading cached payment methods', name: 'PaymentConfig');
      
      if (cached['data'] != null) {
        if (cached['data']['status'] != null) {
          final status = cached['data']['status'] as Map<String, dynamic>;
          paymentMethodStatus.value = status.map((key, value) => MapEntry(key, value.toString()));
        }
        
        if (cached['data']['details'] != null) {
          final details = cached['data']['details'] as Map<String, dynamic>;
          paymentMethodDetails.value = details.map((key, value) => MapEntry(key, value.toString()));
        }
      }
      
      dev.log('Cached payment methods loaded', name: 'PaymentConfig');
    } else {
      dev.log('No cached payment methods found', name: 'PaymentConfig');
    }
  }

  // Check if a payment method is available
  bool isPaymentMethodAvailable(String method) {
    final status = paymentMethodStatus[method];
    return status == '1';
  }

  // Get Paystack public key
  String? getPaystackPublicKey() {
    return storage.read('paystack_public_key') ?? paymentMethodDetails['paystack_public'];
  }

  // Get specific payment gateway details
  String? getRavePublicKey() {
    return storage.read('rave_public_key') ?? paymentMethodDetails['rave_public'];
  }

  String? getRaveEncryptionKey() {
    return storage.read('rave_encryption_key') ?? paymentMethodDetails['rave_enckey'];
  }

  String? getMonnifyApiKey() {
    return storage.read('monnify_api_key') ?? paymentMethodDetails['monnify_apikey'];
  }

  String? getMonnifyContractCode() {
    return storage.read('monnify_contract_code') ?? paymentMethodDetails['monnify_contractcode'];
  }

  // Refresh payment methods
  @override
  Future<void> refresh() async {
    await fetchPaymentMethods();
  }
}
