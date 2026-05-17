import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/modules/card_topup_module/card_topup_module_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/core/constants/fonts.dart';

class CardTopupModulePage extends GetView<CardTopupModuleController> {
  const CardTopupModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Card Top up',
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                TextSemiBold(
                  'Enter your card details and the amount to top up your wallet',
                  fontSize: 14,
                  color: AppColors.background,
                ),
                const Gap(30),

                // Card Number
                TextSemiBold(
                  'Card Number',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(8),
                TextFormField(
                  controller: controller.cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19, // 16 digits + 3 spaces
                  style: TextStyle(fontFamily: AppFonts.manRope),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0000  0000  0000  0000',
                    hintStyle: TextStyle(
                      color: AppColors.primaryGrey2.withOpacity(0.4),
                      fontFamily: AppFonts.manRope,
                    ),
                    counterText: '',
                    suffixIcon: Obx(() {
                      if (controller.cardType.value == 'visa') {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/icons/visa.png',
                            width: 40,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return TextBold(
                                'VISA',
                                fontSize: 12,
                                color: AppColors.primaryColor,
                              );
                            },
                          ),
                        );
                      } else if (controller.cardType.value == 'mastercard') {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextBold(
                            'MC',
                            fontSize: 12,
                            color: AppColors.primaryColor,
                          ),
                        );
                      } else if (controller.cardType.value == 'verve') {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/icons/verve.png',
                            width: 40,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return TextBold(
                                'VERVE',
                                fontSize: 12,
                                color: AppColors.primaryColor,
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: AppColors.primaryGrey2.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: AppColors.primaryGrey2.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  focusNode: controller.cardNumberFocus,
                  onChanged: (value) {
                    if (value.replaceAll(' ', '').length >= 16) {
                      controller.cardNameFocus.requestFocus();
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    final cleaned = value.replaceAll(' ', '');
                    if (cleaned.length < 16) {
                      return 'Card number must be 16 digits';
                    }
                    return null;
                  },
                ),
                const Gap(20),

                // Card Name
                TextSemiBold(
                  'Card Name',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(8),
                TextFormField(
                  controller: controller.cardNameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(fontFamily: AppFonts.manRope),
                  decoration: InputDecoration(
                    hintText: 'Enter card name',
                    hintStyle: TextStyle(
                      color: AppColors.primaryGrey2.withOpacity(0.4),
                      fontFamily: AppFonts.manRope,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: AppColors.primaryGrey2.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: AppColors.primaryGrey2.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  focusNode: controller.cardNameFocus,
                  onFieldSubmitted: (_) =>
                      controller.expiryMonthFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card name';
                    }
                    return null;
                  },
                ),
                const Gap(20),

                // Exp Month, Year and CCV Row
                Row(
                  children: [
                    // Exp Month
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextSemiBold(
                            'Month',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          const Gap(8),
                          TextFormField(
                            controller: controller.expiryMonthController,
                            focusNode: controller.expiryMonthFocus,
                            onChanged: (value) {
                              if (value.length >= 2) {
                                controller.expiryYearFocus.requestFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: TextStyle(fontFamily: AppFonts.manRope),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            decoration: InputDecoration(
                              hintText: 'MM',
                              hintStyle: TextStyle(
                                color: AppColors.primaryGrey2.withOpacity(0.4),
                                fontFamily: AppFonts.manRope,
                              ),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: AppColors.primaryGrey2
                                        .withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: AppColors.primaryGrey2
                                        .withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final month = int.tryParse(value);
                              if (month == null || month < 1 || month > 12) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),

                    // Exp Year
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextSemiBold(
                            'Year',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          const Gap(8),
                          TextFormField(
                            controller: controller.expiryYearController,
                            focusNode: controller.expiryYearFocus,
                            onChanged: (value) {
                              if (value.length >= 2) {
                                controller.cvvFocus.requestFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            maxLength: 2,
                            style: TextStyle(fontFamily: AppFonts.manRope),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            decoration: InputDecoration(
                              hintText: 'YY',
                              hintStyle: TextStyle(
                                color: AppColors.primaryGrey2.withOpacity(0.4),
                                fontFamily: AppFonts.manRope,
                              ),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: AppColors.primaryGrey2
                                        .withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: AppColors.primaryGrey2
                                        .withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 2) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(12),

                    // CCV
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextSemiBold(
                            'CVV',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          const Gap(8),
                          TextFormField(
                            controller: controller.cvvController,
                            focusNode: controller.cvvFocus,
                            onChanged: (value) {
                              if (value.length >= 3) {
                                controller.amountFocus.requestFocus();
                              }
                            },
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                            style: TextStyle(fontFamily: AppFonts.manRope),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: InputDecoration(
                              hintText: '***',
                              hintStyle: TextStyle(
                                color: AppColors.primaryGrey2.withOpacity(0.4),
                                fontFamily: AppFonts.manRope,
                              ),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: AppColors.primaryGrey2
                                        .withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: AppColors.primaryGrey2
                                        .withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.primaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 3) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(20),

                // Amount
                TextSemiBold(
                  'Amount',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(8),
                TextFormField(
                  controller: controller.amountController,
                  focusNode: controller.amountFocus,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontFamily: AppFonts.manRope),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      color: AppColors.primaryGrey2.withOpacity(0.4),
                      fontFamily: AppFonts.manRope,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: AppColors.primaryGrey2.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: AppColors.primaryGrey2.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                const Gap(80),

                // Top up Button
                Obx(() => BusyButton(
                      title: 'Top up',
                      isLoading: controller.isLoading.value,
                      onTap: () => controller.processTopup(),
                    )),
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Card Number Formatter
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('  ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
