import 'package:flutter_test/flutter_test.dart';
import 'package:mcd/core/models/service_status_model.dart';

void main() {
  group('Service Status Model Tests', () {
    test('Should parse service status response correctly', () {
      final json = {
        "success": 1,
        "message": "Fetched successfully",
        "data": {
          "services": {
            "airtime": "1",
            "data": "1",
            "paytv": "0",
            "electricity": "1",
          }
        }
      };

      final model = ServiceStatusModel.fromJson(json);

      expect(model.success, 1);
      expect(model.message, 'Fetched successfully');
      expect(model.data, isNotNull);
      expect(model.data!.services.airtime, '1');
      expect(model.data!.services.data, '1');
      expect(model.data!.services.paytv, '0');
      expect(model.data!.services.electricity, '1');
    });

    test('Should check service availability correctly', () {
      final json = {
        "services": {
          "airtime": "1",
          "data": "0",
          "paytv": "1",
          "electricity": "0",
          "betting": "1",
          "rechargecard": "0",
        }
      };

      final services = Services.fromJson(json['services'] as Map<String, dynamic>);

      expect(services.isServiceAvailable('airtime'), true);
      expect(services.isServiceAvailable('data'), false);
      expect(services.isServiceAvailable('paytv'), true);
      expect(services.isServiceAvailable('cable'), true); // paytv alias
      expect(services.isServiceAvailable('electricity'), false);
      expect(services.isServiceAvailable('betting'), true);
      expect(services.isServiceAvailable('rechargecard'), false);
      expect(services.isServiceAvailable('epin'), false); // rechargecard alias
    });

    test('Should handle missing service data gracefully', () {
      final json = {
        "success": 1,
        "message": "Fetched successfully",
      };

      final model = ServiceStatusModel.fromJson(json);

      expect(model.success, 1);
      expect(model.data, isNull);
    });

    test('Should parse adverts data correctly', () {
      final json = {
        "unity_testmode": "false",
        "unity_gameid": "3717787"
      };

      final adverts = Adverts.fromJson(json);

      expect(adverts.unityTestmode, 'false');
      expect(adverts.unityGameid, '3717787');
    });

    test('Should parse others data correctly', () {
      final json = {
        "mcd_agent_phoneno": "+1 213-224-2393",
        "leaderboard": "1",
        "support_email": "test@gmail.com",
      };

      final others = Others.fromJson(json);

      expect(others.mcdAgentPhoneno, '+1 213-224-2393');
      expect(others.leaderboard, '1');
      expect(others.supportEmail, 'test@gmail.com');
    });

    test('Should handle unknown service key', () {
      final json = {
        "services": {
          "airtime": "1",
        }
      };

      final services = Services.fromJson(json);

      expect(services.isServiceAvailable('unknown_service'), false);
    });

    test('Should handle all service aliases', () {
      final json = {
        "services": {
          "paytv": "1",
          "rechargecard": "1",
        }
      };

      final services = Services.fromJson(json['services'] as Map<String, dynamic>);

      // Test aliases
      expect(services.isServiceAvailable('paytv'), true);
      expect(services.isServiceAvailable('cable'), true);
      expect(services.isServiceAvailable('rechargecard'), true);
      expect(services.isServiceAvailable('epin'), true);
    });
  });
}
