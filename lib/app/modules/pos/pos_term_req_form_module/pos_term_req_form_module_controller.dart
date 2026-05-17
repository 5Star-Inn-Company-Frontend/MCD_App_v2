import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/constants/fonts.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'dart:developer' as dev;

class PosTermReqFormModuleController extends GetxController {
  final apiService = DioApiService();
  final box = GetStorage();

  final isLoading = false.obs;

  final addressDeliveryController = TextEditingController();
  final contactNameController = TextEditingController();
  final contactEmailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();

  final terminalType = ''.obs;
  final purchaseType = ''.obs;
  final numOfPos = ''.obs;

  final selectedState = ''.obs;

  // List of Nigerian States
  final List<String> nigerianStates = [
    "Abia",
    "Adamawa",
    "Akwa Ibom",
    "Anambra",
    "Bauchi",
    "Bayelsa",
    "Benue",
    "Borno",
    "Cross River",
    "Delta",
    "Ebonyi",
    "Edo",
    "Ekiti",
    "Enugu",
    "FCT - Abuja",
    "Gombe",
    "Imo",
    "Jigawa",
    "Kaduna",
    "Kano",
    "Katsina",
    "Kebbi",
    "Kogi",
    "Kwara",
    "Lagos",
    "Nasarawa",
    "Niger",
    "Ogun",
    "Ondo",
    "Osun",
    "Oyo",
    "Plateau",
    "Rivers",
    "Sokoto",
    "Taraba",
    "Yobe",
    "Zamfara"
  ];

  // Terminal data from previous screen
  int? selectedPosId;

  @override
  void onInit() {
    super.onInit();
    dev.log('PosTermReqFormModuleController initialized',
        name: 'PosTermReqForm');

    // Get terminal data from arguments
    final args = Get.arguments;
    if (args != null) {
      if (args['terminalType'] != null) {
        terminalType.value = args['terminalType'];
      }
      if (args['terminal'] != null) {
        selectedPosId = args['terminal'].id;
      }
    }
  }

  @override
  void onClose() {
    addressDeliveryController.dispose();
    contactNameController.dispose();
    contactEmailController.dispose();
    phoneNumberController.dispose();
    stateController.dispose();
    cityController.dispose();
    dev.log('PosTermReqFormModuleController disposed', name: 'PosTermReqForm');
    super.onClose();
  }

  bool validateForm() {
    if (selectedPosId == null) {
      Get.snackbar(
        'Validation Error',
        'Invalid terminal selection. Please go back and retry.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (terminalType.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select terminal type',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (purchaseType.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select purchase type',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (numOfPos.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select number of POS',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (addressDeliveryController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter delivery address',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (selectedState.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select state',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (cityController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter city',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (contactNameController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter contact name',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (contactEmailController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter contact email',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    } else if (!GetUtils.isEmail(contactEmailController.text)) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid email address',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    if (phoneNumberController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter phone number',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    } else if (phoneNumberController.text.length < 11) {
      Get.snackbar(
        'Validation Error',
        'Phone number must be at least 11 digits',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return false;
    }

    return true;
  }

  Future<void> submitPosRequest() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;

      final utilityUrl = box.read('utility_service_url');
      if (utilityUrl == null) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Service configuration error. Please login again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      // Convert purchase type to API format
      String purchaseTypeValue =
          purchaseType.value.toLowerCase().contains('outright')
              ? 'outright'
              : 'lease';

      final body = {
        'pos_id': selectedPosId ?? 1,
        'purchase_type': purchaseTypeValue,
        'quantity': int.parse(numOfPos.value),
        'address': addressDeliveryController.text,
        'city': cityController.text,
        'state': selectedState.value,
        'contact_email': contactEmailController.text,
        'contact_name': contactNameController.text,
        'contact_phone': phoneNumberController.text,
      };

      dev.log('Submitting POS request: $body', name: 'PosTermReqForm');

      final result =
          await apiService.postrequest('${utilityUrl}pos-request', body);

      result.fold(
        (failure) {
          isLoading.value = false;
          dev.log('POS request failed',
              name: 'PosTermReqForm', error: failure.message);
          _showErrorDialog(failure.message);
        },
        (data) {
          isLoading.value = false;
          dev.log('POS request response: $data', name: 'PosTermReqForm');

          // Handle different response scenarios
          if (data['success'] == 1) {
            // Scenario 1: New request successful - has authorization_url
            if (data['data'] != null &&
                data['data']['authorization_url'] != null) {
              _handlePaymentRequired(
                data['data']['authorization_url'],
                data['data']['reference'],
                data['message'] ?? 'Request sent successfully',
              );
            } else {
              // Request successful without payment
              _showSuccessDialog(
                  data['message'] ?? 'Request sent successfully');
            }
          } else if (data['success'] == 0) {
            // Scenario 2 & 3: Existing requests
            if (data['data'] != null &&
                data['data']['authorization_url'] != null) {
              // Scenario 2: Pending request with payment link
              _handlePaymentRequired(
                data['data']['authorization_url'],
                data['data']['reference'],
                data['message'] ?? 'Complete pending payment',
              );
            } else {
              // Scenario 3: Pending request already paid
              _showErrorDialog(data['message'] ?? 'You have a pending request');
            }
          } else {
            _showErrorDialog(data['message'] ?? 'Request failed');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      dev.log('Error submitting POS request', name: 'PosTermReqForm', error: e);
      _showErrorDialog('An error occurred: ${e.toString()}');
    }
  }

  void _handlePaymentRequired(
      String authorizationUrl, String reference, String message) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.payment,
                  size: 32,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Payment Required',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.background,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.background.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _processPayment(authorizationUrl, reference);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.manRope,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    Get.until(
                        (route) => route.settings.name == Routes.POS_HOME);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.manRope,
                      color: AppColors.primaryColor,
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

  Future<void> _processPayment(
      String authorizationUrl, String reference) async {
    try {
      dev.log('Opening Paystack payment URL', name: 'PosTermReqForm');

      // Open payment screen
      final result = await Get.toNamed(
        Routes.PAYSTACK_PAYMENT,
        arguments: {
          'url': authorizationUrl,
          'reference': reference,
        },
      );

      // Verify transaction after payment
      if (result != null && result == true) {
        await _verifyPosPayment(reference);
      } else {
        Get.snackbar(
          'Payment Cancelled',
          'Transaction was not completed',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      dev.log('Error processing POS payment', name: 'PosTermReqForm', error: e);
      Get.snackbar(
        'Error',
        'Failed to process payment: ${e.toString()}',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  Future<void> _verifyPosPayment(String reference) async {
    try {
      dev.log('Verifying POS payment: $reference', name: 'PosTermReqForm');

      // TODO: Payment verification should be done on the backend
      // Secret keys should never be stored in client-side code
      // This method needs to call a backend API to verify the payment
      
      dev.log('Payment verification removed - implement backend verification',
          name: 'PosTermReqForm');
      
      // Temporarily show success until backend verification is implemented
      _showSuccessDialog(
          'Payment submitted! Your POS request has been received.');
          
    } catch (e) {
      dev.log('Error verifying POS payment', name: 'PosTermReqForm', error: e);
      Get.snackbar(
        'Error',
        'Failed to verify payment',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  void _showSuccessDialog(String message) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Success!',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.background,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.background.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.until(
                        (route) => route.settings.name == Routes.POS_HOME);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.manRope,
                      color: Colors.white,
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

  void _showErrorDialog(String message) {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Request Failed',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.background,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.background.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
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
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.manRope,
                      color: Colors.white,
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
}
