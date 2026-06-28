import 'package:flutter/services.dart';
import 'package:mcd/core/import/imports.dart';
import './kyc_update_module_controller.dart';

class KycUpdateModulePage extends GetView<KycUpdateModuleController> {
  const KycUpdateModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Kindly provide your KYC",
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        // Show loading while initializing
        if (controller.isLoading.value &&
            controller.identifierController.text.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // if (controller.isBvnVerified.value) {
        //   return _buildAlreadyVerifiedView(context);
        // }
        return _buildVerificationForm(context);
      }),
    );
  }

  Widget _buildAlreadyVerifiedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const Gap(24),
            TextBold(
              'Already Verified',
              fontSize: 24,
            ),
            const Gap(12),
            TextSemiBold(
              'Your BVN has already been verified. You have completed your KYC requirements.',
              textAlign: TextAlign.center,
              fontSize: 16,
              color: AppColors.primaryGrey2,
            ),
            const Gap(40),
            BusyButton(
              title: 'Go Back',
              onTap: () => Get.back(),
              width: screenWidth(context) * 0.6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryGrey.withOpacity(0.3),
              ),
            ),
            child: Text(
              'This is a new policy from the CENTRAL BANK OF NIGERIA (CBN), which mandates that all virtual accounts must be linked to a BVN.',
              style: TextStyle(
                fontSize: 13,
                fontFamily: AppFonts.manRope,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              softWrap: true,
            ),
          ),
          const Gap(24),
          TextSemiBold(
            'BVN',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.bvnController,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontFamily: AppFonts.manRope,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter your BVN',
                    hintStyle: TextStyle(
                        color: AppColors.primaryGrey2,
                        fontFamily: AppFonts.manRope),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: AppColors.primaryGrey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: AppColors.primaryGrey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    // Implement paste from clipboard
                    final clipboardData = await Clipboard.getData('text/plain');
                    if (clipboardData != null && clipboardData.text != null) {
                      controller.bvnController.text = clipboardData.text!;
                    }
                  },
                  child: TextSemiBold(
                    'Paste',
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Gap(32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.face,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextSemiBold(
                        'Your face needs to be verified against your BVN information.',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      const Gap(8),
                      TextSemiBold(
                        'We Recommend that you:',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      const Gap(4),
                      TextSemiBold(
                        '-Stay in a brightly lit environment\n-Remove glasses, hats, face masks or any other face coverings',
                        fontSize: 12,
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(40),
          Center(
            child: Obx(() => BusyButton(
                  width: screenWidth(context) * 0.8,
                  title: "Start Face Verification",
                  onTap: () => controller.startBvnVerification(context),
                  disabled: controller.isLoading.value,
                )),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}
