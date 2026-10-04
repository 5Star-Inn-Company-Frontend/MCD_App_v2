import 'dart:developer' as dev;
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:mcd/core/services/ads_service.dart';

enum BannerFilterType { all, high, low }

class BannerItemModel {
  final String id;
  final String title;
  final BannerFilterType type;

  BannerItemModel({
    required this.id,
    required this.title,
    required this.type,
  });
}

class BannerListModuleController extends GetxController {
  final AdsService adsService = AdsService();

  final selectedFilter = BannerFilterType.all.obs;
  final highBannerCount = 3.obs;
  final lowBannerCount = 3.obs;

  // Refresh key to force rebuilding of ad widgets
  final refreshKey = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _enableWakelock();
  }

  @override
  void onClose() {
    _disableWakelock();
    super.onClose();
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
      dev.log('Wakelock enabled for BannerListModule', name: 'Wakelock');
    } catch (e) {
      dev.log('Failed to enable wakelock: $e', name: 'Wakelock');
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
      dev.log('Wakelock disabled for BannerListModule', name: 'Wakelock');
    } catch (e) {
      dev.log('Failed to disable wakelock: $e', name: 'Wakelock');
    }
  }

  void setFilter(BannerFilterType filter) {
    selectedFilter.value = filter;
  }

  void incrementHighBanners() {
    highBannerCount.value++;
  }

  void decrementHighBanners() {
    if (highBannerCount.value > 1) {
      highBannerCount.value--;
    }
  }

  void incrementLowBanners() {
    lowBannerCount.value++;
  }

  void decrementLowBanners() {
    if (lowBannerCount.value > 1) {
      lowBannerCount.value--;
    }
  }

  void refreshBanners() {
    refreshKey.value++;
    Get.snackbar(
      'Refreshing Banners',
      'Banner ads have been reloaded.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  List<BannerItemModel> get bannerItems {
    final List<BannerItemModel> list = [];

    final filter = selectedFilter.value;

    if (filter == BannerFilterType.all || filter == BannerFilterType.high) {
      for (int i = 1; i <= highBannerCount.value; i++) {
        list.add(
          BannerItemModel(
            id: 'high_$i',
            title: 'High Banner Ad #$i',
            type: BannerFilterType.high,
          ),
        );
      }
    }

    if (filter == BannerFilterType.all || filter == BannerFilterType.low) {
      for (int i = 1; i <= lowBannerCount.value; i++) {
        list.add(
          BannerItemModel(
            id: 'low_$i',
            title: 'Low Banner Ad #$i',
            type: BannerFilterType.low,
          ),
        );
      }
    }

    // Interleave when 'all' is selected for a balanced layout
    if (filter == BannerFilterType.all) {
      final List<BannerItemModel> interleaved = [];
      int highIdx = 0;
      int lowIdx = 0;
      final highItems = list.where((e) => e.type == BannerFilterType.high).toList();
      final lowItems = list.where((e) => e.type == BannerFilterType.low).toList();

      while (highIdx < highItems.length || lowIdx < lowItems.length) {
        if (highIdx < highItems.length) {
          interleaved.add(highItems[highIdx++]);
        }
        if (lowIdx < lowItems.length) {
          interleaved.add(lowItems[lowIdx++]);
        }
      }
      return interleaved;
    }

    return list;
  }
}
