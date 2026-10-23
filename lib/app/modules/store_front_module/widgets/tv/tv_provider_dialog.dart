import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_provider_selection_dialog.dart';

class TvProviderDialog extends GetView<StoreFrontController> {
  const TvProviderDialog({super.key});

  String _getAsset(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('dstv')) return 'assets/images/dstv.jpeg';
    if (lower.contains('gotv')) return 'assets/images/gotv.png';
    if (lower.contains('startimes')) return 'assets/images/startimes.jpeg';
    return 'assets/icons/storefront/phone.png';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.tvProviders.map((p) {
        return ProviderItemConfig(
          name: p.provider.toUpperCase(),
          subtitle: 'Tap to view and edit packages',
          imageAsset: _getAsset(p.provider),
          isEnabled: p.isEnabled,
          onToggle: (val) {
            controller.updateProviderToggle(
              category: 'cabletv',
              provider: p.provider,
              isEnabled: val,
              discountPercent: p.discountPercent,
            );
          },
          onTap: () => controller.showTvPlanListDialog(p.provider),
        );
      }).toList();

      return SharedProviderSelectionDialog(
        title: 'Cable TV — Select Provider',
        description: 'Choose a TV provider to edit package prices.',
        isLoading: controller.isLoadingTv.value,
        providers: items,
      );
    });
  }
}
