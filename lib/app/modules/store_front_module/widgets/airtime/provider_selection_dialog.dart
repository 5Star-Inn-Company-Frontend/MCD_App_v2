import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_provider_selection_dialog.dart';

class ProviderSelectionDialog extends GetView<StoreFrontController> {
  const ProviderSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedProviderSelectionDialog(
      title: 'Select Provider',
      description: 'Choose a network/provider to edit its pricing.',
      providers: [
        ProviderItemConfig(
          name: 'MTN',
          subtitle: 'Tap to edit discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.mtnEnabled,
          onToggle: (val) => controller.toggleProvider('mtn', val),
          onTap: () => controller.showEditDiscountDialog('MTN'),
        ),
        ProviderItemConfig(
          name: 'Glo',
          subtitle: 'Tap to edit discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.gloEnabled,
          onToggle: (val) => controller.toggleProvider('glo', val),
          onTap: () => controller.showEditDiscountDialog('Glo'),
        ),
        ProviderItemConfig(
          name: 'Airtel',
          subtitle: 'Tap to edit discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.airtelEnabled,
          onToggle: (val) => controller.toggleProvider('airtel', val),
          onTap: () => controller.showEditDiscountDialog('Airtel'),
        ),
        ProviderItemConfig(
          name: '9mobile',
          subtitle: 'Tap to edit discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.etisalatEnabled,
          onToggle: (val) => controller.toggleProvider('9mobile', val),
          onTap: () => controller.showEditDiscountDialog('9mobile'),
        ),
      ],
    );
  }
}
