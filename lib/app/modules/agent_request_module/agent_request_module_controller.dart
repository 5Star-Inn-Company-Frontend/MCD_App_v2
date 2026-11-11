import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;
import 'package:mcd/app/styles/app_colors.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mcd/app/routes/app_pages.dart';
import './models/agent_task_model.dart';

class AgentRequestModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final isLoading = false.obs;
  final step1 = false.obs;
  final step2 = false.obs;
  final step3 = false.obs;

  // Agent Tasks
  final isLoadingTasks = false.obs;
  final currentTasks = Rxn<AgentTasksResponse>();
  final previousTasks = Rxn<AgentPreviousTasksResponse>();
  final expandedHistoryIndex = (-1).obs;
  final tasksErrorMessage = ''.obs;

  // Personal Info Form
  final personalInfoFormKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final businessNameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final streetNumberController = TextEditingController();
  final streetAddressController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final isPersonalInfoFormValid = false.obs;
  final isSubmitting = false.obs;
  final isRead = false.obs;

  // Signature Pad
  final signaturePadKey = GlobalKey<SfSignaturePadState>();

  // Document URL
  final documentUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAgentStatus();

    // Listen to form field changes for validation
    firstNameController.addListener(_validatePersonalInfoForm);
    businessNameController.addListener(_validatePersonalInfoForm);
    dobController.addListener(_validatePersonalInfoForm);
    phoneNumberController.addListener(_validatePersonalInfoForm);
    streetNumberController.addListener(_validatePersonalInfoForm);
    streetAddressController.addListener(_validatePersonalInfoForm);
    stateController.addListener(_validatePersonalInfoForm);
    countryController.addListener(_validatePersonalInfoForm);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    businessNameController.dispose();
    dobController.dispose();
    phoneNumberController.dispose();
    streetNumberController.dispose();
    streetAddressController.dispose();
    stateController.dispose();
    countryController.dispose();
    super.onClose();
  }

  void _validatePersonalInfoForm() {
    isPersonalInfoFormValid.value = businessNameController.text.isNotEmpty &&
        streetAddressController.text.isNotEmpty &&
        stateController.text.isNotEmpty &&
        countryController.text.isNotEmpty;
  }

  Future<void> fetchAgentStatus() async {
    try {
      isLoading.value = true;

      final fullUrl = '${ApiConstants.authUrlV2}/agentstatus';
      dev.log('Request URL: $fullUrl', name: 'AgentRequest');
      final result = await apiService.getrequest(fullUrl);

      result.fold(
        (failure) {
          dev.log('Failed to fetch agent status',
              name: 'AgentRequest', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (response) {
          dev.log('Agent status response: $response', name: 'AgentRequest');
          if (response['success'] == 1 && response['data'] != null) {
            final data = response['data'];
            dev.log(
                'Agent status data: step1=${data['step1']}, step2=${data['step2']}, step3=${data['step3']}',
                name: 'AgentRequest');
            step1.value = data['step1'] ?? false;
            step2.value = data['step2'] ?? false;
            step3.value = data['step3'] ?? false;
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching agent status', name: 'AgentRequest', error: e);
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showBenefitsBottomSheet() {
    // This will be called when "See Benefits" button is tapped
  }

  void showTasksBottomSheet() {
    // This will be called when "My Tasks" button is tapped
  }

  Future<void> fetchCurrentAgentTasks() async {
    try {
      isLoadingTasks.value = true;
      tasksErrorMessage.value = '';

      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        tasksErrorMessage.value =
            'Service configuration error. Please login again.';
        isLoadingTasks.value = false;
        return;
      }

      dev.log(
          'Fetching current agent tasks from: ${transactionUrl}agent-tasks-current',
          name: 'AgentTasks');

      final result =
          await apiService.getrequest('${transactionUrl}agent-tasks-current');

      result.fold(
        (failure) {
          isLoadingTasks.value = false;
          tasksErrorMessage.value = failure.message;
          dev.log('Failed to fetch agent tasks',
              name: 'AgentTasks', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (data) {
          isLoadingTasks.value = false;
          dev.log('Agent tasks response: $data',
              name: 'AgentTasks'); // Log full response

          if (data['success'] == 1) {
            currentTasks.value = AgentTasksResponse.fromJson(data);
            dev.log(
                'Loaded ${currentTasks.value?.tasks.length ?? 0} current tasks',
                name: 'AgentTasks');
          } else {
            tasksErrorMessage.value = data['message'] ?? 'Failed to load tasks';
          }
        },
      );
    } catch (e) {
      isLoadingTasks.value = false;
      tasksErrorMessage.value = 'An error occurred while fetching tasks';
      dev.log('Error fetching agent tasks', name: 'AgentTasks', error: e);
    }
  }

  Future<void> fetchPreviousAgentTasks() async {
    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null) {
        return;
      }

      dev.log(
          'Fetching previous agent tasks from: ${transactionUrl}agent-tasks-previous',
          name: 'AgentTasks');

      final result =
          await apiService.getrequest('${transactionUrl}agent-tasks-previous');

      result.fold(
        (failure) {
          dev.log('Failed to fetch previous agent tasks',
              name: 'AgentTasks', error: failure.message);
        },
        (data) {
          dev.log('Previous agent tasks response: $data',
              name: 'AgentTasks'); // Log full response

          if (data['success'] == 1) {
            previousTasks.value = AgentPreviousTasksResponse.fromJson(data);
            dev.log(
                'Loaded ${previousTasks.value?.tasks.length ?? 0} previous tasks',
                name: 'AgentTasks');
          }
        },
      );
    } catch (e) {
      dev.log('Error fetching previous agent tasks',
          name: 'AgentTasks', error: e);
    }
  }

  void retryFetchTasks() {
    fetchCurrentAgentTasks();
  }

  Future<void> submitAgentRequest() async {
    if (!personalInfoFormKey.currentState!.validate()) {
      return;
    }

    try {
      isSubmitting.value = true;

      // final utilityUrl = box.read('utility_service_url');
      // if (utilityUrl == null || utilityUrl.isEmpty) {
      //   Get.snackbar(
      //     'Error',
      //     'Service URL not found. Please log in again.',
      //     backgroundColor: AppColors.errorBgColor,
      //     colorText: AppColors.textSnackbarColor,
      //   );
      //   return;
      // }

      final fullUrl = '${ApiConstants.authUrlV2}/agent';
      dev.log('Request URL: $fullUrl', name: 'AgentRequest');

      // combine street number and address
      final streetFull = streetNumberController.text.trim().isNotEmpty
          ? '${streetNumberController.text.trim()}, ${streetAddressController.text.trim()}'
          : streetAddressController.text.trim();

      final payload = {
        'company_name': businessNameController.text.trim(),
        'street': streetFull,
        'state': stateController.text.trim(),
        'country': countryController.text.trim(),
      };

      dev.log('Payload: $payload', name: 'AgentRequest');

      final result = await apiService.postrequest(fullUrl, payload);

      print("samji result: ${result}");

      result.fold(
        (failure) {
          dev.log('Failed to submit agent request',
              name: 'AgentRequest', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (response) {
          if(response['success'] == 0){
            Get.snackbar(
              'Error',
              response['message'],
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            return;
          }

          dev.log('Agent request submitted successfully', name: 'AgentRequest');
          Get.snackbar(
            'Success',
            'Your agent request has been submitted successfully',
            backgroundColor: AppColors.primaryColor,
            colorText: AppColors.white,
          );

          // clear form and navigate to agent request steps
          businessNameController.clear();
          streetNumberController.clear();
          streetAddressController.clear();
          stateController.clear();
          countryController.clear();

          // Refresh agent status
          fetchAgentStatus();

          // navigate to agent request steps screen
          Get.offNamed(Routes.AGENT_REQUEST_MODULE);

        },
      );
    } catch (e) {
      dev.log('Error submitting agent request', name: 'AgentRequest', error: e);
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Open document in browser
  Future<void> openDocumentInBrowser() async {
    try {

      isSubmitting.value = true;

      final fullUrl = '${ApiConstants.authUrlV2}/request-agentdoc';


      final result = await apiService.getrequest(fullUrl);

      result.fold(
            (failure) {
          dev.log('Failed to fetch signed document',
              name: 'AgentRequestDoc', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        }, (response) async {
              if(response['success'] == 0){
                Get.snackbar(
                  'Error',
                  response['message'],
                  backgroundColor: AppColors.errorBgColor,
                  colorText: AppColors.textSnackbarColor,
                );
                return;
              }

            dev.log("Opening document URL: ${response['data']}", name: 'AgentRequest');

            final uri = Uri.parse(response['data']);

            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              isRead.value=true;
            } else {
              Get.snackbar(
              'Error',
              'Could not open document',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
              );
            }
        },
      );
    } catch (e) {
      dev.log('Error submitting signed document',
          name: 'AgentRequestDoc', error: e);
      Get.snackbar(
        'Error',
        'Failed to fetch signed document: ${e.toString()}',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Clear signature
  void clearSignature() {
    signaturePadKey.currentState?.clear();
  }

  // Submit signed document
  Future<void> submitSignedDocument() async {
    try {
      // Check if signature is empty
      final signatureData = await signaturePadKey.currentState?.toImage();
      if (signatureData == null) {
        Get.snackbar(
          'Error',
          'Please add your signature before submitting',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      isSubmitting.value = true;

      // Convert signature to base64
      final byteData =
          await signatureData.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert signature to image');
      }

      final pngBytes = byteData.buffer.asUint8List();
      final base64Signature = base64Encode(pngBytes);

      // final authUrl = box.read('authUrlV2');
      // if (authUrl == null || authUrl.isEmpty) {
      //   Get.snackbar(
      //     'Error',
      //     'Service URL not found. Please log in again.',
      //     backgroundColor: AppColors.errorBgColor,
      //     colorText: AppColors.textSnackbarColor,
      //   );
      //   return;
      // }

      final fullUrl = '${ApiConstants.authUrlV2}/agentdocument';
      dev.log('Submitting signed document to: $fullUrl', name: 'AgentRequest');

      final payload = {
        'signature': base64Signature,
      };

      final result = await apiService.postrequest(fullUrl, payload);

      result.fold(
        (failure) {
          dev.log('Failed to submit signed document',
              name: 'AgentRequest', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (response) {
          if(response['success'] == 0){
            Get.snackbar(
              'Error',
              response['message'],
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            return;
          }

          dev.log('Signed document submitted successfully',
              name: 'AgentRequest');
          Get.snackbar(
            'Success',
            response['message'],
            backgroundColor: AppColors.successBgColor,
            colorText: AppColors.textSnackbarColor,
          );

          // Navigate back to agent request page
          Get.until(
              (route) => route.isFirst || route.settings.name == Routes.AGENT_REQUEST_MODULE);

          // Refresh agent status
          fetchAgentStatus();
        },
      );
    } catch (e) {
      dev.log('Error submitting signed document',
          name: 'AgentRequest', error: e);
      Get.snackbar(
        'Error',
        'Failed to submit signed document: ${e.toString()}',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void handleStep2Navigation() {
    if (step2.value) {
      Get.snackbar(
        'Info',
        'You have already completed step 2',
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.white,
      );
    } else {
      Get.toNamed(Routes.AGENT_DOCUMENT);
    }
  }

  void handleTaskAction(String type) {
    if (type.toLowerCase() == 'airtime') {
      Get.toNamed(Routes.AIRTIME_MODULE);
    } else if (type.toLowerCase() == 'data') {
      Get.toNamed(Routes.DATA_MODULE);
    } else if (type.toLowerCase() == 'refer') {
      Get.toNamed(Routes.ADD_REFERRAL_MODULE);
    } else if (type.toLowerCase() == 'tv') {
      Get.toNamed(Routes.CABLE_MODULE);
    } else {
      Get.snackbar(
        'Info',
        'No action defined for this task',
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.white,
      );
    }
  }
}
