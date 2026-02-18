import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/electricity_module/model/electricity_provider_model.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/core/constants/fonts.dart';
import './electricity_module_controller.dart';

class ElectricityModulePage extends GetView<ElectricityModuleController> {
  const ElectricityModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: "Electricity",
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => Get.toNamed(Routes.HISTORY_SCREEN),
              child: TextSemiBold("History", fontWeight: FontWeight.w700, fontSize: 16),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderDropdown(),
                const Gap(25),
                _buildFormFields(),
                const Gap(25),
                // TextSemiBold("Select Amount"),
                // const Gap(14),
                _buildAmountGrid(context),
                const Gap(40),
                Obx(() => BusyButton(
                  title: "Pay",
                  isLoading: controller.isPaying.value,
                  onTap: controller.pay,
                )),
                const Gap(20),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildProviderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryGrey)),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor,));
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        return DropdownButtonHideUnderline(
        child: DropdownButton2<ElectricityProvider>(
          isExpanded: true,
          value: controller.selectedProvider.value,
          items: controller.electricityProviders.map((provider) {
            final imageUrl = controller.providerImages[provider.name] ?? controller.providerImages['DEFAULT']!;
            return DropdownMenuItem<ElectricityProvider>(
              value: provider,
              child: Row(children: [
                Image.asset(imageUrl, width: 40, height: 40),
                const Gap(30),
                Text(provider.name, style: const TextStyle(fontFamily: AppFonts.manRope)),
              ]),
            );
          }).toList(),
          onChanged: (value) => controller.onProviderSelected(value),
          dropdownStyleData: DropdownStyleData(
            elevation: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,)
          ),
          iconStyleData: const IconStyleData(
                icon: Icon(Icons.keyboard_arrow_down),
              ),
        ),
      );}),
    );
  }

  Widget _buildFormFields() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSemiBold('Payment Item', fontSize: 14),
          const Gap(8),
          Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              value: controller.selectedPaymentType.value,
              items: controller.paymentTypes
                  .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: const TextStyle(fontFamily: AppFonts.manRope)),
                    ))
                  .toList(),
              onChanged: (value) => controller.onPaymentTypeSelected(value),
              buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.keyboard_arrow_down),
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,)
              ),
            ),
          )),
          const Divider(),
          const Gap(8),
          TextSemiBold('Meter Number', fontSize: 14),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: controller.meterNoController,
                  style: const TextStyle(fontFamily: AppFonts.manRope),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Meter No needed";
                    if (value.length < 5) return "Meter no not valid";
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '012345678',
                    hintStyle: TextStyle(fontFamily: AppFonts.manRope, color: Colors.grey[400]),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const Gap(8),
              InkWell(
                onTap: () {
                  if (controller.meterNoController.text.isNotEmpty && 
                      controller.selectedProvider.value != null) {
                    controller.validateMeterNumber();
                  } else {
                    Get.snackbar(
                      "Error", 
                      "Please enter meter number and select provider", 
                      backgroundColor: AppColors.errorBgColor, 
                      colorText: AppColors.textSnackbarColor,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          Obx(() {
            if (controller.isValidating.value) {
              return const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                    ),
                    Gap(8),
                    Text("Validating...", style: TextStyle(color: Colors.grey, fontFamily: AppFonts.manRope)),
                  ],
                ),
              );
            }
            if (controller.validatedCustomerName.value != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '(${controller.validatedCustomerName.value!})',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.manRope,
                    fontSize: 14,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildAmountGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // GridView(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 3,
          //     mainAxisSpacing: 10,
          //     crossAxisSpacing: 10,
          //     childAspectRatio: 2.5,
          //   ),
          //   children: [
          //     _amountCard('0.00'), _amountCard('0.00'), _amountCard('0.00'),
          //     _amountCard('0.00'), _amountCard('0.00'), _amountCard('0.00'),
          //   ],
          // ),
          const Gap(15),
          Obx(() => Row(
            children: [
              Text("₦", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w500)),
              const Gap(8),
              Expanded(
                child: TextFormField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Amount needed";
                    final amount = double.tryParse(value);
                    if (amount == null) return "Invalid amount";
                    
                    // Check minimum amount if available
                    if (controller.minimumAmount.value != null && amount < controller.minimumAmount.value!) {
                      return "Minimum amount is ₦${controller.minimumAmount.value!.toStringAsFixed(2)}";
                    }
                    return null;
                  },
                  style: const TextStyle(
                    fontFamily: AppFonts.manRope,
                  ),
                  decoration: InputDecoration(
                    hintText: controller.minimumAmount.value != null 
                        ? '${controller.minimumAmount.value!.toStringAsFixed(2)} - 50,000.00'
                        : '500.00 - 50,000.00',
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.manRope,
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: const UnderlineInputBorder(),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                  ),
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  // Widget _amountCard(String amount) {
  //   return TouchableOpacity(
  //     onTap: () => controller.onAmountSelected(amount),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: AppColors.primaryColor,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Center(
  //         child: Text(
  //           '₦$amount',
  //           style: const TextStyle(
  //             color: AppColors.white,
  //             fontFamily: AppFonts.manRope,
  //             fontSize: 14,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}