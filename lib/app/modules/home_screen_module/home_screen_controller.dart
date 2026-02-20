import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/services.dart';

import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/home_screen_module/model/button_model.dart';
import 'package:mcd/app/modules/home_screen_module/model/dashboard_model.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/mixins/service_availability_mixin.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_api_service.dart';
// import 'package:mcd/core/services/ads_service.dart';

/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class HomeScreenController extends GetxController
    with ServiceAvailabilityMixin {
  var _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final _actionButtonz = <ButtonModel>[].obs;
  List<ButtonModel> get actionButtonz => _actionButtonz;

  final _dashboardData = Rxn<DashboardModel>();
  set dashboardData(value) => _dashboardData.value = value;
  get dashboardData => _dashboardData.value;

  final _isLoading = false.obs;
  set isLoading(value) => _isLoading.value = value;
  get isLoading => _isLoading.value;

  final _errorMessage = ''.obs;
  set errorMessage(value) => _errorMessage.value = value;
  get errorMessage => _errorMessage.value;

  final _gmBalance = '0'.obs;
  set gmBalance(value) => _gmBalance.value = value;
  get gmBalance => _gmBalance.value;
  final _imageSliders = <String>[].obs;
  List<String> get imageSliders => _imageSliders;
  final apiService = DioApiService();
  final box = GetStorage();

  @override
  void onInit() {
    dev.log("HomeScreenController initialized");
    fetchDashboard();
    fetchGMBalance();
    fetchservicestatus();
    super.onInit();
  }

  void updateActionButtons(Map<String, dynamic> services) {
    final allButtons = <ButtonModel>[
      ButtonModel(
          icon: AppAsset.airtime, text: "Airtime", link: Routes.AIRTIME_MODULE),
      ButtonModel(
          icon: AppAsset.internet,
          text: "Internet Data",
          link: Routes.DATA_MODULE),
      ButtonModel(
          icon: AppAsset.tv, text: "Cable Tv", link: Routes.CABLE_MODULE),
      ButtonModel(
          icon: AppAsset.electricity,
          text: "Electricity",
          link: Routes.ELECTRICITY_MODULE),
      ButtonModel(
          icon: AppAsset.ball, text: "Betting", link: Routes.BETTING_MODULE),
      ButtonModel(icon: AppAsset.list, text: "Epins", link: "epin"),
      ButtonModel(
          icon: AppAsset.money,
          text: "Airtime to cash",
          link: Routes.A2C_MODULE),
      ButtonModel(
          icon: AppAsset.docSearch,
          text: "Exams",
          link: Routes.RESULT_CHECKER_MODULE),
      ButtonModel(icon: AppAsset.posIcon, text: "POS", link: Routes.POS_HOME),
      ButtonModel(
          icon: AppAsset.nin,
          text: "NIN Validation",
          link: Routes.NIN_VALIDATION_MODULE),
      ButtonModel(
          icon: AppAsset.gift,
          text: "Reward Centre",
          link: Routes.REWARD_CENTRE_MODULE),
      // ButtonModel(icon: AppAsset.service, text: "Mega Bulk Service", link: ""),
      ButtonModel(icon: 'assets/icons/bank-card-two.svg', text: "Virtual Card", link: Routes.VIRTUAL_CARD_DETAILS),
    ];

    _actionButtonz.assignAll(allButtons);
  }

  @override
  void onReady() {
    super.onReady();
    dev.log(
        "HomeScreenController ready, dashboardData: ${dashboardData != null ? 'loaded' : 'null'}");

    // // Show banner ad
    // AdsService().showBannerAd();

    // Check clipboard for phone number
    _checkClipboardForPhoneNumber();
  }

  @override
  void onClose() {}

  Future<void> fetchDashboard({bool force = false}) async {
    dev.log(
        "fetchDashboard called, force: $force, current data: ${dashboardData != null ? 'exists' : 'null'}");

    // Always fetch if data is null
    if (dashboardData != null && !force) {
      dev.log("Dashboard already loaded, skipping fetch");
      return;
    }

    isLoading = true;
    errorMessage = "";
    dev.log("Starting dashboard fetch...");

    final result =
        await apiService.getrequest("${ApiConstants.authUrlV2}/dashboard");

    result.fold(
      (failure) {
        errorMessage = failure.message;
        dev.log("Dashboard fetch failed: ${failure.message}");
        Get.snackbar("Error", failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
      },
      (data) async {
        dev.log("Dashboard fetch success: ${data.toString()}");
        dashboardData = DashboardModel.fromJson(data);
        dev.log(
            "Dashboard model created - User: ${dashboardData?.user.userName}, Balance: ${dashboardData?.balance.wallet}");

        // save username e.g excade001
        await box.write(
            'biometric_username_real', dashboardData?.user.userName ?? 'MCD');
        dev.log(
            "Biometric username updated in storage: ${box.read('biometric_username_real')}");

        await box.write('user_email', dashboardData?.user.email ?? '');
        dev.log("User email updated in storage: ${box.read('user_email')}");

        if (force) {
          // Get.snackbar("Updated", "Dashboard refreshed", backgroundColor: AppColors.successBgColor, colorText: AppColors.textSnackbarColor);
          dev.log("Dashboard refreshed successfully");
        }
      },
    );

    isLoading = false;
  }

  Future<void> refreshDashboard() async {
    await Future.wait([
      fetchDashboard(force: true),
      fetchGMBalance(),
      fetchservicestatus(),
    ]);
  }

  Future<void> fetchGMBalance() async {
    final transactionUrl = box.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found',
          name: 'HomeScreen', error: 'URL missing');
      return;
    }

    final result =
        await apiService.getrequest('${transactionUrl}gmtransactions');

    result.fold(
      (failure) {
        dev.log('GM balance fetch failed: ${failure.message}',
            name: 'HomeScreen');
      },
      (data) {
        // dev.log('GM balance response: $data', name: 'HomeScreen');

        if (data['wallet'] != null) {
          gmBalance = data['wallet'].toString();
          dev.log('GM balance updated to: ₦$gmBalance', name: 'HomeScreen');
        } else {
          dev.log('Wallet balance not found in response', name: 'HomeScreen');
        }
      },
    );
  }

  Future<void> fetchservicestatus() async {
    var storageresult = box.read('serviceenablingdata');
    if (storageresult != null) {
      var data = jsonDecode(storageresult);
      if (data != null) {
        updateActionButtons(data);
      }
    }
    final transactionUrl = box.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found',
          name: 'HomeScreen', error: 'URL missing');
      return;
    }

    final result = await apiService.getrequest('${transactionUrl}services');

    result.fold(
      (failure) {
        dev.log('Service status fetch failed: ${failure.message}',
            name: 'HomeScreen');
      },
      (data) async {
        dev.log('Service status response: ${data['data']}', name: 'HomeScreen');
        await box.write('serviceenablingdata', jsonEncode(data['data']));
        if (data['data']['services'] != null) {
          updateActionButtons(data['data']['services']);
        }
        // load image sliders from api
        if (data['data']['others']?['image_sliders'] != null) {
          final sliders =
              List<String>.from(data['data']['others']['image_sliders']);
          _imageSliders.assignAll(sliders);
        }
      },
    );
  }

  /// Get service key for API checking based on button text/link
  String getServiceKey(String buttonText, String? link) {
    // Map button text/link to API service keys
    if (buttonText.toLowerCase().contains("airtime")) {
      if (buttonText.toLowerCase().contains("cash")) {
        return "airtimeconverter";
      }
      return "airtime";
    } else if (buttonText.toLowerCase().contains("internet") ||
        buttonText.toLowerCase().contains("data")) {
      return "data";
    } else if (buttonText.toLowerCase().contains("cable") ||
        buttonText.toLowerCase().contains("tv")) {
      return "paytv";
    } else if (buttonText.toLowerCase().contains("electricity")) {
      return "electricity";
    } else if (buttonText.toLowerCase().contains("betting")) {
      return "betting";
    } else if (buttonText.toLowerCase().contains("epin") || link == "epin") {
      return "rechargecard";
    } else if (buttonText.toLowerCase().contains("result")) {
      return "resultchecker";
    } else if (buttonText.toLowerCase().contains("nin")) {
      return "nin_validation";
    } else if (link == Routes.POS_HOME) {
      return "virtual_card";
    } else if (buttonText.toLowerCase().contains("reward")) {
      // Check for spin win, giveaway, etc.
      return "spinwin"; // Default to spinwin for reward centre
    }
    return "";
  }

  /// Handle service button tap with availability check
  Future<bool> handleServiceNavigation(ButtonModel button) async {
    final serviceKey = getServiceKey(button.text, button.link);

    // If no service key mapping, allow navigation (e.g., Mega Bulk Service)
    if (serviceKey.isEmpty) {
      return true;
    }

    // Check service availability
    return await checkAndNavigate(
      serviceKey,
      serviceName: button.text,
    );
  }

  /// Check clipboard for phone number and show dialog
  Future<void> _checkClipboardForPhoneNumber() async {
    try {
      // Check if dialog has already been shown in this session
      final hasShownDialog = box.read('clipboard_dialog_shown') ?? false;
      if (hasShownDialog) {
        dev.log('Clipboard dialog already shown, skipping', name: 'HomeScreen');
        return;
      }

      // Delay to ensure home screen is fully loaded
      await Future.delayed(const Duration(milliseconds: 500));

      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null &&
          clipboardData.text != null &&
          clipboardData.text!.isNotEmpty) {
        String phoneNumber = clipboardData.text!;
        phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

        // Normalize Nigerian phone numbers
        if (phoneNumber.startsWith('234')) {
          phoneNumber = '0${phoneNumber.substring(3)}';
        } else if (phoneNumber.startsWith('+234')) {
          phoneNumber = '0${phoneNumber.substring(4)}';
        } else if (!phoneNumber.startsWith('0') && phoneNumber.length == 10) {
          phoneNumber = '0$phoneNumber';
        }

        // Check if it's a valid 11-digit Nigerian phone number
        if (phoneNumber.length == 11 && phoneNumber.startsWith('0')) {
          dev.log('Valid phone number detected in clipboard: $phoneNumber',
              name: 'HomeScreen');
          // Mark dialog as shown
          await box.write('clipboard_dialog_shown', true);
          // Verify the network first
          await _verifyAndShowDialog(phoneNumber);
        }
      }
    } catch (e) {
      dev.log('Error checking clipboard: $e', name: 'HomeScreen');
    }
  }

  /// Verify network and show dialog with network info
  Future<void> _verifyAndShowDialog(String phoneNumber) async {
    final transactionUrl = box.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found', name: 'HomeScreen');
      return;
    }

    final body = {
      "service": "airtime",
      "provider": "Ng",
      "number": phoneNumber,
    };

    final result =
        await apiService.postrequest('${transactionUrl}validate-number', body);

    result.fold(
      (failure) {
        dev.log('Network verification failed: ${failure.message}',
            name: 'HomeScreen');
        // Show dialog without network info
        _showClipboardPhoneDialog(phoneNumber, 'Unknown', {});
      },
      (data) {
        if (data['success'] == 1) {
          final networkName =
              data['data']?['operatorName'] ?? 'Unknown Network';
          final networkData = data['data'] ?? {};
          dev.log('Network verified: $networkName', name: 'HomeScreen');
          _showClipboardPhoneDialog(phoneNumber, networkName, networkData);
        } else {
          // Show dialog without network info
          _showClipboardPhoneDialog(phoneNumber, 'Unknown', {});
        }
      },
    );
  }

  /// Show dialog when phone number is detected in clipboard
  void _showClipboardPhoneDialog(String phoneNumber, String networkName,
      Map<String, dynamic> networkData) {
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: '',
      barrierDismissible: true,
      content: Padding(
        padding: const EdgeInsets.only(
            top: 0, left: 24.0, right: 24.0, bottom: 16.0),
        child: Column(
          children: [
            // Image.asset('assets/images/mcdagentlogo.png', height: 80),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Mega Cheap Data detected ",
                style: const TextStyle(
                  color: AppColors.background,
                  fontFamily: AppFonts.manRope,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                children: const [
                  TextSpan(
                    text: "in your clipboard.",
                    style: TextStyle(fontFamily: AppFonts.manRope),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(250, 250, 250, 1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/mcdagentlogo.png', height: 40),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          phoneNumber,
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontFamily: AppFonts.manRope,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          networkName,
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontFamily: AppFonts.manRope,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _dialogButton(
              'Cancel',
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.primaryColor,
            ).onTap(() {
              Get.back();
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dialogButton(
                    'Send Airtime',
                    AppColors.primaryColor,
                    Colors.white,
                  ).onTap(() {
                    Get.back();
                    // Navigate directly to airtime module with verified data
                    Get.toNamed(Routes.AIRTIME_MODULE, arguments: {
                      'verifiedNumber': phoneNumber,
                      'verifiedNetwork': networkName,
                      'networkData': networkData,
                    });
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dialogButton(
                    'Send Data',
                    AppColors.primaryColor,
                    Colors.white,
                  ).onTap(() {
                    Get.back();
                    // Navigate directly to data module with verified data
                    Get.toNamed(Routes.DATA_MODULE, arguments: {
                      'verifiedNumber': phoneNumber,
                      'verifiedNetwork': networkName,
                      'networkData': networkData,
                    });
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog button widget
  Widget _dialogButton(String text, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontFamily: AppFonts.manRope,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

extension on Widget {
  Widget onTap(void Function()? callback) {
    return GestureDetector(
      onTap: callback,
      child: this,
    );
  }
}
