import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UsageTrackerService extends GetxService {
  static UsageTrackerService get to => Get.find();
  final GetStorage _box = GetStorage();
  final String _storageKey = 'service_usage_counts';

  final RxMap<String, int> usageCounts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUsageCounts();
  }

  void _loadUsageCounts() {
    final Map<String, dynamic>? storedCounts = _box.read<Map<String, dynamic>>(_storageKey);
    if (storedCounts != null) {
      usageCounts.value = storedCounts.map((key, value) => MapEntry(key, value as int));
    } else {
      // default initial usage for the most common services to show them first
      usageCounts.value = {
        'Data': 4,
        'Airtime': 3,
        'Electricity': 2,
        'Betting': 1,
      };
      _saveUsageCounts();
    }
  }

  void _saveUsageCounts() {
    _box.write(_storageKey, usageCounts);
  }

  void incrementUsage(String serviceKey) {
    if (usageCounts.containsKey(serviceKey)) {
      usageCounts[serviceKey] = (usageCounts[serviceKey] ?? 0) + 1;
    } else {
      usageCounts[serviceKey] = 1;
    }
    _saveUsageCounts();
  }

  int getUsage(String serviceKey) {
    return usageCounts[serviceKey] ?? 0;
  }
}
