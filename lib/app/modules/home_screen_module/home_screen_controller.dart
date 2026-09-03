import 'dart:developer' as dev;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/modules/home_screen_module/model/button_model.dart';
import 'package:mcd/app/modules/home_screen_module/model/dashboard_model.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/controllers/service_status_controller.dart';
import 'package:mcd/core/mixins/service_availability_mixin.dart';
import 'package:mcd/core/services/notification_permission_service.dart';
import 'package:mcd/core/services/dashboard_service.dart';
import 'package:mcd/core/services/deep_link_service.dart';
import 'package:mcd/core/services/dialog_manager_service.dart';

import '../../../core/network/dio_api_service.dart';
// import 'package:mcd/core/services/ads_service.dart';

/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class HomeScreenController extends GetxController
    with ServiceAvailabilityMixin, StateMixin {
  var _obj = ''.obs;
  set obj(value) => _obj.value = value;
  get obj => _obj.value;

  final actionButtonz = <ButtonModel>[].obs;

  DashboardModel? get dashboardData => DashboardService.to.dashboardData.value;
  bool get isLoading => DashboardService.to.isLoadingDashboard.value;
  String get errorMessage => DashboardService.to.errorMessage.value;
  String get gmBalance => DashboardService.to.gmBalance.value;

  final isBalanceVisible = true.obs;

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
    box.write('is_balance_visible', isBalanceVisible.value);
  }

  final imageSliders = <String>[].obs;
  final apiService = DioApiService();
  final box = GetStorage();

  @override
  void onInit() {
    dev.log("HomeScreenController initialized");

    isBalanceVisible.value = box.read('is_balance_visible') ?? true;

    final token = box.read('token');
    if (token == null || token.toString().isEmpty) {
      dev.log("No token found, skipping dashboard fetch in onInit");
      return;
    }

    unawaited(_bootstrapAfterLogin());

    // react to future updates from ServiceStatusController
    final ssc = ServiceStatusController.to;
    ever(ssc.serviceStatus, (_) => _loadServiceData());

    change(null, status: RxStatus.success());
    super.onInit();
  }

  Future<void> _bootstrapAfterLogin() async {
    try {
      await Future.wait([
        fetchDashboard(force: true),
        fetchGMBalance(),
      ]);

      _loadServiceData();
      
      // TODO: Replace this placeholder with the actual marketing dialog condition
      DialogManagerService.to.addDialog(
        DialogRequest(
          priority: DialogPriority.marketing,
          showDialog: () async {
            if (Get.context != null) {
              await _showMarketingPlaceholderDialog();
            }
          },
        ),
      );
      
    } finally {
      try {
        Get.find<LoginScreenController>().dismissLoadingDialog();
      } catch (e) {
        dev.log('Unable to dismiss login loader: $e', name: 'HomeScreen');
      }
    }
  }

  Future<void> _showMarketingPlaceholderDialog() async {
    await Get.defaultDialog(
      title: 'Special Offer!',
      middleText: 'This is a placeholder for the new marketing dialog.',
      textConfirm: 'Got it',
      buttonColor: AppColors.primaryColor,
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  void updateActionButtons(Map<String, dynamic> services) {
    // maps button service key -> services map key
    const keyMap = {
      'Data': 'data',
      'Airtime': 'airtime',
      'Cable Tv': 'paytv',
      'Electricity': 'electricity',
      'Betting': 'betting',
      'Epins': 'rechargecard',
      'Airtime to cash': 'airtimeconverter',
      'Exams': 'resultchecker',
      'NIN Validation': 'nin_validation',
      'Virtual Card': 'virtual_card',
    };

    bool isEnabled(String buttonText) {
      final key = keyMap[buttonText];
      if (key == null) return true; // no key = always show (POS, Reward Centre)
      final val = services[key];
      return val == null || val.toString() == '1';
    }

    final allButtons = <ButtonModel>[
      ButtonModel(
          icon: AppAsset.internet, text: "Data", link: Routes.DATA_MODULE),
      ButtonModel(
          icon: AppAsset.airtime, text: "Airtime", link: Routes.AIRTIME_MODULE),
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
          icon: AppAsset.capOne,
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
      ButtonModel(
          icon: 'assets/icons/bank-card-two.svg',
          text: "Virtual Card",
          link: Routes.VIRTUAL_CARD_DETAILS),
      ButtonModel(
          icon: AppAsset.service,
          text: "Store Front",
          link: Routes.STORE_FRONT),
    ];

    final filtered = allButtons.where((b) => isEnabled(b.text)).toList();
    dev.log('Service buttons: ${filtered.map((b) => b.text).join(', ')}',
        name: 'HomeScreen');
    actionButtonz.assignAll(filtered);
  }

  @override
  void onReady() {
    super.onReady();
    dev.log(
        "HomeScreenController ready, dashboardData: ${dashboardData != null ? 'loaded' : 'null'}");

    _checkNotificationPermission(); // Check for notification permission (Android only)

    // // Show banner ad
    // AdsService().showBannerAd();

    // Check clipboard for phone number
    // _checkClipboardForPhoneNumber();

    try {
      final deepLinkService = DeepLinkService.to;
      deepLinkService.markNavigationReady();
      deepLinkService.consumePendingDeepLink();
    } catch (e) {
      dev.log('error consuming pending deep link: $e', name: 'HomeScreen');
    }
  }

  Future<void> _checkNotificationPermission() async {
    // Delay slightly to ensure layout is ready and other dialogs don't overlap
    await Future.delayed(const Duration(seconds: 2));

    await NotificationPermissionService.ensurePermissionOnAppOpen();
  }

  @override
  void onClose() {}

  Future<void> fetchDashboard({bool force = false}) async {
    await DashboardService.to.fetchDashboard(force: force);
    
    // show news dialog if logging in
    if (box.read('show_news_dialog') == true &&
        dashboardData?.news != null &&
        dashboardData!.news.isNotEmpty) {
      await box.write('show_news_dialog', false);
      
      DialogManagerService.to.addDialog(
        DialogRequest(
          priority: DialogPriority.news,
          showDialog: () async {
            if (Get.context != null) {
              await _showNewsDialog(dashboardData!.news);
            }
          },
        ),
      );
      
      dev.log("news ${dashboardData?.news}");
    }
  }

  Future<void> _showNewsDialog(String news) async {
    if (Get.context == null) return;

    await Get.dialog(Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    // Circular image header
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF1C1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset(
                            'assets/images/celebrate.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Latest News',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      news,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppFonts.manRope,
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Thanks!',
                          style: TextStyle(
                            fontFamily: AppFonts.manRope,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> refreshDashboard() async {
    await Future.wait([
      fetchDashboard(force: true),
      fetchGMBalance(),
      ServiceStatusController.to.fetchServiceStatus(),
    ]);
    // service data updates reactively via the ever() listener
  }

  Future<void> fetchGMBalance() async {
    await DashboardService.to.fetchGMBalance();
  }

  // reads service data from ServiceStatusController — no own API call
  void _loadServiceData() {
    try {
      final ssc = ServiceStatusController.to;
      final rawServices = ssc.getRawServices();
      if (rawServices.isNotEmpty) {
        updateActionButtons(rawServices);
      }

      final sliders = ssc.getImageSliders();
      if (sliders.isNotEmpty) {
        imageSliders.assignAll(sliders);
      }
    } catch (e) {
      dev.log('Error loading service data: $e', name: 'HomeScreen');
    }
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
    } else if (buttonText.toLowerCase().contains("virtual card") ||
        link == Routes.VIRTUAL_CARD_DETAILS ||
        link == Routes.VIRTUAL_CARD_HOME) {
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
  Future<void> checkClipboardForPhoneNumber() async {
    dev.log('_checkClipboardForPhoneNumber initiated');
    try {
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

        // Check if dialog has already been shown in this session
        final hasShownDialog =
            box.read('clipboard_dialog_shown') == phoneNumber;
        if (hasShownDialog) {
          dev.log('Clipboard dialog already shown, skipping',
              name: 'HomeScreen');
          return;
        }

        // Check if it's a valid 11-digit Nigerian phone number
        if (phoneNumber.length == 11 && phoneNumber.startsWith('0')) {
          dev.log('Valid phone number detected in clipboard: $phoneNumber',
              name: 'HomeScreen');
          // Mark dialog as shown
          await box.write('clipboard_dialog_shown', phoneNumber);
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
        DialogManagerService.to.addDialog(
          DialogRequest(
            priority: DialogPriority.clipboard,
            showDialog: () async {
              await _showClipboardPhoneDialog(phoneNumber, 'Unknown', {});
            },
          ),
        );
      },
      (data) {
        if (data['success'] == 1) {
          final networkName =
              data['data']?['operatorName'] ?? 'Unknown Network';
          final networkData = data['data'] ?? {};
          dev.log('Network verified: $networkName', name: 'HomeScreen');
          DialogManagerService.to.addDialog(
            DialogRequest(
              priority: DialogPriority.clipboard,
              showDialog: () async {
                await _showClipboardPhoneDialog(phoneNumber, networkName, networkData);
              },
            ),
          );
        } else {
          // Show dialog without network info
          // _showClipboardPhoneDialog(phoneNumber, 'Unknown', {});
        }
      },
    );
  }

  /// Show dialog when phone number is detected in clipboard
  Future<void> _showClipboardPhoneDialog(String phoneNumber, String networkName,
      Map<String, dynamic> networkData) async {
    await Get.defaultDialog(
      backgroundColor: Colors.white,
      title: '',
      barrierDismissible: true,
      content: Padding(
        padding: const EdgeInsets.only(
            top: 0, left: 24.0, right: 24.0, bottom: 16.0),
        child: Column(
          children: [
            Image.asset('assets/images/number_detected_ico.png', height: 55),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Mega Cheap Data detected phone number ",
                style: const TextStyle(
                  color: Color(0xff727272),
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
                borderRadius: BorderRadius.circular(35),
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
                      Container(
                        width: 70,
                        child: Text(
                          networkName,
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: AppFonts.manRope,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis),
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
                    AppColors.primaryColor2,
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
                    AppColors.primaryColor2,
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
        borderRadius: BorderRadius.circular(35),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontFamily: AppFonts.manRope,
            fontWeight: FontWeight.w700,
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
