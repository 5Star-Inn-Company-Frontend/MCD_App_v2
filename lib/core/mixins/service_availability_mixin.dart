import 'dart:developer' as dev;
import 'package:mcd/core/controllers/service_status_controller.dart';
import 'package:mcd/core/import/imports.dart';

/// Mixin to add service availability checking to controllers
mixin ServiceAvailabilityMixin {
  ServiceStatusController get _serviceStatusController => ServiceStatusController.to;

  /// Check if service is available before navigation
  /// Returns true if available, false if not (and shows dialog)
  Future<bool> checkAndNavigate(
    String serviceKey, {
    String? serviceName,
    Function? onAvailable,
    String? routeName,
  }) async {
    // if we need to fetch status over the network, show a loader
    bool needsNetworkCheck = _serviceStatusController.serviceStatus.value == null;
    
    if (needsNetworkCheck) {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );
    }

    try {
      final isAvailable = await _serviceStatusController.checkServiceAvailability(
        serviceKey,
        serviceName: serviceName,
      );

      if (needsNetworkCheck) {
        if (Get.isDialogOpen == true) {
          Get.back(); // dismiss the loader
        }
      }

      if (isAvailable) {
        if (onAvailable != null) {
          onAvailable();
        } else if (routeName != null) {
          Get.toNamed(routeName);
        }
      }

      return isAvailable;
    } catch (e) {
      if (needsNetworkCheck) {
        dev.log('Service availability check failed: $e', name: 'ServiceAvailabilityMixin');
        if (Get.isDialogOpen == true) {
          Get.back(); // dismiss the loader on error
        }
      }
      return false;
    }
  }

  /// Quick check without dialog
  bool isServiceAvailable(String serviceKey) {
    return _serviceStatusController.isServiceAvailable(serviceKey);
  }

  /// Refresh service status
  Future<void> refreshServiceStatus() async {
    await _serviceStatusController.refresh();
  }
}
