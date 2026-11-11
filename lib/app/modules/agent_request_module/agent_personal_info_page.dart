import 'package:mcd/core/import/imports.dart';
import './agent_request_module_controller.dart';

class AgentPersonalInfoPage extends GetView<AgentRequestModuleController> {
  const AgentPersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Personal Information',
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: controller.personalInfoFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Name
              TextSemiBold(
                'Business Name',
                fontSize: 14,
                color: AppColors.textPrimaryColor,
              ),
              const Gap(8),
              TextFormField(
                controller: controller.businessNameController,
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontFamily: AppFonts.manRope,
                ),
                decoration: InputDecoration(
                  hintText: 'Joe accessories',
                  hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const Gap(20),

              // Street Number
              TextSemiBold(
                'Street Number',
                fontSize: 14,
                color: AppColors.textPrimaryColor,
              ),
              const Gap(8),
              TextFormField(
                controller: controller.streetNumberController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontFamily: AppFonts.manRope,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 123',
                  hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                ),
              ),
              const Gap(20),

              // Street Address
              TextSemiBold(
                'Street Address',
                fontSize: 14,
                color: AppColors.textPrimaryColor,
              ),
              const Gap(8),
              TextFormField(
                controller: controller.streetAddressController,
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontFamily: AppFonts.manRope,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Main Street',
                  hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Street address is required';
                  }
                  return null;
                },
              ),
              const Gap(20),

              // State
              TextSemiBold(
                'State',
                fontSize: 14,
                color: AppColors.textPrimaryColor,
              ),
              const Gap(8),
              TextFormField(
                controller: controller.stateController,
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontFamily: AppFonts.manRope,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Lagos',
                  hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'State is required';
                  }
                  return null;
                },
              ),
              const Gap(20),

              // Country
              TextSemiBold(
                'Country',
                fontSize: 14,
                color: AppColors.textPrimaryColor,
              ),
              const Gap(8),
              TextFormField(
                controller: controller.countryController,
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontFamily: AppFonts.manRope,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Nigeria',
                  hintStyle: const TextStyle(
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColors.primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Country is required';
                  }
                  return null;
                },
              ),
              const Gap(40),

              // Submit Button
              Center(
                child: Obx(() => BusyButton(
                      title: 'Submit',
                      onTap: controller.submitAgentRequest,
                      width: screenWidth(context) * 0.8,
                      disabled: !controller.isPersonalInfoFormValid.value ||
                          controller.isSubmitting.value,
                    )),
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
