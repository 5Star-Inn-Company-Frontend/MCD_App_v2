import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/models/storefront_provider_model.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/shared_edit_pricing_dialog.dart';

class EditDiscountDialog extends GetView<StoreFrontController> {
  final StorefrontProviderModel provider;

  const EditDiscountDialog({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final commissionText = 'Your commission per sale: ${(provider.baseDiscount - provider.discountPercent).clamp(0, 100).toStringAsFixed(2)}% of amount'.obs;
    final errorText = ''.obs;
    final currentDiscount = provider.discountPercent.obs;

    void calculate(String val) {
      final discount = double.tryParse(val.trim());
      if (discount == null) {
        errorText.value = 'Please enter a valid percentage';
        commissionText.value = 'Invalid discount value';
        return;
      }
      if (discount < 0) {
        errorText.value = 'Discount cannot be negative';
        commissionText.value = 'Discount cannot be negative';
        return;
      }
      if (discount > provider.baseDiscount) {
        errorText.value = 'Discount cannot exceed our base (${provider.baseDiscount}%)';
        commissionText.value = 'Discount exceeds base cost';
        return;
      }
      errorText.value = '';
      currentDiscount.value = discount;
      final comm = (provider.baseDiscount - discount).clamp(0.0, 100.0);
      commissionText.value = 'Your commission per sale: ${comm.toStringAsFixed(2)}% of amount';
    }

    return SharedEditPricingDialog(
      title: '${provider.provider.toUpperCase()} Discount',
      subtitle: 'Set customer discount between 0% and ${provider.baseDiscount}% (our base).',
      baseCost: '${provider.baseDiscount}%',
      inputLabel: 'Customer Discount (%)',
      initialInputValue: provider.discountPercent == 0 ? '0' : provider.discountPercent.toString(),
      onChanged: calculate,
      commissionText: commissionText,
      errorText: errorText,
      onSave: () {
        if (errorText.value.isNotEmpty) return;
        controller.updateProviderToggle(
          category: 'airtime',
          provider: provider.provider,
          isEnabled: provider.isEnabled,
          discountPercent: currentDiscount.value,
        );
        Get.back();
      },
      onBack: () {
        Get.back();
        controller.showSelectProviderDialog();
      },
    );
  }
}
