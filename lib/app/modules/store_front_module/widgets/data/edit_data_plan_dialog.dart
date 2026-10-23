import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mcd/app/modules/store_front_module/models/storefront_plan_model.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_edit_pricing_dialog.dart';

class EditDataPlanDialog extends GetView<StoreFrontController> {
  final String providerName;
  final String typeName;
  final StorefrontPlanModel plan;

  const EditDataPlanDialog({
    super.key,
    required this.providerName,
    required this.typeName,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'en_US');
    final initialSell = plan.sellPrice > 0 ? plan.sellPrice : plan.baseCost;
    final currentSell = initialSell.obs;
    final initialComm = (initialSell - plan.baseCost).clamp(0.0, double.infinity);
    final commissionText = 'Commission per sale: N${currencyFormatter.format(initialComm)}'.obs;
    final errorText = ''.obs;
    final isSaving = false.obs;

    void calculate(String val) {
      final price = double.tryParse(val.trim());
      if (price == null) {
        errorText.value = 'Please enter a valid price';
        commissionText.value = 'Invalid price';
        return;
      }
      if (price < plan.baseCost) {
        errorText.value = 'Price cannot be lower than base cost (N${currencyFormatter.format(plan.baseCost)})';
        commissionText.value = 'Price below base cost';
        return;
      }
      if (plan.maxAllowedPrice > 0 && price > plan.maxAllowedPrice) {
        errorText.value = 'Price cannot exceed max allowed (N${currencyFormatter.format(plan.maxAllowedPrice)})';
        commissionText.value = 'Price exceeds max allowed';
        return;
      }
      errorText.value = '';
      currentSell.value = price;
      final comm = (price - plan.baseCost).clamp(0.0, double.infinity);
      commissionText.value = 'Commission per sale: N${currencyFormatter.format(comm)}';
    }

    final maxPriceStr = plan.maxAllowedPrice > 0
        ? 'Between N${currencyFormatter.format(plan.baseCost)} and N${currencyFormatter.format(plan.maxAllowedPrice)}.'
        : 'Minimum price: N${currencyFormatter.format(plan.baseCost)}.';

    return SharedEditPricingDialog(
      title: plan.name,
      subtitle: maxPriceStr,
      baseCost: 'N${currencyFormatter.format(plan.baseCost)}',
      inputLabel: 'Your Sell Price (N)',
      initialInputValue: initialSell.toStringAsFixed(0),
      onChanged: calculate,
      commissionText: commissionText,
      errorText: errorText,
      isLoading: isSaving,
      onSave: () async {
        if (errorText.value.isNotEmpty) return;
        isSaving.value = true;
        final success = await controller.updatePlanPriceAndSync(
          category: 'data',
          itemCode: plan.itemCode,
          sellPrice: currentSell.value,
          isEnabled: plan.isEnabled,
          provider: providerName,
          type: typeName,
        );
        isSaving.value = false;
        if (success) {
          Get.back();
          controller.showDataPlanListDialog(providerName, typeName);
        }
      },
      onBack: () {
        Get.back();
        controller.showDataPlanListDialog(providerName, typeName);
      },
    );
  }
}
