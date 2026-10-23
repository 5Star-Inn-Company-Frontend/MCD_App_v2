import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/styles/app_colors.dart';

class SharedEditPricingDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String baseCost;
  final String inputLabel;
  final String initialInputValue;
  final ValueChanged<String>? onChanged;
  final RxString commissionText;
  final RxString? errorText;
  final VoidCallback onSave;
  final VoidCallback onBack;
  final RxBool? isLoading;

  const SharedEditPricingDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.baseCost,
    required this.inputLabel,
    required this.initialInputValue,
    this.onChanged,
    required this.commissionText,
    this.errorText,
    required this.onSave,
    required this.onBack,
    this.isLoading,
  });

  @override
  State<SharedEditPricingDialog> createState() => _SharedEditPricingDialogState();
}

class _SharedEditPricingDialogState extends State<SharedEditPricingDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialInputValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.boxColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textPrimaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textPrimaryColor2,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MCD base cost',
                      style: TextStyle(
                        color: AppColors.textPrimaryColor2,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      widget.baseCost,
                      style: const TextStyle(
                        color: AppColors.textPrimaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.inputLabel,
                style: const TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineBorder(
                    borderSide: const BorderSide(color: AppColors.filledBorderIColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineBorder(
                    borderSide: const BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 8),
              Obx(() {
                final hasError = widget.errorText != null && widget.errorText!.value.isNotEmpty;
                final text = hasError ? widget.errorText!.value : widget.commissionText.value;
                return Text(
                  text,
                  style: TextStyle(
                    color: hasError ? AppColors.errorBgColor : AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: hasError ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }),
              const SizedBox(height: 32),
              Obx(() {
                final isBusy = widget.isLoading?.value ?? false;
                final hasError = widget.errorText != null && widget.errorText!.value.isNotEmpty;
                return ElevatedButton(
                  onPressed: (isBusy || hasError) ? null : widget.onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.filledBorderIColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: AppColors.textPrimaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutlineBorder extends OutlineInputBorder {
  const OutlineBorder({
    super.borderSide,
    super.borderRadius,
  });
}
