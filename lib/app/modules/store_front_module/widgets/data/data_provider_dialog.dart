import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_provider_selection_dialog.dart';

class DataProviderDialog extends GetView<StoreFrontController> {
  const DataProviderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedProviderSelectionDialog(
      title: 'Data — Select provider',
      description: 'Choose a network/provider to edit its pricing.',
      providers: [
        ProviderItemConfig(
          name: 'MTN',
          subtitle: 'Tap to edit Discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.mtnDataEnabled,
          onToggle: (val) => controller.toggleDataProvider('mtn', val),
          onTap: () => controller.showDataTypeDialog('MTN'),
        ),
        ProviderItemConfig(
          name: 'Glo',
          subtitle: 'Tap to edit Discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.gloDataEnabled,
          onToggle: (val) => controller.toggleDataProvider('glo', val),
          onTap: () => controller.showDataTypeDialog('Glo'),
        ),
        ProviderItemConfig(
          name: 'Airtel',
          subtitle: 'Tap to edit Discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.airtelDataEnabled,
          onToggle: (val) => controller.toggleDataProvider('airtel', val),
          onTap: () => controller.showDataTypeDialog('Airtel'),
        ),
        ProviderItemConfig(
          name: '9mobile',
          subtitle: 'Tap to edit Discount setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.etisalatDataEnabled,
          onToggle: (val) => controller.toggleDataProvider('9mobile', val),
          onTap: () => controller.showDataTypeDialog('9mobile'),
        ),
      ],
    );
  }
}
