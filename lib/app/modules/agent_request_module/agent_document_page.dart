import 'package:mcd/core/import/imports.dart';
import './agent_request_module_controller.dart';

class AgentDocumentPage extends GetView<AgentRequestModuleController> {
  const AgentDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Step 2: Preview & Sign',
        centerTitle: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Banner Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primaryColor.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.description_rounded,
                                  color: AppColors.primaryColor,
                                  size: 26,
                                ),
                              ),
                              const Gap(14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextSemiBold(
                                      'Document Generated!',
                                      fontSize: 16,
                                      color: AppColors.textPrimaryColor,
                                    ),
                                    const Gap(4),
                                    Text(
                                      'Your agent request agreement is ready for preview.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.primaryGrey2,
                                        fontFamily: AppFonts.manRope,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Gap(24),

                        // Instructions Card
                        TextSemiBold(
                          'Next Steps',
                          fontSize: 16,
                          color: AppColors.textPrimaryColor,
                        ),
                        const Gap(12),
                        _buildInstructionStep(
                          stepNumber: '1',
                          title: 'Read & Preview Document',
                          description:
                              'Click "Read Document" below to preview and review your agreement terms in your browser.',
                        ),
                        const Gap(12),
                        _buildInstructionStep(
                          stepNumber: '2',
                          title: 'Sign & Pay Fee',
                          description:
                              'Once reviewed, click "Sign & Pay" to input your signature. A processing fee of NGN 5,000 will be deducted from your wallet.',
                        ),

                        const Gap(24),

                        // Status Badge
                        Obx(() {
                          final isRead = controller.isRead.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isRead
                                  ? AppColors.successBgColor.withOpacity(0.1)
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isRead
                                    ? AppColors.primaryColor.withOpacity(0.3)
                                    : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isRead
                                      ? Icons.check_circle_rounded
                                      : Icons.info_outline_rounded,
                                  color: isRead
                                      ? AppColors.primaryColor
                                      : const Color(0xFFD97706),
                                  size: 22,
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Text(
                                    isRead
                                        ? 'Document reviewed! You can now proceed to sign.'
                                        : 'Please read the document before signing.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isRead
                                          ? AppColors.primaryColor
                                          : const Color(0xFF92400E),
                                      fontFamily: AppFonts.manRope,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),

                    // Action Buttons Bottom Container
                    Column(
                      children: [
                        const Gap(24),

                        // Read Document button
                        Obx(() => BusyButton(
                              title: 'Read Document',
                              isLoading: controller.isSubmitting.value,
                              onTap: controller.openDocumentInBrowser,
                              width: double.infinity,
                            )),

                        const Gap(14),

                        // Sign & Pay button
                        Obx(() {
                          final isRead = controller.isRead.value;
                          return BusyButton(
                            title: 'Sign Here & Pay (NGN 5,000)',
                            color: isRead
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withOpacity(0.5),
                            onTap: () {
                              if (!isRead) {
                                Get.snackbar(
                                  'Action Required',
                                  'Kindly click "Read Document" to preview the document before signing',
                                  backgroundColor: AppColors.errorBgColor,
                                  colorText: AppColors.textSnackbarColor,
                                  snackPosition: SnackPosition.TOP,
                                );
                                return;
                              }
                              Get.toNamed(Routes.AGENT_SIGNATURE);
                            },
                            width: double.infinity,
                          );
                        }),

                        const Gap(16),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSemiBold(
                  title,
                  fontSize: 14,
                  color: AppColors.textPrimaryColor,
                ),
                const Gap(4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGrey2,
                    fontFamily: AppFonts.manRope,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
