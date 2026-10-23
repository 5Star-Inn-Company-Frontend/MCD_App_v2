import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_provider_selection_dialog.dart';

class ProviderSelectionDialog extends GetView<StoreFrontController> {
  const ProviderSelectionDialog({super.key});

  String _getAsset(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('mtn')) return 'assets/images/mtn.png';
    if (lower.contains('glo')) return 'assets/images/glo.png';
    if (lower.contains('airtel')) return 'assets/images/airtel.png';
    if (lower.contains('9mobile') || lower.contains('etisalat')) return 'assets/images/etisalat.png';
    return 'assets/icons/storefront/phone.png';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.airtimeProviders.map((p) {
        return ProviderItemConfig(
          name: p.provider.toUpperCase(),
          subtitle: 'Base ${p.baseDiscount}% · Sell discount ${p.discountPercent}%',
          imageAsset: _getAsset(p.provider),
          isEnabled: p.isEnabled,
          onToggle: (val) {
            controller.updateProviderToggle(
              category: 'airtime',
              provider: p.provider,
              isEnabled: val,
              discountPercent: p.discountPercent,
            );
          },
          onTap: () => controller.showEditDiscountDialog(p),
        );
      }).toList();

      return SharedProviderSelectionDialog(
        title: 'Airtime — Select Provider',
        description: 'Choose a network to configure your discount & profit.',
        isLoading: controller.isLoadingAirtime.value,
        providers: items,
      );
    });
  }
}
