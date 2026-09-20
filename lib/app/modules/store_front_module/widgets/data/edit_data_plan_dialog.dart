import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_edit_pricing_dialog.dart';

class EditDataPlanDialog extends GetView<StoreFrontController> {
  final String providerName;
  final String typeName;
  final String planName;

  const EditDataPlanDialog({
    super.key,
    required this.providerName,
    required this.typeName,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return SharedEditPricingDialog(
      title: '$providerName $typeName $planName',
      subtitle: 'Between N350 and N420.',
      baseCost: controller.mcdDataBaseCost,
      inputLabel: 'Your sell price (N)',
      initialInputValue: controller.dataSellPrice.value,
      onChanged: (val) {
        controller.dataSellPrice.value = val;
      },
      commissionText: 'Commission per sale: N50',
      onSave: () => Get.back(),
      onBack: () {
        Get.back();
        controller.showDataPlanListDialog(providerName, typeName);
      },
    );
  }
}
