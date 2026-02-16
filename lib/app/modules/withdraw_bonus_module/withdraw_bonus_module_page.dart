import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import './withdraw_bonus_module_controller.dart';

class WithdrawBonusModulePage extends GetView<WithdrawBonusModuleController> {
  const WithdrawBonusModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PaylonyAppBarTwo(
        title: 'Withdraw Bonus',
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              Get.toNamed('/history_screen');
            },
            child: TextSemiBold(
              'History',
              fontSize: 15,
              // color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Wallet Section
              TextSemiBold(
                'Select wallet',
                fontSize: 14,
                color: AppColors.primaryGrey2,
              ),
              const Gap(8),
              Obx(() => InkWell(
                    onTap: () => _showWalletSelector(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: AppColors.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextSemiBold(
                                controller.selectedWallet.value,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              const Gap(4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₦',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryGrey2,
                                      ),
                                    ),
                                    TextSpan(
                                      text: controller.selectedWalletBalance,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryGrey2,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  )),

              const Gap(24),

              // Select Amount Section
              TextSemiBold(
                'Select Amount',
                fontSize: 14,
                color: AppColors.primaryGrey2,
              ),
              const Gap(12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                ),
                itemCount: controller.quickAmounts.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => controller
                        .setQuickAmount(controller.quickAmounts[index]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₦',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                            TextSpan(
                              text: controller.quickAmounts[index],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // const Gap(24),

              // Amount Input with range hint
              // Row(
              //   children: [
              //     RichText(
              //       text: TextSpan(
              //         text: '₦',
              //         style: GoogleFonts.plusJakartaSans(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.black87,
              //         ),
              //       ),
              //     ),
              //     const Gap(8),
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           TextFormField(
              //             controller: controller.amountController,
              //             keyboardType: TextInputType.number,
              //             inputFormatters: [
              //               FilteringTextInputFormatter.digitsOnly,
              //             ],
              //             decoration: InputDecoration(
              //               hintText: '500.00 - 50, 000.00',
              //               hintStyle: TextStyle(
              //                 color: AppColors.primaryGrey2.withOpacity(0.4),
              //                 fontSize: 14,
              //                 fontFamily: 'Manrope',
              //               ),
              //               border: InputBorder.none,
              //               enabledBorder: InputBorder.none,
              //               focusedBorder: InputBorder.none,
              //               isDense: true,
              //               contentPadding: EdgeInsets.zero,
              //             ),
              //             style: const TextStyle(
              //               fontSize: 14,
              //               color: Colors.black87,
              //               fontFamily: 'Manrope',
              //             ),
              //             validator: (value) {
              //               if (value == null || value.isEmpty) {
              //                 return 'Please enter amount';
              //               }
              //               final amount = double.tryParse(value);
              //               if (amount == null || amount <= 0) {
              //                 return 'Enter a valid amount';
              //               }
              //               if (amount < 500 || amount > 50000) {
              //                 return 'Amount must be between ₦500 and ₦50,000';
              //               }
              //               return null;
              //             },
              //           ),
              //           const Gap(4),
              //           Container(
              //             height: 1,
              //             color: AppColors.primaryGrey2.withOpacity(0.3),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),

              const Gap(32),

              // Select Bank Section
              TextSemiBold(
                'Select bank',
                fontSize: 14,
                color: AppColors.primaryGrey2,
              ),
              const Gap(8),
              Obx(() => InkWell(
                    onTap: () => _showBankSelectionBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primaryGrey2.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextSemiBold(
                            controller.selectedBank.value,
                            fontSize: 14,
                            color:
                                controller.selectedBank.value == 'Choose bank'
                                    ? AppColors.primaryGrey2.withOpacity(0.5)
                                    : Colors.black,
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: AppColors.primaryGrey2,
                          ),
                        ],
                      ),
                    ),
                  )),

              const Gap(24),

              // Account Number Section
              TextSemiBold(
                'Enter Account Number',
                fontSize: 14,
                color: AppColors.primaryGrey2,
              ),
              const Gap(8),
              TextFormField(
                controller: controller.accountNumberController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'Manrope',
                ),
                decoration: InputDecoration(
                  hintText: 'Enter account number',
                  hintStyle: TextStyle(
                    color: AppColors.primaryGrey2.withOpacity(0.5),
                    fontSize: 14,
                    fontFamily: 'Manrope',
                  ),
                  counterText: '',
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
                    borderSide:
                        BorderSide(color: AppColors.primaryColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 10) {
                    controller.validateAccountNumber();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length != 10) {
                    return 'Account number must be 10 digits';
                  }
                  return null;
                },
              ),

              const Gap(16),

              // Validated Name Display
              Obx(() {
                if (controller.isValidatingAccount.value) {
                  return Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const Gap(8),
                      TextSemiBold(
                        'Validating account...',
                        fontSize: 13,
                        color: AppColors.primaryGrey2,
                      ),
                    ],
                  );
                }

                if (controller.accountNameController.text.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                        const Gap(8),
                        Expanded(
                          child: TextSemiBold(
                            controller.accountNameController.text,
                            fontSize: 13,
                            color: AppColors.primaryGrey2,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return TextSemiBold(
                  '(validated name will appear here)',
                  fontSize: 13,
                  color: AppColors.primaryGrey2.withOpacity(0.5),
                );
              }),

              const Gap(40),

              // Confirm & Send Button
              Obx(() => BusyButton(
                    title: 'Confirm & Send',
                    onTap: controller.confirmAndWithdraw,
                    isLoading: controller.isWithdrawing.value,
                    disabled: controller.isWithdrawing.value,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showBankSelectionBottomSheet(BuildContext context) {
    // Reset search when opening modal
    controller.bankSearchQuery = '';
    controller.bankSearchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextSemiBold(
                    'Select Bank',
                    fontSize: 18,
                    color: AppColors.primaryColor,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Gap(16),

              // Search Field
              TextFormField(
                controller: controller.bankSearchController,
                onChanged: (value) {
                  controller.bankSearchQuery = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search bank...',
                  hintStyle: TextStyle(
                    color: AppColors.primaryGrey2.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primaryGrey2,
                  ),
                  filled: true,
                  fillColor: AppColors.primaryGrey2.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const Gap(16),

              Obx(() {
                if (controller.isLoadingBanks.value) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.banks.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: TextSemiBold(
                        'No banks available',
                        fontSize: 14,
                        color: AppColors.primaryGrey2,
                      ),
                    ),
                  );
                }

                final filteredBanks = controller.filteredBanks;

                if (filteredBanks.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: TextSemiBold(
                        'No banks found',
                        fontSize: 14,
                        color: AppColors.primaryGrey2,
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: filteredBanks.length,
                    itemBuilder: (context, index) {
                      final bank = filteredBanks[index];
                      return InkWell(
                        onTap: () {
                          controller.selectedBank.value = bank['name']!;
                          controller.selectedBankCode.value = bank['code']!;
                          controller.accountNameController
                              .clear(); // Clear validated name on bank change
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.primaryGrey2.withOpacity(0.2),
                              ),
                            ),
                          ),
                          child: TextSemiBold(
                            bank['name']!,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showWalletSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: TextSemiBold(
            'Select Wallet',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => InkWell(
                    onTap: () =>
                        controller.selectWallet('Mega Bonus', 'mega_bonus'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            controller.selectedWalletType.value == 'mega_bonus'
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primaryGrey2.withOpacity(0.2),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextSemiBold(
                                'Mega Bonus',
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              const Gap(4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₦',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryGrey2,
                                      ),
                                    ),
                                    TextSpan(
                                      text: controller.megaBonusBalance.value
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryGrey2,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (controller.selectedWalletType.value ==
                              'mega_bonus')
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  )),
              Obx(() => InkWell(
                    onTap: () =>
                        controller.selectWallet('Commission', 'commission'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            controller.selectedWalletType.value == 'commission'
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextSemiBold(
                                'Commission',
                                fontSize: 15,
                                color: Colors.black,
                              ),
                              const Gap(4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₦',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryGrey2,
                                      ),
                                    ),
                                    TextSpan(
                                      text: controller.commissionBalance.value
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primaryGrey2,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (controller.selectedWalletType.value ==
                              'commission')
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primaryColor,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
