import 'package:flutter_test/flutter_test.dart';
import 'package:mcd/core/models/service_status_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Remote Config Logic & Key Normalization Tests', () {
    test('Service status model checks correctly with server data', () {
      final json = {
        "services": {
          "airtime": "1",
          "data": "0",
          "paytv": "1",
          "electricity": "0",
          "betting": "1",
        }
      };

      final services = Services.fromJson(json['services'] as Map<String, dynamic>);

      expect(services.isServiceAvailable('airtime'), true);
      expect(services.isServiceAvailable('data'), false);
      expect(services.isServiceAvailable('paytv'), true);
      expect(services.isServiceAvailable('cable'), true);
      expect(services.isServiceAvailable('electricity'), false);
      expect(services.isServiceAvailable('betting'), true);
    });

    test('Key normalizer maps aliases and preserves ads keys', () {
      final defaults = {
        'service_airtime': true,
        'service_paytv': true,
        'service_rechargecard': true,
        'ads_bannerlist': false,
        'ads_showrepeat': false,
      };

      String normalizeServiceKey(String key) {
        String cleanKey = key.toLowerCase().trim();
        if (cleanKey == 'cable' || cleanKey == 'paytv') {
          cleanKey = 'paytv';
        } else if (cleanKey == 'epin' || cleanKey == 'rechargecard') {
          cleanKey = 'rechargecard';
        }

        if (defaults.containsKey(cleanKey) ||
            cleanKey.startsWith('ads_') ||
            cleanKey.startsWith('payment_') ||
            cleanKey.startsWith('service_')) {
          return cleanKey;
        }

        final prefixed = 'service_$cleanKey';
        if (defaults.containsKey(prefixed)) {
          return prefixed;
        }

        return cleanKey;
      }

      expect(normalizeServiceKey('airtime'), 'service_airtime');
      expect(normalizeServiceKey('cable'), 'service_paytv');
      expect(normalizeServiceKey('paytv'), 'service_paytv');
      expect(normalizeServiceKey('epin'), 'service_rechargecard');
      expect(normalizeServiceKey('rechargecard'), 'service_rechargecard');
      expect(normalizeServiceKey('service_electricity'), 'service_electricity');
      expect(normalizeServiceKey('ads_bannerlist'), 'ads_bannerlist');
      expect(normalizeServiceKey('ads_showrepeat'), 'ads_showrepeat');
    });

    test('Key normalizer maps payment method keys to proper remote config keys', () {
      String normalizePaymentKey(String method) {
        String cleanKey = method.toLowerCase().trim();
        if (cleanKey == 'general_market' || cleanKey == 'pay_gm') {
          cleanKey = 'general_market';
        }

        if (cleanKey.startsWith('payment_')) {
          return cleanKey;
        }
        return 'payment_$cleanKey';
      }

      expect(normalizePaymentKey('paystack'), 'payment_paystack');
      expect(normalizePaymentKey('monnify'), 'payment_monnify');
      expect(normalizePaymentKey('general_market'), 'payment_general_market');
      expect(normalizePaymentKey('pay_gm'), 'payment_general_market');
      expect(normalizePaymentKey('payment_bank_transfer'), 'payment_bank_transfer');
    });
  });
}
