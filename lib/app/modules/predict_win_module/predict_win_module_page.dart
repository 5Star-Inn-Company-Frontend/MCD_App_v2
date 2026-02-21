import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/predict_win_module/predict_win_module_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/core/constants/fonts.dart';

class PredictWinModulePage extends GetView<PredictWinModuleController> {
  const PredictWinModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: "Predict and Win",
        centerTitle: false,
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        // Error state
        if (controller.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(16),
                  TextSemiBold(
                    controller.errorMessage.value!,
                    fontSize: 16,
                    color: AppColors.primaryGrey,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(24),
                  BusyButton(
                    title: 'Retry',
                    onTap: controller.fetchPredictions,
                    width: 120,
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (controller.predictions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 64,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(16),
                  TextSemiBold(
                    'No predictions available',
                    fontSize: 16,
                    color: AppColors.primaryGrey,
                  ),
                  const Gap(8),
                  Text(
                    'Check back later for new matches',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Success state - show prediction form
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match Card
              _buildMatchCard(),
              const Gap(14),
              controller.adsService.showBannerAdWidget(),
              const Gap(14),

              // Description
              if (controller.selectedPrediction.value?.description.isNotEmpty ??
                  false)
                _buildDescriptionCard(),

              const Gap(24),

              // Prediction Form
              _buildPredictionForm(),

              const Gap(24),

              // Warning message
              _buildWarningMessage(),

              const Gap(32),

              // Submit button
              Obx(() => BusyButton(
                    title: 'Submit',
                    onTap: controller.submitPrediction,
                    disabled: controller.isSubmitting.value,
                  )),

              const Gap(40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMatchCard() {
    final prediction = controller.selectedPrediction.value;
    if (prediction == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF3FFF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE0E0E0)),
      ),
      child: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              prediction.matchTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.manRope,
              ),
            ),
          ),
          const Gap(8),

          // Match date and time
          Text(
            '${prediction.matchDate} • ${prediction.kickoffTime}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryGrey2,
              fontFamily: AppFonts.manRope,
            ),
          ),
          const Gap(20),

          // Teams
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Team 1
              Expanded(
                child: Column(
                  children: [
                    _buildTeamFlag(prediction.team1Flag),
                    const Gap(12),
                    Text(
                      prediction.team1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.manRope,
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),

              // VS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryColor, width: 2),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                ),
              ),

              // Team 2
              Expanded(
                child: Column(
                  children: [
                    _buildTeamFlag(prediction.team2Flag),
                    const Gap(12),
                    Text(
                      prediction.team2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.manRope,
                        color: AppColors.background,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(20),

          // Countdown
          Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    const Gap(8),
                    Text(
                      controller.countdown.value.isEmpty
                          ? 'Loading...'
                          : controller.countdown.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTeamFlag(String flagUrl) {
    if (flagUrl.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primaryGrey.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.sports_soccer,
          size: 40,
          color: AppColors.primaryGrey,
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: flagUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: AppColors.primaryGrey.withOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryGrey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sports_soccer,
            size: 40,
            color: AppColors.primaryGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final prediction = controller.selectedPrediction.value;
    if (prediction == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.manRope,
              color: AppColors.background,
            ),
          ),
          const Gap(12),
          Text(
            prediction.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryGrey,
              height: 1.5,
              fontFamily: AppFonts.manRope,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionForm() {
    final prediction = controller.selectedPrediction.value;
    if (prediction == null) return const SizedBox.shrink();

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prediction Question
          TextSemiBold(
            'Prediction Question',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const Gap(12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              prediction.predictionQuestion,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.background,
                fontFamily: AppFonts.manRope,
              ),
            ),
          ),
          const Gap(24),

          // Answer Input
          TextSemiBold(
            'Enter your Prediction',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const Gap(8),
          TextField(
            controller: controller.answerController,
            decoration: InputDecoration(
              hintText: 'e.g., 1-1, 2-0, 0-0',
              errorText:
                  controller.validateAnswer(controller.answerController.text),
            ),
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
            ],
          ),
          const Gap(20),

          // Recipient Phone Number
          TextSemiBold(
            'Recipient Phone Number',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          const Gap(8),
          TextField(
            controller: controller.recipientController,
            decoration: InputDecoration(
              hintText: '08012345678',
              errorText: controller
                  .validateRecipient(controller.recipientController.text),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'Predictions must be submitted before the countdown ends. Late entries will not be accepted.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade900,
                fontFamily: AppFonts.manRope,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
