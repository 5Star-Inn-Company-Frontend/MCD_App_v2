import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_provider_selection_dialog.dart';

class TvProviderDialog extends GetView<StoreFrontController> {
  const TvProviderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedProviderSelectionDialog(
      title: 'Cable Tv — Select provider',
      description: 'Choose a network/provider to edit its pricing.',
      providers: [
        ProviderItemConfig(
          name: 'DStv',
          subtitle: 'Tap to edit plan setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.dstvEnabled,
          onToggle: (val) => controller.toggleTvProvider('dstv', val),
          onTap: () => controller.showTvPlanListDialog('DStv'),
        ),
        ProviderItemConfig(
          name: 'GOtv',
          subtitle: 'Tap to edit plan setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.gotvEnabled,
          onToggle: (val) => controller.toggleTvProvider('gotv', val),
          onTap: () => controller.showTvPlanListDialog('GOtv'),
        ),
        ProviderItemConfig(
          name: 'Startimes',
          subtitle: 'Tap to edit plan setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.startimesEnabled,
          onToggle: (val) => controller.toggleTvProvider('startimes', val),
          onTap: () => controller.showTvPlanListDialog('Startimes'),
        ),
        ProviderItemConfig(
          name: 'Showmax',
          subtitle: 'Tap to edit plan setting',
          imageAsset: 'assets/icons/storefront/phone.png',
          isEnabled: controller.showmaxEnabled,
          onToggle: (val) => controller.toggleTvProvider('showmax', val),
          onTap: () => controller.showTvPlanListDialog('Showmax'),
        ),
      ],
    );
  }
}
