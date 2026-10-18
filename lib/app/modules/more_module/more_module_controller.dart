import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:share_plus/share_plus.dart';

import '../home_screen_module/model/dashboard_model.dart';

class MoreModuleController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final box = GetStorage();

  late TabController tabController;

  final dashboardDataRx = Rxn<DashboardModel>();
  DashboardModel? get dashboardData => dashboardDataRx.value;
  set dashboardData(DashboardModel? value) => dashboardDataRx.value = value;

  int? _handledTabArg;

  void switchTab(int index) {
    if (index >= 0 && index < 5) {
      _handledTabArg = index;
      if (tabController.index != index) {
        tabController.animateTo(index);
      }
    }
  }

  void checkAndApplyTabArgument(int tab) {
    if (_handledTabArg != tab) {
      switchTab(tab);
    }
  }

  @override
  void onInit() {
    super.onInit();
    final currentArgs = Get.arguments as Map<String, dynamic>?;
    final initialTab = currentArgs?['initialTab'] as int?;
    final startIndex = (initialTab != null && initialTab >= 0 && initialTab < 5)
        ? initialTab
        : 0;

    _handledTabArg = startIndex;

    tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: startIndex,
    );

    final cachedData = box.read('cached_dashboard');
    if (cachedData != null) {
      try {
        dashboardData = DashboardModel.fromJson(cachedData);
        dev.log("Dashboard loaded from local cache");
      } catch (e) {
        dev.log("Error loading dashboard from cache: $e");
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    final currentArgs = Get.arguments as Map<String, dynamic>?;
    final initialTab = currentArgs?['initialTab'] as int?;
    if (initialTab != null && initialTab >= 0 && initialTab < 5) {
      Future.delayed(const Duration(milliseconds: 100), () {
        switchTab(initialTab);
      });
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // get user's referral code (username) from local storage
  String getReferralCode() {
    // First try to get from local storage (faster, no API wait)
    final storedUsername = box.read('biometric_username_real');
    if (storedUsername != null && storedUsername.toString().isNotEmpty) {
      return storedUsername.toString();
    }
    // Fallback to dashboard data if local storage is empty
    return dashboardData?.user.userName ?? '';
  }

  // copy referral code to clipboard
  Future<void> copyReferralCode() async {
    final referralCode = getReferralCode();
    if (referralCode.isEmpty) {
      Get.snackbar(
        'Notice',
        'Referral code not available. Please check your account profile.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: referralCode));
    Get.snackbar(
      'Copied!',
      'Referral code copied to clipboard',
      backgroundColor: AppColors.successBgColor,
      colorText: AppColors.textSnackbarColor,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  // share referral code
  Future<void> shareReferralCode() async {
    final referralCode = getReferralCode();
    if (referralCode.isEmpty) {
      Get.snackbar(
        'Notice',
        'Referral code not available. Please check your account profile.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final message = '''
🎉 Join me on MEGA Cheap Data (MCD)!

Use my referral code: $referralCode

Enjoy cheap data plans, airtime top-ups, instant bill payments, and earn exciting bonuses! 🚀

Download the app now:
https://play.google.com/store/apps/details?id=a5starcompany.com.megacheapdata
'''.trim();

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'Join MEGA Cheap Data - Referral Code: $referralCode',
        ),
      );
    } catch (e) {
      dev.log('Error sharing referral code: $e', name: 'MoreModuleController');
      Get.snackbar(
        'Error',
        'Could not share referral code. Please try again.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // navigate to referral list
  void viewReferralList() {
    Get.toNamed(Routes.REFERRAL_LIST_MODULE);
  }

  Future<void> deleteAccount() async {
    var mail =
        "mailto:info@5starcompany.com.ng?subject=Account Deletion by ${getReferralCode()}&body=I want to apply for the account deletion";
    var url = Uri.parse(mail).toString();
    await launchUrl(Uri.parse(url));
  }

}
