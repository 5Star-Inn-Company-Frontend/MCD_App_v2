import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/airtime_module/model/airtime_provider_model.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import '../../../core/import/imports.dart';
import './airtime_module_controller.dart';

class AirtimeModulePage extends GetView<AirtimeModuleController> {
  const AirtimeModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: controller.isForeign ? "Foreign Airtime" : "Airtime",
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => Get.toNamed(Routes.HISTORY_SCREEN),
              child: TextSemiBold("History",
                  fontWeight: FontWeight.w700, fontSize: 16),
            ),
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(15),

                // Animated toggle between Single and Multiple Airtime
                Obx(() => Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: controller.isSingleAirtime.value
                                ? 0
                                : MediaQuery.of(context).size.width * 0.5 - 15,
                            right: controller.isSingleAirtime.value
                                ? MediaQuery.of(context).size.width * 0.5 - 15
                                : 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.isSingleAirtime.value = true;
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          fontFamily: AppFonts.manRope,
                                          fontSize: 14,
                                          fontWeight:
                                              controller.isSingleAirtime.value
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                          color:
                                              controller.isSingleAirtime.value
                                                  ? AppColors.white
                                                  : AppColors.primaryGrey2,
                                        ),
                                        child: const Text('Single Airtime'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    controller.isSingleAirtime.value = false;
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          fontFamily: AppFonts.manRope,
                                          fontSize: 14,
                                          fontWeight:
                                              !controller.isSingleAirtime.value
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                          color:
                                              !controller.isSingleAirtime.value
                                                  ? AppColors.white
                                                  : AppColors.primaryGrey2,
                                        ),
                                        child: const Text('Multiple Airtime'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),

                const Gap(25),

                // Animated content switcher
                Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: controller.isSingleAirtime.value
                          ? _buildSingleAirtimeForm(context)
                          : _buildMultipleAirtimeForm(context),
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSingleAirtimeForm(BuildContext context) {
    return Column(
      key: const ValueKey('single'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.primaryGrey)),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: Obx(() {
                  if (controller.isLoading) {
                    return const SizedBox(
                      height: 40,
                      child: Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      )),
                    );
                  }

                  if (controller.errorMessage != null) {
                    return SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          "Failed to load",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton2<AirtimeProvider>(
                      isExpanded: true,
                      iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              size: 30)),
                      items: controller.airtimeProviders
                          .map((provider) => DropdownMenuItem<AirtimeProvider>(
                                value: provider,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      controller
                                          .getProviderLogo(provider.network),
                                      width: 30,
                                      height: 30,
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Text(
                                        provider.network.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: AppFonts.manRope,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      value: controller.selectedProvider.value,
                      onChanged: (value) =>
                          controller.onProviderSelected(value),
                      buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          height: 40,
                          width: 140),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 70,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        elevation: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                width: 3,
                height: 30,
                decoration: const BoxDecoration(color: AppColors.primaryGrey),
              ),
              Flexible(
                flex: 4,
                child: TextFormField(
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return ("Pls input phone number");
                    }
                    // Only enforce 11-digit validation for Nigerian numbers
                    if (!controller.isForeign && value.length != 11) {
                      return ("Pls Input valid 11-digit number");
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  style: TextStyle(
                    fontFamily: AppFonts.manRope,
                  ),
                  decoration: textInputDecoration.copyWith(
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Image.asset(
                            'assets/icons/contact-person-icon.png',
                            width: 24,
                            height: 24),
                        onPressed: controller.pickContact,
                      )),
                  controller: controller.phoneController,
                ),
              ),
            ],
          ),
        ),

        const Gap(50),

        //bonus container
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        //   decoration: BoxDecoration(
        //     color: const Color(0xffF3FFF7),
        //     border: Border.all(color: AppColors.primaryColor),
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text("Bonus ₦10", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500)),
        //       Container(
        //         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        //         decoration: BoxDecoration(
        //             color: AppColors.primaryColor,
        //             borderRadius: BorderRadius.circular(5)),
        //         child: TextSemiBold("Claim", color: AppColors.white),
        //       )
        //     ],
        //   ),
        // ),

        // const Gap(25),
        TextSemiBold("Select Amount"),
        const Gap(14),

        // amounts container
        Container(
          height: screenHeight(context) * 0.24,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          decoration:
              BoxDecoration(border: Border.all(color: const Color(0xffF1F1F1))),
          child: Column(
            children: [
              Flexible(
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3 / 1.3,
                  ),
                  children: [
                    _amountCard('100'),
                    _amountCard('200'),
                    _amountCard('500'),
                    _amountCard('1000'),
                    _amountCard('2000'),
                    _amountCard('5000'),
                  ],
                ),
              ),
              Row(
                children: [
                  Text("₦",
                      style:
                          GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500)),
                  const Gap(8),
                  Flexible(
                    child: Obx(() {
                      final provider = controller.selectedProvider.value;
                      final minAmount = provider?.minAmount;
                      final maxAmount = provider?.maxAmount;
                      String hintText = '500.00 - 50,000.00';
                      if (minAmount != null && maxAmount != null) {
                        hintText = '${minAmount.toStringAsFixed(2)} - ${maxAmount.toStringAsFixed(2)}';
                      } else if (minAmount != null) {
                        hintText = 'Min: ${minAmount.toStringAsFixed(2)}';
                      } else if (maxAmount != null) {
                        hintText = 'Max: ${maxAmount.toStringAsFixed(2)}';
                      }
                      
                      return TextFormField(
                        controller: controller.amountController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return ("Pls input amount");
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return ("Enter a valid amount");
                          }
                          if (minAmount != null && amount < minAmount) {
                            return ("Amount must be at least ${minAmount.toStringAsFixed(0)}");
                          }
                          if (maxAmount != null && amount > maxAmount) {
                            return ("Amount must not exceed ${maxAmount.toStringAsFixed(0)}");
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontFamily: AppFonts.manRope,
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(color: AppColors.primaryGrey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryColor),
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ],
          ),
        ),

        const Gap(40),
        Obx(() => BusyButton(
              title: "Pay",
              onTap: controller.pay,
              isLoading: controller.isPaying,
            )),
        const Gap(30),
        // SizedBox(width: double.infinity, child: Image.asset(AppAsset.banner)),
        // const Gap(20)
      ],
    );
  }

  Widget _buildMultipleAirtimeForm(BuildContext context) {
    return Column(
      key: const ValueKey('multiple'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone number input with Verify button
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.primaryGrey)),
          ),
          child: Row(
            children: [
              Flexible(
                flex: 2,
                child: Obx(() {
                  if (controller.isLoading) {
                    return const SizedBox(
                      height: 40,
                      child: Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      )),
                    );
                  }

                  if (controller.errorMessage != null) {
                    return SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          "Failed to load",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton2<AirtimeProvider>(
                      isExpanded: true,
                      iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              size: 30)),
                      items: controller.airtimeProviders
                          .map((provider) => DropdownMenuItem<AirtimeProvider>(
                                value: provider,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      controller
                                          .getProviderLogo(provider.network),
                                      width: 30,
                                      height: 30,
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Text(
                                        provider.network.toUpperCase(),
                                        style: const TextStyle(
                                          fontFamily: AppFonts.manRope,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                      value: controller.selectedProvider.value,
                      onChanged: (value) =>
                          controller.onProviderSelected(value),
                      buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          height: 40,
                          width: 140),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 70,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        elevation: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                width: 3,
                height: 30,
                decoration: const BoxDecoration(color: AppColors.primaryGrey),
              ),
              Flexible(
                flex: 4,
                child: Obx(() => TextFormField(
                      enabled: !controller.isNumberVerified.value,
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => controller.onPhoneNumberChanged(),
                      decoration: textInputDecoration.copyWith(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          hintText: '08156995030',
                          suffixIcon: IconButton(
                            icon: Image.asset(
                                'assets/icons/contact-person-icon.png',
                                width: 24,
                                height: 24),
                            onPressed: controller.isNumberVerified.value
                                ? null
                                : controller.pickContact,
                          )),
                      controller: controller.phoneController,
                    )),
              ),
            ],
          ),
        ),

        // Inline verification status and Verify button
        Obx(() {
          if (controller.isVerifying.value) {
            // show verifying spinner
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryColor),
                  ),
                  const Gap(8),
                  Text(
                    'Verifying number...',
                    style: TextStyle(
                      fontFamily: AppFonts.manRope,
                      color: AppColors.primaryGrey2,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          } else if (controller.isNumberVerified.value) {
            // show verified status with edit button
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const Gap(8),
                  Text(
                    'Verified as ${controller.verifiedNetwork.value}',
                    style: TextStyle(
                      fontFamily: AppFonts.manRope,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      controller.isNumberVerified.value = false;
                      controller.verifiedNetwork.value = '';
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // show verify button
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: controller.verifyNumberInline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primaryColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: TextSemiBold('Verify Number',
                      color: AppColors.primaryColor, fontSize: 13),
                ),
              ),
            );
          }
        }),

        const Gap(15),
        TextSemiBold("Select Amount"),
        const Gap(14),

        // amounts container - disabled when not verified
        Obx(() => Opacity(
              opacity: controller.isNumberVerified.value ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !controller.isNumberVerified.value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffF1F1F1))),
                  child: Column(
                    children: [
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.5,
                        ),
                        children: [
                          _amountCard('100'),
                          _amountCard('200'),
                          _amountCard('500'),
                          _amountCard('1000'),
                          _amountCard('2000'),
                          _amountCard('5000'),
                        ],
                      ),
                      Row(
                        children: [
                          Text("₦",
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          const Gap(8),
                          Flexible(
                            child: Obx(() {
                              final provider = controller.selectedProvider.value;
                              final minAmount = provider?.minAmount;
                              final maxAmount = provider?.maxAmount;
                              String hintText = 'Custom amount';
                              if (minAmount != null && maxAmount != null) {
                                hintText = '${minAmount.toStringAsFixed(0)} - ${maxAmount.toStringAsFixed(0)}';
                              } else if (minAmount != null) {
                                hintText = 'Min: ${minAmount.toStringAsFixed(0)}';
                              } else if (maxAmount != null) {
                                hintText = 'Max: ${maxAmount.toStringAsFixed(0)}';
                              }
                              
                              return TextFormField(
                                controller: controller.amountController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  fontFamily: AppFonts.manRope,
                                ),
                                decoration: InputDecoration(
                                  hintText: hintText,
                                  hintStyle: TextStyle(
                                      color: AppColors.primaryGrey,
                                      fontFamily: AppFonts.manRope),
                                  focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryColor),
                          ),
                                ),
                              );
                            }),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )),

        const Gap(24),

        // Add button - only enabled when verified
        Obx(() => SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.isNumberVerified.value
                    ? controller.addToMultipleList
                    : null,
                icon: Icon(Icons.add_circle_outline,
                    color: controller.isNumberVerified.value
                        ? AppColors.primaryColor
                        : AppColors.primaryGrey),
                label: TextSemiBold('Add',
                    color: controller.isNumberVerified.value
                        ? AppColors.primaryColor
                        : AppColors.primaryGrey),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(
                      color: controller.isNumberVerified.value
                          ? AppColors.primaryColor
                          : AppColors.primaryGrey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            )),

        const Gap(20),

        // Multiple airtime list
        Obx(() {
          if (controller.multipleAirtimeList.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.list_alt,
                        size: 40, color: AppColors.primaryGrey2),
                    const Gap(10),
                    Text(
                      'You can add upto 5 number',
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                        color: AppColors.primaryGrey2,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextSemiBold(
                      'Added Numbers (${controller.multipleAirtimeList.length})'),
                  Text(
                    '₦${AmountUtil.formatFigure(controller.multipleAirtimeList.fold<double>(0, (sum, item) => sum + double.parse(item['amount'])))}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              const Gap(15),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.multipleAirtimeList.length,
                separatorBuilder: (_, __) => const Gap(10),
                itemBuilder: (context, index) {
                  final item = controller.multipleAirtimeList[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          item['networkImage'],
                          width: 35,
                          height: 35,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['phoneNumber'],
                                style: const TextStyle(
                                  fontFamily: AppFonts.manRope,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '₦${AmountUtil.formatFigure(double.tryParse(item['amount'].toString()) ?? 0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppColors.primaryGrey2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              controller.removeFromMultipleList(index),
                          icon: const Icon(Icons.close,
                              color: Colors.red, size: 20),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }),

        const Gap(30),
        Obx(() => BusyButton(
              title: "Pay",
              onTap: controller.payMultiple,
              isLoading: controller.isPaying,
            )),
        const Gap(20),
      ],
    );
  }

  Widget _amountCard(String amount) {
    return TouchableOpacity(
      onTap: () {
        HapticFeedback.lightImpact();
        controller.onAmountSelected(amount);
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xffF1F1F1))),
        child: Center(
          child: Text('₦$amount',
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.white, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
