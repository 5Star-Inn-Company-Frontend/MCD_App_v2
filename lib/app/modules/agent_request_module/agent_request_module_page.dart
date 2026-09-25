import 'package:mcd/core/import/imports.dart';
import 'package:mcd/app/widgets/skeleton_loader.dart';
import './agent_request_module_controller.dart';
import './my_tasks_page.dart';
import 'package:mcd/app/widgets/custom_bottom_sheet.dart';

class AgentRequestModulePage extends GetView<AgentRequestModuleController> {
  const AgentRequestModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Agent Request',
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: const [
                SkeletonCard(height: 80),
                Gap(16),
                SkeletonCard(height: 80),
                Gap(16),
                SkeletonCard(height: 80),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Steps Section
              _buildStepCard(
                stepNumber: '1',
                title: 'Provide personal details',
                isCompleted: controller.step1.value,
                isEnabled: true, // step 1 is always enabled
                onTap: () {
                  if (controller.step1.value) {
                    Get.snackbar(
                      'Info',
                      'You have already completed this step',
                      backgroundColor: AppColors.primaryColor,
                      colorText: AppColors.white,
                    );
                  } else {
                    Get.toNamed(Routes.AGENT_PERSONAL_INFO);
                  }
                },
              ),
              const Gap(16),
              _buildStepCard(
                stepNumber: '2',
                title: 'Provide copy of signed document sent to your email',
                isCompleted: controller.step2.value,
                isEnabled:
                    controller.step1.value, // enabled only if step 1 is done
                onTap: controller.step1.value
                    ? controller.handleStep2Navigation
                    : null,
              ),
              const Gap(16),
              _buildStepCard(
                stepNumber: '3',
                title: 'Awaiting verification',
                isCompleted: controller.step3.value,
                isEnabled:
                    controller.step2.value, // enabled only if step 2 is done
                onTap: null,
              ),

              const Gap(40),

              // See Benefits Button
              Center(
                child: GestureDetector(
                  onTap: () => _showBenefitsBottomSheet(context),
                  child: TextSemiBold(
                    'See Benefits',
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required bool isCompleted,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled
          ? onTap
          : () {
              Get.snackbar(
                'Step Locked',
                'Please complete the previous step first',
                backgroundColor: AppColors.errorBgColor,
                colorText: AppColors.textSnackbarColor,
              );
            },
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(
              color: isEnabled
                  ? AppColors.primaryGrey.withOpacity(0.3)
                  : AppColors.primaryGrey.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSemiBold(
                      'Step $stepNumber',
                      fontSize: 14,
                    ),
                    const Gap(4),
                    TextSemiBold(
                      title,
                      fontSize: 15,
                      color: isEnabled
                          ? AppColors.textPrimaryColor
                          : AppColors.primaryGrey,
                    ),
                  ],
                ),
              ),
              isCompleted
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.primaryColor,
                      size: 24,
                    )
                  : Icon(
                      isEnabled ? Icons.chevron_right : Icons.lock_outline,
                      color: AppColors.primaryGrey,
                      size: 24,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBenefitsBottomSheet(BuildContext context) {
    showCustomBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),

              Image.asset(
                'assets/images/mcdagentlogo.png',
                width: 60,
                height: 60,
              ),
              const Gap(8),
              const Text(
                'Your compensation package as an Agent will be each and every successful sale & tv subscription purchased within a month and according to level breakdown is shown below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGrey2,
                    fontFamily: AppFonts.manRope),
              ),

              const Gap(24),

              // Levels List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildLevelItem('Level 1: #3'),
                    _buildLevelItem('Level 2: #5'),
                    _buildLevelItem('Level 3: #8'),
                    _buildLevelItem('Level 4: #9'),
                    _buildLevelItem('Level 5: #10'),
                    _buildLevelItem('Level 6: #13'),
                    _buildLevelItem('Level 7: #15'),
                    _buildLevelItem('Level 8: #20'),
                    _buildLevelItem('...and so on'),
                  ],
                ),
              ),

              // const Gap(16),

              // My Tasks Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const MyTasksPage());
                  },
                  child: TextSemiBold(
                    'My Tasks',
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 14),
          const Gap(12),
          TextSemiBold(
            text,
            fontSize: 14,
            color: AppColors.textPrimaryColor,
          ),
        ],
      ),
    );
  }
}
