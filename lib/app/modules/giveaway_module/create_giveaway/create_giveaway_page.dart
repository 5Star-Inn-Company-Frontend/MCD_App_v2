import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/core/import/imports.dart';

import '../giveaway_module_controller.dart';

class CreateGiveawayPage extends GetView<GiveawayModuleController> {
  const CreateGiveawayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Giveaway"),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Short Note / Description field
            TextSemiBold(
              'Short Note',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),
            const Gap(8),
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter a brief description',
                hintStyle: const TextStyle(
                  color: AppColors.primaryGrey2,
                  fontFamily: AppFonts.manRope,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),
            const Gap(16),

            // Type dropdown
            TextSemiBold(
              'Type',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffE5E5E5)),
              ),
              child: DropdownButtonHideUnderline(
                  child: Obx(
                () => DropdownButton<String>(
                  dropdownColor: AppColors.white,
                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                  borderRadius: BorderRadius.circular(8),
                  isExpanded: true,
                  value: controller.selectedType,
                  hint: Text('Type',
                      style: TextStyle(
                          fontFamily: AppFonts.manRope, color: Colors.grey)),
                  items: [
                    'airtime',
                    'data',
                    'electricity',
                    'tv',
                    'betting_topup'
                  ]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.toUpperCase().replaceAll('_', ' '),
                              style:
                                  const TextStyle(fontFamily: AppFonts.manRope),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) controller.setType(value);
                  },
                ),
              )),
            ),
            const Gap(16),

            // Network Selection (Airtime & Data)
            Obx(() => Visibility(
                  visible: controller.selectedType == 'airtime' ||
                      controller.selectedType == 'data',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSemiBold(
                        'Network',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffE5E5E5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: AppColors.white,
                            icon: Icon(Icons.keyboard_arrow_down_rounded),
                            borderRadius: BorderRadius.circular(8),
                            isExpanded: true,
                            value: controller.selectedTypeCode,
                            hint: Text('Select Network',
                                style: TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    color: Colors.grey)),
                            items: ['mtn', 'glo', 'airtel', '9mobile']
                                .map((code) => DropdownMenuItem(
                                      value: code,
                                      child: Text(
                                        code.toUpperCase(),
                                        style: const TextStyle(
                                            fontFamily: AppFonts.manRope),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) controller.setTypeCode(value);
                            },
                          ),
                        ),
                      ),
                      const Gap(16),
                    ],
                  ),
                )),

            // Data Plan Selection (Data Only)
            Obx(() => Visibility(
                  visible: controller.selectedType == 'data' &&
                      controller.selectedTypeCode != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSemiBold(
                        'Data Plan',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(8),
                      controller.isFetchingDataPlans.value
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryColor),
                            ))
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xffE5E5E5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: AppColors.white,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                                  borderRadius: BorderRadius.circular(8),
                                  isExpanded: true,
                                  value: controller.selectedDataPlanCode,
                                  hint: Text('Select Plan',
                                      style: TextStyle(
                                          fontFamily: AppFonts.manRope,
                                          color: Colors.grey)),
                                  items: controller.dataPlans
                                      .map((plan) => DropdownMenuItem(
                                            value: plan['coded'] as String?,
                                            child: Text(
                                              "${plan['name']} - ₦${plan['price']}",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) =>
                                      controller.setDataPlan(value),
                                ),
                              ),
                            ),
                      const Gap(16),
                    ],
                  ),
                )),

            // Electricity Provider Selection
            Obx(() => Visibility(
                  visible: controller.selectedType == 'electricity',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSemiBold(
                        'Provider',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(8),
                      controller.isFetchingElectricityProviders.value
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryColor),
                            ))
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xffE5E5E5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: AppColors.white,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                                  borderRadius: BorderRadius.circular(8),
                                  isExpanded: true,
                                  value: controller
                                      .selectedElectricityProviderCode,
                                  hint: Text('Select Provider',
                                      style: TextStyle(
                                          fontFamily: AppFonts.manRope,
                                          color: Colors.grey)),
                                  items: controller.electricityProviders
                                      .map((provider) => DropdownMenuItem(
                                            value: provider['code'] as String?,
                                            child: Text(
                                              provider['name'] ?? '',
                                              style: const TextStyle(
                                                  fontFamily: AppFonts.manRope),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) =>
                                      controller.setElectricityProvider(value),
                                ),
                              ),
                            ),
                      const Gap(16),
                    ],
                  ),
                )),

            // Cable TV Provider Selection
            Obx(() => Visibility(
                  visible: controller.selectedType == 'tv',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSemiBold(
                        'Provider',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffE5E5E5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Obx(() {
                            final providers =
                                controller.cableProviders.toList();
                            final items = providers.map((provider) {
                              final code = provider['code'] as String?;
                              return DropdownMenuItem<String>(
                                value: code,
                                child: Text(
                                  provider['name'] ?? '',
                                  style: const TextStyle(
                                      fontFamily: AppFonts.manRope),
                                ),
                              );
                            }).toList();

                            return DropdownButton<String>(
                              dropdownColor: AppColors.white,
                              icon: Icon(Icons.keyboard_arrow_down_rounded),
                              borderRadius: BorderRadius.circular(8),
                              isExpanded: true,
                              value: controller.selectedCableProviderCode,
                              hint: Text('Select Provider',
                                  style: TextStyle(
                                      fontFamily: AppFonts.manRope,
                                      color: Colors.grey)),
                              items: items,
                              onChanged: (value) =>
                                  controller.setCableProvider(value),
                            );
                          }),
                        ),
                      ),
                      const Gap(16),
                    ],
                  ),
                )),

            // Cable Package Selection
            Obx(() => Visibility(
                  visible: controller.selectedType == 'tv' &&
                      controller.selectedCableProvider.value != null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSemiBold(
                        'Package',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(8),
                      controller.isFetchingCablePackages.value
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryColor),
                            ))
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xffE5E5E5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: AppColors.white,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded),
                                  borderRadius: BorderRadius.circular(8),
                                  isExpanded: true,
                                  value: controller.selectedCablePackageCode,
                                  hint: Text('Select Package',
                                      style: TextStyle(
                                          fontFamily: AppFonts.manRope,
                                          color: Colors.grey)),
                                  items: controller.cablePackages
                                      .map((pkg) => DropdownMenuItem(
                                            value: pkg['coded'] as String?,
                                            child: Text(
                                              "${pkg['name']}",
                                              style: const TextStyle(
                                                  fontFamily: AppFonts.manRope,
                                                  fontSize: 12),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) =>
                                      controller.setCablePackage(value),
                                ),
                              ),
                            ),
                      const Gap(16),
                    ],
                  ),
                )),

            // Betting Provider Selection
            Obx(() => Visibility(
                  visible: controller.selectedType == 'betting_topup',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSemiBold(
                        'Provider',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        style: const TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      const Gap(8),
                      controller.isFetchingBettingProviders.value
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                  color: AppColors.primaryColor),
                            ))
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xffE5E5E5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: Obx(() {
                                  final providers =
                                      controller.bettingProviders.toList();
                                  final items = providers
                                      .map((provider) => DropdownMenuItem(
                                            value: provider['code'] as String?,
                                            child: Text(
                                              provider['name'] ?? '',
                                              style: const TextStyle(
                                                  fontFamily: AppFonts.manRope),
                                            ),
                                          ))
                                      .toList();

                                  return DropdownButton<String>(
                                    dropdownColor: AppColors.white,
                                    icon:
                                        Icon(Icons.keyboard_arrow_down_rounded),
                                    borderRadius: BorderRadius.circular(8),
                                    isExpanded: true,
                                    value:
                                        controller.selectedBettingProviderCode,
                                    hint: Text('Select Provider',
                                        style: TextStyle(
                                            fontFamily: AppFonts.manRope,
                                            color: Colors.grey)),
                                    items: items,
                                    onChanged: (value) =>
                                        controller.setBettingProvider(value),
                                  );
                                }),
                              ),
                            ),
                      // const Gap(16),
                    ],
                  ),
                )),
            const Gap(16),

            // File upload area
            TextSemiBold(
              'Upload Image',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),
            const Gap(8),
            Obx(() => InkWell(
                  onTap: controller.pickImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xffE5E5E5),
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xffFAFAFA),
                    ),
                    child: controller.selectedImage != null
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  controller.selectedImage!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Gap(12),
                              const Text(
                                'Tap to change image',
                                style: TextStyle(
                                  fontFamily: AppFonts.manRope,
                                  fontSize: 13,
                                  color: AppColors.primaryGrey2,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: AppColors.primaryGrey2,
                              ),
                              const Gap(12),
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Click here to Upload Document\n',
                                      style: TextStyle(
                                        fontFamily: AppFonts.manRope,
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'JPG, PNG (Max 5MB)',
                                      style: TextStyle(
                                        fontFamily: AppFonts.manRope,
                                        fontSize: 12,
                                        color: AppColors.primaryGrey2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                )),
            const Gap(16),

            // Amount field
            TextSemiBold(
              'Amount',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),
            const Gap(8),
            Obx(() => TextFormField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  readOnly: controller.selectedType == 'data' ||
                      controller.selectedType == 'tv',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: AppColors.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    filled: controller.selectedType == 'data' ||
                        controller.selectedType == 'tv',
                    fillColor: (controller.selectedType == 'data' ||
                            controller.selectedType == 'tv')
                        ? Colors.grey.shade100
                        : null,
                  ),
                  style: const TextStyle(fontFamily: AppFonts.manRope),
                )),
            const Gap(16),

            // Number of Users field
            TextSemiBold(
              'Number of User',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),
            const Gap(8),
            TextFormField(
              controller: controller.quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter number of users',
                hintStyle: const TextStyle(
                  color: AppColors.primaryGrey2,
                  fontFamily: AppFonts.manRope,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xffE5E5E5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primaryColor, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),

            const Gap(16),
            TextSemiBold(
              'Visibility',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              style: const TextStyle(fontFamily: AppFonts.manRope),
            ),
            const Gap(8),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.isPublic
                              ? AppColors.primaryColor.withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: controller.isPublic
                                ? AppColors.primaryColor
                                : const Color(0xffE5E5E5),
                          ),
                        ),
                        child: RadioListTile<bool>(
                          value: true,
                          groupValue: controller.isPublic,
                          onChanged: (val) => controller.setIsPublic(val!),
                          title: const Text(
                            'Public',
                            style: TextStyle(
                              fontFamily: AppFonts.manRope,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          activeColor: AppColors.primaryColor,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: !controller.isPublic
                              ? AppColors.primaryColor.withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !controller.isPublic
                                ? AppColors.primaryColor
                                : const Color(0xffE5E5E5),
                          ),
                        ),
                        child: RadioListTile<bool>(
                          value: false,
                          groupValue: controller.isPublic,
                          onChanged: (val) => controller.setIsPublic(val!),
                          title: const Text(
                            'Private',
                            style: TextStyle(
                              fontFamily: AppFonts.manRope,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          activeColor: AppColors.primaryColor,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                )),
            const Gap(28),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: BusyButton(
                    title: "Create",
                    isLoading: controller.isCreating,
                    onTap: () async {
                      await controller.createGiveaway();
                      // if (success) {
                      //   Get.back();
                      // }
                    },
                  ),
                )),
            const Gap(20),
            controller.adsService.showBannerAdWidget(),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}
