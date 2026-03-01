import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/modules/ussd_topup_module/ussd_topup_module_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/core/constants/fonts.dart';

class UssdTopupModulePage extends GetView<UssdTopupModuleController> {
  const UssdTopupModulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'USSD Top-up',
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.hasVirtualAccount.value) {
            return _buildKycPrompt();
          }
          return _buildFormView();
        }),
      ),
    );
  }

  Widget _buildKycPrompt() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                    const Gap(8),
                    Expanded(
                      child: TextSemiBold(
                        "Complete KYC to Use USSD Top-up",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(12),
                TextSemiBold(
                  "You need to complete your KYC verification to get a dedicated bank account for USSD top-up.",
                  fontSize: 14,
                  color: AppColors.primaryGrey2,
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.KYC_UPDATE_MODULE),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: TextSemiBold(
                      "Complete KYC Verification",
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your bank and the amount to generate a USSD code quickly',
              style: TextStyle(
                fontFamily: AppFonts.manRope,
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const Gap(24),

            // Bank Selection
            TextSemiBold(
              'Select Bank',
              fontSize: 14,
              color: AppColors.primaryGrey2,
            ),
            const SizedBox(height: 8),
            Obx(() => InkWell(
                  onTap: () => _showBankSelectionBottomSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryGrey2.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.selectedBank.value,
                          style: TextStyle(
                            fontFamily: AppFonts.manRope,
                            fontSize: 14,
                            color:
                                controller.selectedBank.value == 'Choose bank'
                                    ? AppColors.primaryGrey2.withOpacity(0.5)
                                    : Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.primaryGrey2,
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 20),

            // Amount
            TextSemiBold(
              'Enter Amount',
              fontSize: 14,
              color: AppColors.primaryGrey2,
            ),
            const Gap(8),
            TextFormField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontFamily: AppFonts.manRope),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: TextStyle(
                    fontFamily: AppFonts.manRope,
                    color: AppColors.primaryGrey2.withOpacity(0.5)),
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
                      const BorderSide(color: AppColors.primaryColor, width: 2),
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
            const SizedBox(height: 40),

            // Generate Button
            Obx(() => BusyButton(
                  title: 'Generate USSD Code',
                  isLoading: controller.isGeneratingCode.value,
                  onTap: () => controller.generateCode(),
                )),
            const SizedBox(height: 30),

            // Generated Code Section
            Obx(() {
              if (controller.generatedCode.value.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: AppColors.primaryGrey2.withOpacity(0.2),
                    thickness: 1,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 24,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextBold(
                              'Code Generated!',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            const Gap(4),
                            TextSemiBold(
                              'Dial the code below to complete top-up',
                              fontSize: 12,
                              color: AppColors.primaryGrey2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // USSD Code Display
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            controller.generatedCode.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              letterSpacing: 2,
                              fontFamily: AppFonts.manRope,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => controller.copyCode(),
                          icon: const Icon(Icons.copy, size: 20),
                          label: const Text(
                            'Copy Code',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.manRope,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryColor,
                            side: const BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.dialCode(),
                          icon: const Icon(Icons.phone, size: 20),
                          label: const Text(
                            'Dial Code',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.manRope,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: TextButton.icon(
                      onPressed: () => controller.clearGeneratedCode(),
                      icon: const Icon(Icons.close, size: 18),
                      label: TextSemiBold(
                        'Clear Code',
                        fontSize: 13,
                        color: AppColors.primaryGrey2,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGrey2,
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBankSelectionBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primaryGrey2.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextBold(
                    'Select Bank',
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.bankSearchController,
                onChanged: (value) => controller.bankSearchQuery = value,
                decoration: InputDecoration(
                  hintText: 'Search banks...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primaryGrey2.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.primaryGrey2.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Banks List
            Expanded(
              child: Obx(() {
                if (controller.isLoadingBanks.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                final banks = controller.filteredBanks;

                if (banks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppColors.primaryGrey2.withOpacity(0.5),
                        ),
                        const Gap(16),
                        TextSemiBold(
                          'No banks found',
                          fontSize: 14,
                          color: AppColors.primaryGrey2,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: banks.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.primaryGrey2.withOpacity(0.2),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final bank = banks[index];
                    return ListTile(
                      onTap: () => controller.selectBank(
                        bank['name'] as String,
                        bank['code'] as String,
                        bank['ussdTemplate'] as String?,
                        bank['baseUssdCode'] as String?,
                      ),
                      title: TextSemiBold(
                        bank['name'] as String,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      subtitle: bank['ussdTemplate'] != null
                          ? Text(
                              'USSD: ${bank['baseUssdCode'] ?? bank['ussdTemplate']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryGrey2.withOpacity(0.7),
                                fontFamily: AppFonts.manRope,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.primaryGrey2,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
