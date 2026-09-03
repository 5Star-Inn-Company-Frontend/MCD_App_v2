import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_edit_pricing_dialog.dart';

class EditTvPlanDialog extends GetView<StoreFrontController> {
  final String providerName;
  final String planName;

  const EditTvPlanDialog({
    super.key,
    required this.providerName,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return SharedEditPricingDialog(
      title: '$providerName $planName',
      subtitle: 'Between N15,700 and N17,270',
      baseCost: controller.mcdTvBaseCost,
      inputLabel: 'Your sell price (N)',
      initialInputValue: controller.tvSellPrice.value,
      onChanged: (val) {
        controller.tvSellPrice.value = val;
      },
      commissionText: 'Commission per sale: N300',
      onSave: () => Get.back(),
      onBack: () {
        Get.back();
        controller.showTvPlanListDialog(providerName);
      },
    );
  }
}
