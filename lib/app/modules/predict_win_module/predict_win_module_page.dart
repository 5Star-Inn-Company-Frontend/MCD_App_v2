import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
        if (controller.predictionData.value == null) {
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
                    'Check back later for new predictions',
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
              // Question Card with Image
              _buildQuestionCard(),
              const Gap(20),

              // Reward Display
              _buildRewardDisplay(),
              const Gap(16),

              // Horizontal Spinning Wheel
              _buildSpinningWheel(),
              const Gap(24),

              // Prediction Form
              _buildPredictionForm(),

              const Gap(24),

              // Warning message
              _buildWarningMessage(),

              const Gap(24),

              // Submit button
              Obx(() => BusyButton(
                    title: 'PREDICT NOW',
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

  Widget _buildQuestionCard() {
    final question = controller.predictionData.value?.question;
    if (question == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Image
          if (question.image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: question.image,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: AppColors.primaryGrey.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: AppColors.primaryGrey.withOpacity(0.1),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.primaryGrey,
                  ),
                ),
              ),
            ),

          // Question Text and Countdown
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
                          color: AppColors.background,
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(12),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const Gap(6),
                          Text(
                            'Ends in: ${controller.countdown.value.isEmpty ? 'Loading...' : controller.countdown.value}',
                            style: TextStyle(
                              fontSize: 13,
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
          ),
          
        ],
      ),
    );
  }

  Widget _buildSpinButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(() => ElevatedButton(
            onPressed: controller.hasSpun.value || controller.isSpinning.value
                ? null
                : controller.spinWheel,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.hasSpun.value
                  ? AppColors.primaryGrey2
                  : AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: controller.hasSpun.value ? 0 : 2,
            ),
            child: Text(
              controller.isSpinning.value
                      ? 'Spinning...'
                      : 'SPIN',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: AppFonts.manRope,
              ),
            ),
          )),
    );
  }

  Widget _buildRewardDisplay() {
    return Obx(() {
      final reward = controller.selectedReward.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reward:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    reward?.displayName ?? 'Spin to select reward',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: reward != null
                          ? AppColors.primaryColor
                          : AppColors.primaryGrey2,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            _buildSpinButton()
          ],
        ),
      );
    });
  }

  Widget _buildSpinningWheel() {
    return Obx(() {
      final rewards = controller.predictionData.value?.rewards ?? [];
      if (rewards.isEmpty) return const SizedBox.shrink();

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FortuneBar(
          height: 80,
          selected: controller.spinController.stream,
          animateFirst: false,
          duration: const Duration(seconds: 4),
          curve: Curves.easeOutCirc,
          // indicators: const [
          //   FortuneIndicator(
          //     alignment: Alignment.topCenter,
          //     child: TriangleIndicator(
          //       color: AppColors.primaryColor,
          //       width: 20,
          //       height: 15,
          //     ),
          //   ),
          // ],
          items: rewards.map((reward) {
            return FortuneItem(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                // color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon(
                    //   _getIconForReward(reward.type),
                    //   color: AppColors.primaryColor,
                    //   size: 24,
                    // ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        reward.displayName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              style: FortuneItemStyle(
                color: Colors.grey.shade50,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  IconData _getIconForReward(String type) {
    switch (type.toLowerCase()) {
      case 'airtime':
        return Icons.phone_android;
      case 'data':
        return Icons.wifi;
      case 'betting':
        return Icons.sports_soccer;
      case 'electricity':
        return Icons.bolt;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.card_giftcard;
    }
  }

  Widget _buildPredictionForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Prediction
          TextSemiBold(
            'Enter Score Prediction',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          const Gap(10),
          Row(
            children: [
              // Home Score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGrey2,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                    const Gap(6),
                    TextFormField(
                      controller: controller.homeScoreController,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppColors.primaryGrey,
                          fontFamily: AppFonts.manRope,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.manRope,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: controller.validateScore,
                    ),
                  ],
                ),
              ),
              
              // VS Separator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Gap(18),
                    Text(
                      '-',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGrey2,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Away Score
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Away',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGrey2,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                    const Gap(6),
                    TextFormField(
                      controller: controller.awayScoreController,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: AppColors.primaryGrey,
                          fontFamily: AppFonts.manRope,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.manRope,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: controller.validateScore,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(20),

          // Recipient Phone Number
          Obx(() {
            final isRequired = controller.isRecipientRequired();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextSemiBold(
                      'Recipient Phone Number',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    if (!isRequired) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Not Required',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Gap(10),
                TextFormField(
                  controller: controller.recipientController,
                  enabled: isRequired,
                  decoration: InputDecoration(
                    hintText: isRequired ? '08012345678' : 'Not required for wallet credit',
                    hintStyle: TextStyle(
                      color: AppColors.primaryGrey,
                      fontFamily: AppFonts.manRope,
                    ),
                    filled: true,
                    fillColor: isRequired ? Colors.grey.shade50 : Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(14),
                  ],
                  validator: controller.validateRecipient,
                ),
              ],
            );
          }),
          const Gap(20),

          // Amount to Stake (Fixed ₦100)
          TextSemiBold(
            'Amount to Stake',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          const Gap(10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              '₦100',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 22,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
                const Gap(4),
                Text(
                  '• You can only spin once per prediction\n• Stake amount is fixed at ₦100\n• Predictions must be submitted before countdown ends',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    height: 1.4,
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
