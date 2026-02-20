import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/betting_module/model/betting_provider_model.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import './betting_module_controller.dart';

class BettingModulePage extends GetView<BettingModuleController> {
  const BettingModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: "Betting",
        elevation: 0,
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: AppColors.primaryColor,
            color: AppColors.primaryColor,
          ));
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: AppColors.primaryGrey)),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: _buildProviderDropdown(),
                        ),
                      ],
                    ),
                  ),
                  const Gap(30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xffE0E0E0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "User ID",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.manRope),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.userIdController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    fontFamily: AppFonts.manRope),
                                decoration: const InputDecoration(
                                  hintText: 'Enter User ID',
                                  hintStyle: TextStyle(
                                      color: AppColors.primaryGrey,
                                      fontFamily: AppFonts.manRope),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.primaryColor),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(8),
                            InkWell(
                              onTap: () {
                                if (controller
                                        .userIdController.text.isNotEmpty &&
                                    controller.selectedProvider.value != null) {
                                  controller.validateUser();
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter user ID and select provider",
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
                          if (controller.isPaying.value) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryColor),
                                  ),
                                  Gap(8),
                                  Text("Validating...",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          }
                          if (controller.validatedUserName.value != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 16),
                                  const Gap(4),
                                  Expanded(
                                    child: Text(
                                      controller.validatedUserName.value!,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                  const Gap(25),
                  TextSemiBold("Deposit Amount"),
                  const Gap(14),
                  Container(
                    height: screenHeight(context) * 0.23,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffF1F1F1))),
                    child: Column(
                      children: [
                        Flexible(
                          child: GridView(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 3 / 1.3,
                            ),
                            children: [
                              _amountCard('₦500.00'),
                              _amountCard('₦1000.00'),
                              _amountCard('₦2000.00'),
                              _amountCard('₦5000.00'),
                              _amountCard('₦10000.00'),
                              _amountCard('₦20000.00'),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text("₦",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15, fontWeight: FontWeight.w500)),
                            const Gap(8),
                            Flexible(
                              child: TextFormField(
                                controller: controller.amountController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.plusJakartaSans(),
                                decoration: InputDecoration(
                                  hintText: '500.00 - 50,000.00',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primaryGrey,
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.primaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(30),
                  BusyButton(
                    title: "Proceed",
                    onTap: controller.pay,
                  ),
                  const Gap(30),
                  // SizedBox(width: double.infinity, child: Image.asset(AppAsset.banner)),
                  // const Gap(20)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProviderDropdown() {
    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 6),
      // decoration: const BoxDecoration(
      //   border: Border(bottom: BorderSide(color: AppColors.primaryGrey)),
      // ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BettingProvider>(
          isExpanded: true,
          dropdownColor: Colors.white,
          itemHeight: 60,
          items: controller.bettingProviders
              .map((provider) => DropdownMenuItem<BettingProvider>(
                    value: provider,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.primaryGrey.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              controller.providerImages[provider.name] ??
                                  controller.providerImages['DEFAULT']!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Gap(16),
                          Expanded(
                            child: TextSemiBold(
                              provider.name,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          value: controller.selectedProvider.value,
          onChanged: (value) => controller.onProviderSelected(value),
          icon: const Icon(Icons.keyboard_arrow_down),
          borderRadius: BorderRadius.circular(12),
          alignment: Alignment.center,
          menuMaxHeight: screenHeight(Get.context!) * 0.7,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }

  Widget _amountCard(String amount, {bool isFirst = false}) {
    final raw = amount.replaceAll('₦', '').replaceAll(',', '').trim();
    final value = double.tryParse(raw) ?? 0.0;
    final label = AmountUtil.formatAmountToNaira(value);

    return Obx(() {
      final isSelected = controller.selectedAmount.value == label;
      return InkWell(
        onTap: () => controller.onAmountSelected(label),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primaryColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? AppColors.white : AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    });
  }
}
