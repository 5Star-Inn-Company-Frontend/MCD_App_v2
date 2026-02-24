import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/predict_win_module/models/predict_win_model.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/ads_service.dart';

class PredictWinModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();
  final adsService = AdsService();

  // Observables
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final predictionData = Rxn<PredictWinModel>();
  final selectedReward = Rxn<PredictWinReward>();

  // Form controllers
  final homeScoreController = TextEditingController();
  final awayScoreController = TextEditingController();
  final recipientController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Submission state
  final isSubmitting = false.obs;

  // Spinning wheel state
  final isSpinning = false.obs;
  final hasSpun = false.obs;
  final currentSpinIndex = 0.obs;
  StreamController<int>? _spinController;
  
  StreamController<int> get spinController {
    _spinController ??= StreamController<int>.broadcast();
    return _spinController!;
  }

  // Countdown timer
  Timer? _countdownTimer;
  final countdown = ''.obs;

  // Info dialog shown state
  final hasShownInfoDialog = false.obs;

  // Get storage key for tracking spin state per prediction
  String get _spinStorageKey {
    final questionId = predictionData.value?.question.id ?? 0;
    return 'predict_win_spin_$questionId';
  }

  @override
  void onInit() {
    super.onInit();
    dev.log('PredictWinModuleController initialized', name: 'PredictWin');
    fetchPredictions();
  }

  void _showInfoDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to PREDICT & WIN.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoItem('You can only predict once'),
              _buildInfoItem('There is ₦100 wallet charge on your prediction'),
              _buildInfoItem('Roll the wheel to your favour before submitting your prediction'),
              _buildInfoItem('After submission, your prediction cannot be modified'),
              _buildInfoItem('There is no refund on LOSS'),
              _buildInfoItem('After the match is over, expect your reward within an hour'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0
                  ),
                  child: const Text(
                    'PROCEED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryGrey2,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.primaryGrey2,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _spinController?.close();
    homeScoreController.dispose();
    awayScoreController.dispose();
    recipientController.dispose();
    super.onClose();
  }

  Future<void> fetchPredictions() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final utilityUrl = box.read('utility_service_url');
      if (utilityUrl == null || utilityUrl.isEmpty) {
        errorMessage.value = 'Service URL not configured. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = '${utilityUrl}predict-win';

      final result = await apiService.getrequest(url);

      result.fold(
        (failure) {
          dev.log('Failed to fetch predictions',
              name: 'PredictWin', error: failure.message);
          errorMessage.value = failure.message;
          isLoading.value = false;
        },
        (data) {
          dev.log('Predictions response: $data', name: 'PredictWin');

          if (data['success'] == 1) {
            final response = PredictWinResponse.fromJson(data);
            predictionData.value = response.data;

            if (predictionData.value != null) {
              _startCountdown();
              _loadSpinState();
              // Show info dialog on first load
              if (!hasShownInfoDialog.value) {
                hasShownInfoDialog.value = true;
                Future.delayed(const Duration(milliseconds: 500), () {
                  _showInfoDialog();
                });
              }
            }

            dev.log('Fetched prediction with ${predictionData.value?.rewards.length ?? 0} rewards',
                name: 'PredictWin');
          } else {
            errorMessage.value =
                data['message'] ?? 'Failed to fetch predictions';
          }

          isLoading.value = false;
        },
      );
    } catch (e) {
      dev.log('Error fetching predictions', name: 'PredictWin', error: e);
      errorMessage.value = 'An error occurred while fetching predictions';
      isLoading.value = false;
    }
  }

  void _loadSpinState() {
    try {
      final spinData = box.read(_spinStorageKey);
      if (spinData != null && spinData is Map) {
        // Validate timestamp against prediction end time
        final timestampStr = spinData['timestamp'];
        if (timestampStr != null) {
          try {
            final spinTimestamp = DateTime.parse(timestampStr);
            final endDateTime = DateTime.parse(predictionData.value!.question.endAt);
            
            // If spin was made after the prediction ended, clear it
            if (spinTimestamp.isAfter(endDateTime)) {
              dev.log('Spin state expired (after prediction end time), clearing', name: 'PredictWin');
              _clearSpinState();
              return;
            }
            
            // If prediction has already ended, clear old spin state
            if (DateTime.now().isAfter(endDateTime)) {
              dev.log('Prediction has ended, clearing spin state', name: 'PredictWin');
              _clearSpinState();
              return;
            }
          } catch (e) {
            dev.log('Error parsing timestamp, clearing spin state', name: 'PredictWin', error: e);
            _clearSpinState();
            return;
          }
        }
        
        hasSpun.value = spinData['hasSpun'] ?? false;
        final rewardId = spinData['rewardId'];
        
        if (hasSpun.value && rewardId != null) {
          // Find and restore the selected reward
          final rewards = predictionData.value?.rewards ?? [];
          final reward = rewards.firstWhereOrNull((r) => r.id == rewardId);
          if (reward != null) {
            selectedReward.value = reward;
            dev.log('Restored spin state: ${reward.displayName}', name: 'PredictWin');
          } else {
            // Reward not found, clear invalid state
            hasSpun.value = false;
            _clearSpinState();
          }
        }
      }
    } catch (e) {
      dev.log('Error loading spin state', name: 'PredictWin', error: e);
    }
  }

  void _saveSpinState() {
    try {
      final spinData = {
        'hasSpun': hasSpun.value,
        'rewardId': selectedReward.value?.id,
        'timestamp': DateTime.now().toIso8601String(),
      };
      box.write(_spinStorageKey, spinData);
      dev.log('Saved spin state for question ${predictionData.value?.question.id}', name: 'PredictWin');
    } catch (e) {
      dev.log('Error saving spin state', name: 'PredictWin', error: e);
    }
  }

  void _clearSpinState() {
    try {
      box.remove(_spinStorageKey);
      dev.log('Cleared spin state for question ${predictionData.value?.question.id}', name: 'PredictWin');
    } catch (e) {
      dev.log('Error clearing spin state', name: 'PredictWin', error: e);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    if (predictionData.value == null) return;

    // Parse the end_at time
    try {
      final endDateTime = DateTime.parse(predictionData.value!.question.endAt);

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final difference = endDateTime.difference(now);

        if (difference.isNegative) {
          countdown.value = 'Ended';
          timer.cancel();
        } else {
          final days = difference.inDays;
          final hours = difference.inHours.remainder(24);
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);
          
          if (days > 0) {
            countdown.value = '${days}d ${hours}h ${minutes}m';
          } else {
            countdown.value =
                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
          }
        }
      });
    } catch (e) {
      dev.log('Error parsing countdown', name: 'PredictWin', error: e);
    }
  }

  Future<void> spinWheel() async {
    if (hasSpun.value || predictionData.value == null) {
      return;
    }

    if (predictionData.value!.rewards.isEmpty) {
      Get.snackbar(
        'Error',
        'No rewards available',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isSpinning.value = true;

    // Generate random final index
    final random = DateTime.now().millisecondsSinceEpoch;
    final rewards = predictionData.value!.rewards;
    final finalIndex = random % rewards.length;

    // Trigger FortuneBar animation
    spinController.add(finalIndex);
    currentSpinIndex.value = finalIndex;

    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 4));

    // Set final result
    selectedReward.value = rewards[finalIndex];
    hasSpun.value = true;
    isSpinning.value = false;

    // Save spin state to storage
    _saveSpinState();

    dev.log('Spun reward: ${selectedReward.value?.displayName}', name: 'PredictWin');
  }

  Future<void> submitPrediction() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (predictionData.value == null) {
      Get.snackbar(
        'Error',
        'No prediction available',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!hasSpun.value || selectedReward.value == null) {
      Get.snackbar(
        'Error',
        'Please spin the wheel first to select your reward',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final utilityUrl = box.read('utility_service_url');
      if (utilityUrl == null || utilityUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Service URL not configured. Please login again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
          snackPosition: SnackPosition.TOP,
        );
        isSubmitting.value = false;
        return;
      }

      final url = '${utilityUrl}predict-win';

      // Format answer as "home-away" (e.g., "2-1")
      final formattedAnswer = '${homeScoreController.text.trim()}-${awayScoreController.text.trim()}';

      // Use '0' for recipient if it's a wallet credit, otherwise use the input value
      final recipient = isRecipientRequired() 
          ? recipientController.text.trim() 
          : '0';

      final request = SubmitPredictionRequest(
        id: selectedReward.value!.id,
        ques: predictionData.value!.question.id,
        answer: formattedAnswer,
        recipient: recipient,
      );

      dev.log('Submission payload: ${request.toJson()}', name: 'PredictWin');

      final result = await apiService.postrequest(url, request.toJson());

      result.fold(
        (failure) {
          dev.log('Prediction submission failed',
              name: 'PredictWin', error: failure.message);
          Get.snackbar(
            'Submission Failed',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
            snackPosition: SnackPosition.TOP,
          );
        },
        (data) {
          dev.log('Prediction submission response: $data', name: 'PredictWin');

          final response = SubmitPredictionResponse.fromJson(data);

          if (response.isSuccess) {
            // Clear spin state from storage
            _clearSpinState();
            
            // Clear form
            homeScoreController.clear();
            awayScoreController.clear();
            recipientController.clear();
            selectedReward.value = null;
            hasSpun.value = false;

            Get.snackbar(
              'Success',
              response.message,
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 3),
            );

            // Refresh predictions
            fetchPredictions();
          } else {
            Get.snackbar(
              'Submission Failed',
              response.message,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              snackPosition: SnackPosition.TOP,
            );
          }
        },
      );
    } catch (e) {
      dev.log('Error submitting prediction', name: 'PredictWin', error: e);
      Get.snackbar(
        'Error',
        'An error occurred while submitting your prediction',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void selectPrediction(PredictWinModel prediction) {
    predictionData.value = prediction;
    _startCountdown();
  }

  String? validateScore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final score = int.tryParse(value.trim());
    if (score == null || score < 0) {
      return 'Enter valid score';
    }
    return null;
  }

  // Check if recipient is required based on reward type
  bool isRecipientRequired() {
    final reward = selectedReward.value;
    if (reward == null) return true;
    // Wallet credits don't need recipient phone number
    return reward.type.toLowerCase() != 'wallet';
  }

  String? validateRecipient(String? value) {
    // Skip validation if recipient is not required (wallet credit)
    if (!isRecipientRequired()) {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'Please enter recipient phone number';
    }

    // Validate Nigerian phone number
    final cleanNumber = value.replaceAll(RegExp(r'\s+'), '');
    if (cleanNumber.length < 10 || cleanNumber.length > 14) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}
