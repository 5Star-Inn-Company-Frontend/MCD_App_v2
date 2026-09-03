import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_edit_pricing_dialog.dart';

class EditDiscountDialog extends GetView<StoreFrontController> {
  final String providerName;

  const EditDiscountDialog({
    super.key,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    return SharedEditPricingDialog(
      title: '$providerName Discount',
      subtitle: 'Set discount between 0% and 3%(our base).',
      baseCost: controller.mcdBaseCost,
      inputLabel: 'Discount to Price (%)',
      initialInputValue: controller.mtnDiscount.value,
      onChanged: (val) {
        controller.mtnDiscount.value = val;
      },
      commissionText: 'Your commission per sale: 1% of amount',
      onSave: () => Get.back(),
      onBack: () {
        Get.back();
        controller.showSelectProviderDialog();
      },
    );
  }
}
