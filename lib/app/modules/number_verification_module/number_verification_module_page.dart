import '../../../core/import/imports.dart';
import './number_verification_module_controller.dart';

class NumberVerificationModulePage
    extends GetView<NumberVerificationModuleController> {
  const NumberVerificationModulePage({super.key});

  String _getNetworkLogo(String network) {
    final normalized = network.toLowerCase();
    if (normalized.contains('mtn')) {
      return 'assets/images/mtn.png';
    } else if (normalized.contains('airtel')) {
      return 'assets/images/airtel.png';
    } else if (normalized.contains('glo')) {
      return 'assets/images/glo.png';
    } else if (normalized.contains('9mobile') ||
        normalized.contains('etisalat')) {
      return 'assets/images/etisalat.png';
    }
    return 'assets/images/mtn.png'; // default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: "Verify Phone Number",
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(30),
              TextSemiBold(
                "Enter Phone Number",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const Gap(8),
              TextSemiBold(
                controller.isForeign && controller.countryName != null
                    ? "Please enter the ${controller.countryName} phone number${controller.callingCode != null && controller.callingCode!.isNotEmpty ? ' (${controller.callingCode})' : ''} you want to verify for this transaction."
                    : "Please enter the phone number you want to verify for this transaction.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const Gap(20),
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontFamily: AppFonts.manRope,
                ),
                decoration: textInputDecoration.copyWith(
                  hintText: controller.isForeign
                      ? "Enter phone number"
                      : "Enter 11-digit phone number",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontFamily: AppFonts.manRope,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryGrey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.content_paste,
                            color: AppColors.primaryColor),
                        onPressed: controller.pasteFromClipboard,
                        tooltip: 'Paste',
                      ),
                      IconButton(
                        icon: const Icon(Icons.contacts,
                            color: AppColors.primaryColor),
                        onPressed: controller.pickContact,
                        tooltip: 'Select Contact',
                      ),
                    ],
                  ),
                ),
                onChanged: controller.onPhoneInputChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!controller.isForeign) {
                    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digits.length < 11) {
                      return 'Please enter a valid 11-digit phone number';
                    }
                  }
                  return null;
                },
              ),
              const Gap(40),
              Obx(() => BusyButton(
                    title: "Verify Number",
                    onTap: controller.verifyNumber,
                    isLoading: controller.isLoading.value,
                  )),

              // beneficiaries section
              Obx(() {
                if (controller.isLoadingBeneficiaries.value) {
                  return Column(
                    children: [
                      const Gap(30),
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  );
                }

                final filtered = controller.filteredBeneficiaries;
                if (filtered.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(30),
                    TextSemiBold(
                      "Beneficiaries",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    const Gap(15),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Gap(16),
                        itemBuilder: (context, index) {
                          final beneficiary = filtered[index];
                          final phone = beneficiary['phone']?.toString() ?? '';
                          final network = beneficiary['network']?.toString() ?? '';
                          return GestureDetector(
                            onTap: () => controller.selectBeneficiary(beneficiary),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Image.asset(
                                        _getNetworkLogo(network),
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.phone_android,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: AppFonts.manRope,
                                    color: AppColors.background,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),

              // recent verified numbers - replaced by beneficiaries
              // Obx(() {
              //   if (controller.recentNumbers.isEmpty) {
              //     return const SizedBox.shrink();
              //   }
              //   return Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Gap(30),
              //       TextSemiBold(
              //         "Recent",
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //       ),
              //       const Gap(15),
              //       SizedBox(
              //         height: 100,
              //         child: ListView.separated(
              //           scrollDirection: Axis.horizontal,
              //           itemCount: controller.recentNumbers.length,
              //           separatorBuilder: (_, __) => const Gap(16),
              //           itemBuilder: (context, index) {
              //             final item = controller.recentNumbers[index];
              //             final phone = item['phone'] ?? '';
              //             final network = item['network'] ?? '';
              //             return GestureDetector(
              //               onTap: () => controller.selectRecentNumber(item),
              //               child: Column(
              //                 children: [
              //                   Container(
              //                     width: 56,
              //                     height: 56,
              //                     child: ClipOval(
              //                       child: Padding(
              //                         padding: const EdgeInsets.all(8),
              //                         child: Image.asset(
              //                           _getNetworkLogo(network),
              //                           fit: BoxFit.contain,
              //                           errorBuilder: (_, __, ___) => Icon(
              //                             Icons.phone_android,
              //                             color: Colors.white,
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                   const Gap(8),
              //                   Text(
              //                     phone,
              //                     style: TextStyle(
              //                       fontSize: 11,
              //                       fontFamily: AppFonts.manRope,
              //                       color: AppColors.background,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //             );
              //           },
              //         ),
              //       ),
              //     ],
              //   );
              // }),

              const Spacer(),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryColor),
                    Gap(10),
                    Expanded(
                      child: Text(
                        "We'll verify your number before proceeding with the transaction.",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 13,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }
}
