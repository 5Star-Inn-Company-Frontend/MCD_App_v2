import 'package:get/get.dart';
import 'package:mcd/core/controllers/service_status_controller.dart';

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
    final isAvailable = await _serviceStatusController.checkServiceAvailability(
      serviceKey,
      serviceName: serviceName,
    );

    if (isAvailable) {
      if (onAvailable != null) {
        onAvailable();
      } else if (routeName != null) {
        Get.toNamed(routeName);
      }
    }

    return isAvailable;
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
