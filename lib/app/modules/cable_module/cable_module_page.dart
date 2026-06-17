import 'package:flutter/services.dart';
import 'package:mcd/app/modules/cable_module/cable_module_controller.dart';
import 'package:mcd/app/modules/cable_module/model/cable_provider_model.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CableModulePage extends GetView<CableModuleController> {
  const CableModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: "Cable Tv",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => Get.toNamed(Routes.HISTORY_SCREEN),
              child: TextSemiBold("History"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              _buildProviderDropdown(context),
              const Gap(25),
              _buildSmartCardInput(),
              const Gap(50),
              BusyButton(
                title: "Proceed",
                isLoading: false,
                onTap: controller.proceedToNextScreen,
              ),
              const Gap(30),
              // SizedBox(
              //     width: double.infinity, child: Image.asset(AppAsset.banner)),
              // const Gap(20)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryGrey)),
      ),
      child: Obx(() {
        return Skeletonizer(
          enabled: controller.isLoadingProviders.value &&
              controller.cableProviders.isEmpty,
          child: controller.errorMessage.value != null
              ? Center(child: Text(controller.errorMessage.value!))
              : DropdownButtonHideUnderline(
                  child: DropdownButton<CableProvider>(
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    value: controller.selectedProvider.value,
                    items: controller.isLoadingProviders.value
                        ? [
                            DropdownMenuItem(
                              value: null,
                              child: Row(children: [
                                Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.grey[300]),
                                const Gap(30),
                                const Text("Loading Provider..."),
                              ]),
                            )
                          ]
                        : controller.cableProviders.map((provider) {
                            final imageUrl =
                                controller.providerImages[provider.name] ??
                                    controller.providerImages['DEFAULT']!;
                            return DropdownMenuItem<CableProvider>(
                              value: provider,
                              child: Row(children: [
                                Image.asset(imageUrl, width: 40),
                                const Gap(30),
                                TextSemiBold(provider.name),
                              ]),
                            );
                          }).toList(),
                    onChanged: (value) => controller.onProviderSelected(value),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    borderRadius: BorderRadius.circular(08),
                    menuWidth: screenWidth(context) * 0.9,
                    alignment: Alignment.center,
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildSmartCardInput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration:
          BoxDecoration(border: Border.all(color: const Color(0xffF1F1F1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSemiBold('Smart card Number'),
          const Gap(4),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.smartCardController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: AppFonts.manRope),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Card No needed";
                    if (value.length < 5) return "Card no not valid";
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '012345678',
                    hintStyle: TextStyle(
                        color: AppColors.primaryGrey,
                        fontFamily: AppFonts.manRope),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                ),
              ),
              const Gap(8),
              InkWell(
                onTap: () async {
                  if (controller.selectedProvider.value == null) {
                    Get.snackbar(
                      "Error",
                      "Please select a provider",
                      backgroundColor: AppColors.errorBgColor,
                      colorText: AppColors.textSnackbarColor,
                    );
                    return;
                  }

                  // Get clipboard data
                  final clipboardData = await Clipboard.getData('text/plain');
                  if (clipboardData != null &&
                      clipboardData.text != null &&
                      clipboardData.text!.isNotEmpty) {
                    controller.smartCardController.text = clipboardData.text!;

                    // Validate only, don't navigate
                    await controller.validateSmartCard();
                  } else {
                    Get.snackbar(
                      "Error",
                      "No number found in clipboard",
                      backgroundColor: AppColors.errorBgColor,
                      colorText: AppColors.textSnackbarColor,
                    );
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Paste',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.manRope,
                    ),
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
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryColor),
                    ),
                    Gap(8),
                    Text("Validating...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            if (controller.validatedCustomerName.value != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '(${controller.validatedCustomerName.value!})',
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
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
    );
  }
}
