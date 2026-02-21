import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  final predictions = <PredictWinModel>[].obs;
  final selectedPrediction = Rxn<PredictWinModel>();

  // Form controllers
  final answerController = TextEditingController();
  final recipientController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Submission state
  final isSubmitting = false.obs;

  // Countdown timer
  Timer? _countdownTimer;
  final countdown = ''.obs;

  @override
  void onInit() {
    super.onInit();
    dev.log('PredictWinModuleController initialized', name: 'PredictWin');
    fetchPredictions();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    answerController.dispose();
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
            predictions.value = response.predictions;

            if (predictions.isNotEmpty) {
              selectedPrediction.value = predictions.first;
              _startCountdown();
            }

            dev.log('Fetched ${predictions.length} predictions',
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

  void _startCountdown() {
    _countdownTimer?.cancel();

    if (selectedPrediction.value == null) return;

    // Parse the match date and time
    try {
      final matchDateTime = DateTime.parse(
          '${selectedPrediction.value!.matchDate} ${selectedPrediction.value!.kickoffTime}');

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final difference = matchDateTime.difference(now);

        if (difference.isNegative) {
          countdown.value = 'Match Started';
          timer.cancel();
        } else {
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);
          countdown.value =
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        }
      });
    } catch (e) {
      dev.log('Error parsing countdown', name: 'PredictWin', error: e);
    }
  }

  Future<void> submitPrediction() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedPrediction.value == null) {
      Get.snackbar(
        'Error',
        'No prediction selected',
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

      final request = SubmitPredictionRequest(
        id: selectedPrediction.value!.id,
        ques: 1, // Question number - assuming 1 for now
        answer: answerController.text.trim(),
        recipient: recipientController.text.trim(),
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
            // Clear form
            answerController.clear();
            recipientController.clear();

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
    selectedPrediction.value = prediction;
    _startCountdown();
  }

  String? validateAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your prediction';
    }
    return null;
  }

  String? validateRecipient(String? value) {
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
