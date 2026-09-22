import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/import/imports.dart';
import '../../utils/bottom_navigation.dart';
import '../../widgets/app_bar.dart';

/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: HomeScreenController(),
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            return await _showExitDialog(context) ?? false;
          },
          child: Obx(() {
            return Scaffold(
              appBar: PaylonyAppBar(
                title:
                    "Hello ${controller.dashboardData?.user.userName ?? 'User'} 👋🏼",
                elevation: 0,
                actions: [
                  TouchableOpacity(
                      child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.QRCODE_MODULE);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/bx_scan.svg',
                            colorFilter: const ColorFilter.mode(
                                Colors.black, BlendMode.srcIn),
                          ))),
                  const Gap(10),
                  TouchableOpacity(
                      child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.NOTIFICATION_MODULE);
                          },
                          child: SvgPicture.asset(AppAsset.notificationIicon))),
                  const Gap(12)
                ],
              ),
              body: RefreshIndicator(
                color: AppColors.primaryColor,
                backgroundColor: AppColors.white,
                onRefresh: controller.refreshDashboard,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Obx(() => Skeletonizer(
                        enabled: controller.isLoading,
                        child: ListView(
                          children: [
                            const Gap(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routes.MORE_MODULE,
                                        arguments: {'initialTab': 1});
                                  },
                                  child: Container(
                                    width: screenWidth(context) * 0.4,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.primaryGrey2),
                                        borderRadius: BorderRadius.circular(6)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextSemiBold(
                                          controller
                                                      .dashboardData
                                                      ?.user
                                                      .referralPlan
                                                      .isNotEmpty ==
                                                  true
                                              ? controller.dashboardData!.user
                                                  .referralPlan
                                                  .toUpperCase()
                                              : "FREE",
                                          fontSize: 14,
                                          color: AppColors.background
                                              .withOpacity(0.7),
                                        ),
                                        const Icon(
                                            Icons.arrow_forward_ios_outlined)
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(20),
                            _buildWalletCard(controller, context),
                            const Gap(15),
                            SizedBox(
                              height: screenHeight(context) * 0.03,
                              child: Marquee(
                                text: controller.dashboardData?.cleanNews ??
                                    'Welcome to Mega Cheap Data',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: AppFonts.manRope),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                blankSpace: 50.0,
                                velocity: 50.0,
                                pauseAfterRound: const Duration(seconds: 1),
                                startPadding: 10.0,
                                accelerationDuration:
                                    const Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration:
                                    const Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
                              ),
                            ),
                            const Divider(
                              color: AppColors.boxColor,
                            ),
                            const Gap(10),
                            _buildQuickActionsRow(controller, context),
                            const Divider(
                              color: AppColors.boxColor,
                            ),
                            const Gap(20),
                            _buildStaticCarousel(context),
                            const Gap(20),
                            _buildTopEarners(context),
                            const Gap(20),
                            controller.imageSliders.isNotEmpty
                                ? _buildImageSlider(controller)
                                : controller.isLoading &&
                                        controller.imageSliders.isEmpty
                                    ? Container(
                                        height: 200,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                            const Gap(30),
                          ],
                        ),
                      )),
                ),
              ),
              bottomNavigationBar: const BottomNavigation(
                selectedIndex: 0,
              ),
            );
          }),
        );
      },
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: TextSemiBold('Exit App'),
        content: TextSemiBold('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: TextSemiBold(
              'No',
              color: AppColors.textPrimaryColor,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: TextSemiBold(
              'Yes',
              color: AppColors.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showResultCheckerOptions(
      BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final options = [
          {
            'title': 'Result Checker Token',
            'type': 'token',
            'route': Routes.RESULT_CHECKER_MODULE,
            'serviceKey': 'resultchecker'
          },
          {
            'title': 'JAMB Pin',
            'type': 'jamb',
            'route': Routes.JAMB_MODULE,
            'serviceKey': 'jamb'
          },
        ];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...options.map((option) {
                final isAvailable = controller
                    .isServiceAvailable(option['serviceKey'] as String);
                return Opacity(
                  opacity: isAvailable ? 1.0 : 0.5,
                  child: TouchableOpacity(
                    onTap: () async {
                      await controller.checkAndNavigate(
                        option['serviceKey'] as String,
                        serviceName: option['title'] as String,
                        onAvailable: () {
                          Navigator.pop(context);
                          Get.toNamed(
                            option['route'] as String,
                            arguments: {'type': option['type']},
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.background,
                              fontFamily: AppFonts.manRope,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.background,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Gap(10),
            ],
          ),
        );
      },
    );
  }

  void _showEpinOptionsBottomSheet(
      BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final options = [
          {
            'title': 'Airtime Pin',
            'route': Routes.AIRTIME_PIN_MODULE,
            'serviceKey': 'airtime_pin'
          },
          {
            'title': 'Data Pin',
            'route': Routes.DATA_PIN,
            'serviceKey': 'data_pin'
          },
          {'title': 'Recharge Card', 'route': '', 'serviceKey': 'rechargecard'},
        ];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TextSemiBold(
              //   'Select E-Pin Service',
              //   fontSize: 18,
              //   color: AppColors.primaryColor,
              // ),
              const Gap(20),
              ...options.map((option) {
                final isAvailable = controller
                    .isServiceAvailable(option['serviceKey'] as String);
                return Opacity(
                  opacity: isAvailable ? 1.0 : 0.5,
                  child: TouchableOpacity(
                    onTap: () async {
                      final serviceKey = option['serviceKey'] as String;
                      final title = option['title'] as String;
                      final route = option['route'] as String;

                      await controller.checkAndNavigate(
                        serviceKey,
                        serviceName: title,
                        onAvailable: () {
                          Navigator.pop(context);
                          if (serviceKey == 'rechargecard') {
                            launchUrl(
                              Uri.parse(
                                  'https://rechargecardportal.5starcompany.com.ng/authentication/login'),
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            Get.toNamed(route);
                          }
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'] as String,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.background,
                                  ),
                                ),
                                if (!isAvailable) ...[
                                  const Gap(4),
                                  const Text(
                                    'E-pin service is currently unavailable. Please try again later.',
                                    style: TextStyle(
                                      fontFamily: AppFonts.manRope,
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.background,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Gap(40),
            ],
          ),
        );
      },
    );
  }

  void _showAirtimeSelectionBottomSheet(
      BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final options = [
          {'title': 'Nigeria', 'isForeign': false, 'serviceKey': 'airtime'},
          {
            'title': 'Other Countries',
            'isForeign': true,
            'serviceKey': 'foreign_airtime'
          },
        ];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              ...options.map((option) {
                final isAvailable = controller
                    .isServiceAvailable(option['serviceKey'] as String);
                return Opacity(
                  opacity: isAvailable ? 1.0 : 0.5,
                  child: TouchableOpacity(
                    onTap: () async {
                      await controller.checkAndNavigate(
                        option['serviceKey'] as String,
                        serviceName: option['title'] as String,
                        onAvailable: () {
                          Navigator.pop(context);
                          if (option['isForeign'] as bool) {
                            Get.toNamed(Routes.COUNTRY_SELECTION, arguments: {
                              'redirectTo': Routes.AIRTIME_MODULE
                            });
                          } else {
                            Get.toNamed(Routes.NUMBER_VERIFICATION_MODULE,
                                arguments: {
                                  'redirectTo': Routes.AIRTIME_MODULE
                                });
                          }
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'] as String,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.background,
                                  ),
                                ),
                                if (!isAvailable) ...[
                                  const Gap(4),
                                  const Text(
                                    'This service is currently unavailable. Please try again later.',
                                    style: TextStyle(
                                      fontFamily: AppFonts.manRope,
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.background,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Gap(40),
            ],
          ),
        );
      },
    );
  }

  void _showDataSelectionBottomSheet(
      BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        final options = [
          {'title': 'Nigeria', 'isForeign': false, 'serviceKey': 'data'},
          {
            'title': 'Other Countries',
            'isForeign': true,
            'serviceKey': 'foreign_data'
          },
        ];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              ...options.map((option) {
                final isAvailable = controller
                    .isServiceAvailable(option['serviceKey'] as String);
                return Opacity(
                  opacity: isAvailable ? 1.0 : 0.5,
                  child: TouchableOpacity(
                    onTap: () async {
                      await controller.checkAndNavigate(
                        option['serviceKey'] as String,
                        serviceName: option['title'] as String,
                        onAvailable: () {
                          Navigator.pop(context);
                          if (option['isForeign'] as bool) {
                            Get.toNamed(Routes.COUNTRY_SELECTION,
                                arguments: {'redirectTo': Routes.DATA_MODULE});
                          } else {
                            Get.toNamed(Routes.NUMBER_VERIFICATION_MODULE,
                                arguments: {'redirectTo': Routes.DATA_MODULE});
                          }
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'] as String,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.background,
                                  ),
                                ),
                                if (!isAvailable) ...[
                                  const Gap(4),
                                  const Text(
                                    'This service is currently unavailable. Please try again later.',
                                    style: TextStyle(
                                      fontFamily: AppFonts.manRope,
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.background,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Gap(40),
            ],
          ),
        );
      },
    );
  }

  Widget dataItem(String name, String amount) {
    return Column(
      children: [
        Text(
          amount,
          style: GoogleFonts.plusJakartaSans(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
        const Gap(10),
        TextSemiBold(
          name,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        )
      ],
    );
  }

  Widget _buildWalletCard(HomeScreenController controller, BuildContext context) {
    final accs = controller.dashboardData?.virtualAccounts;
    String accountText = "Loading...";
    if (accs != null) {
      if (accs.hasPrimary) {
        accountText = "${accs.primaryAccountNumber} | ${accs.primaryBankName} | MCD-${controller.dashboardData?.user.userName ?? ''}";
      } else {
        accountText = "No Virtual Account";
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  accountText,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: AppFonts.manRope),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                   if (accs?.hasPrimary ?? false) {
                     Clipboard.setData(ClipboardData(text: accs!.primaryAccountNumber));
                     Get.snackbar('Copied', 'Account number copied to clipboard', backgroundColor: AppColors.primaryColor, colorText: Colors.white);
                   }
                },
                child: const Icon(Icons.copy, color: Colors.white, size: 16),
              )
            ],
          ),
          const Gap(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                controller.isBalanceVisible.value ? '₦ ' : '',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, fontFamily: AppFonts.manRope),
              ),
              Text(
                controller.isBalanceVisible.value 
                  ? AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.wallet ?? '0') ?? 0)
                  : '****',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, fontFamily: AppFonts.manRope),
              ),
              const Gap(10),
              GestureDetector(
                onTap: () => controller.toggleBalanceVisibility(),
                child: Icon(
                  controller.isBalanceVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const Gap(5),
          const Text(
            "Last Updated 2 Sec ago",
            style: TextStyle(color: Colors.white70, fontSize: 10, fontFamily: AppFonts.manRope),
          ),
          const Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _walletActionButton(icon: Icons.add, text: 'Add money', onTap: () {
                Get.toNamed(Routes.ADD_MONEY_MODULE, arguments: {'dashboardData': controller.dashboardData});
              }),
              _walletActionButton(svgIcon: 'assets/icons/home/history.svg', text: 'History', onTap: () {
                Get.offAllNamed(Routes.HISTORY_SCREEN);
              }),
              _walletActionButton(svgIcon: 'assets/icons/home/wallet.svg', text: 'Wallets', onTap: () {
                _showWalletsBottomSheet(context, controller);
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _walletActionButton({IconData? icon, String? svgIcon, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 16),
            if (svgIcon != null) SvgPicture.asset(svgIcon, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn), height: 16),
            const Gap(6),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: AppFonts.manRope)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(HomeScreenController controller, BuildContext context) {
    if (controller.isLoading && controller.actionButtonz.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.actionButtonz.map((button) {
          final serviceKey = controller.getServiceKey(button.text, button.link);
          final isAvailable = serviceKey.isEmpty || controller.isServiceAvailable(serviceKey);

          return Opacity(
            opacity: isAvailable ? 1.0 : 0.5,
            child: GestureDetector(
              onTap: () async {
                final isAvailable = await controller.handleServiceNavigation(button);
                if (!isAvailable) return;

                if (!context.mounted) return;

                if (button.link == Routes.RESULT_CHECKER_MODULE) {
                  _showResultCheckerOptions(context, controller);
                } else if (button.link == "epin") {
                  _showEpinOptionsBottomSheet(context, controller);
                } else if (button.link == Routes.AIRTIME_MODULE) {
                  _showAirtimeSelectionBottomSheet(context, controller);
                } else if (button.link == Routes.DATA_MODULE) {
                  _showDataSelectionBottomSheet(context, controller);
                } else if (button.link.isNotEmpty) {
                  Get.toNamed(button.link);
                }
              },
              child: SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xffF3FFF7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          button.icon,
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(AppColors.primaryColor2, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    const Gap(8),
                    Text(
                      button.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primaryColor2,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showWalletsBottomSheet(BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSemiBold("Other Wallets", fontSize: 16),
              const Gap(20),
              _walletItem("Commission", "₦ ${AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.commission ?? '0.00') ?? 0)}"),
              _walletItem("Points", AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.points ?? '0') ?? 0)),
              _walletItem("Bonus", "₦ ${AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.bonus ?? '0.00') ?? 0)}"),
              _walletItem("General Market", "₦ ${AmountUtil.formatFigure(double.tryParse(controller.gmBalance ?? '0.00') ?? 0)}"),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticCarousel(BuildContext context) {
    final items = [
      {
        'title': 'Daily Bonus',
        'subtitle': 'Claim free cash daily',
        'image': 'assets/images/home_carousel/green-gift.png',
        'icon': 'assets/icons/home/daily-bonus-icon.svg',
        'action': () {
          Get.toNamed('/free_money');
        }
      },
      {
        'title': 'Mega Sale',
        'subtitle': 'Get up to 50% off',
        'image': 'assets/images/home_carousel/mega-sale.png',
        'icon': 'assets/icons/home/mega-sale-icon.svg',
        'action': () {
           
        }
      },
      {
        'title': 'Refer & Earn',
        'subtitle': 'Earn when you refer',
        'image': 'assets/images/home_carousel/refer.png',
        'icon': 'assets/icons/home/refer-icon.svg',
        'action': () {
          Get.toNamed(Routes.REFERRAL_LIST_MODULE);
        }
      }
    ];

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
           final item = items[index];
           return GestureDetector(
             onTap: item['action'] as VoidCallback,
             child: Container(
               width: 280,
               margin: const EdgeInsets.only(right: 12),
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(16),
                 image: DecorationImage(
                   image: AssetImage(item['image'] as String),
                   fit: BoxFit.cover,
                 ),
               ),
               child: Stack(
                 children: [
                   Positioned(
                     left: 16,
                     top: 0,
                     bottom: 0,
                     child: Center(
                       child: Container(
                         width: 45,
                         height: 45,
                         decoration: const BoxDecoration(
                           color: AppColors.primaryColor,
                           shape: BoxShape.circle,
                         ),
                         child: Center(
                           child: SvgPicture.asset(
                             item['icon'] as String,
                             colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                             width: 20,
                           ),
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             )
           );
        }
      )
    );
  }

  Widget _buildTopEarners(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top Earners!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.manRope,
                  color: AppColors.background,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.LEADERBOARD_MODULE),
                child: const Text(
                  "See all",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.manRope,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const Gap(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTopEarnerAvatar('assets/images/leaderboard/second.png', 2, 70),
              _buildTopEarnerAvatar('assets/images/leaderboard/first.png', 1, 90),
              _buildTopEarnerAvatar('assets/images/leaderboard/third.png', 3, 70),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTopEarnerAvatar(String imagePath, int rank, double size) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: rank == 1 ? AppColors.primaryColor : Colors.grey.shade300, width: 3),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _walletItem(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontFamily: AppFonts.manRope)),
          TextSemiBold(amount, fontSize: 14, color: AppColors.primaryColor),
        ],
      ),
    );
  }

  Widget _buildImageSlider(HomeScreenController controller) {
    return _ImageSliderWidget(
      images: controller.imageSliders,
    );
  }
}

class _ImageSliderWidget extends StatefulWidget {
  final List<String> images;

  const _ImageSliderWidget({required this.images});

  @override
  State<_ImageSliderWidget> createState() => _ImageSliderWidgetState();
}

class _ImageSliderWidgetState extends State<_ImageSliderWidget> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  static const _kStartPage = 1000;

  @override
  void initState() {
    super.initState();
    _currentPage = _kStartPage;
    _pageController = PageController(initialPage: _currentPage);
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(_ImageSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != oldWidget.images) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.images.isEmpty || !mounted) return;

      _currentPage++;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GestureDetector(
            onPanDown: (_) => _stopAutoSlide(),
            onPanCancel: () => _startAutoSlide(),
            onPanEnd: (_) => _startAutoSlide(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final actualIndex = index % widget.images.length;
                return _ImageItem(url: widget.images[actualIndex]);
              },
            ),
          ),
        ),
        const Gap(10),
        // slider indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (index) {
              final isActive = (_currentPage % widget.images.length) == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? AppColors.primaryColor : Colors.grey[300],
                ),
              );
            },
          ),
        ),
        const Gap(15),
      ],
    );
  }
}

class _ImageItem extends StatefulWidget {
  final String url;

  const _ImageItem({required this.url});

  @override
  State<_ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<_ImageItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
          placeholder: (context, url) => Container(
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            // dev.log("failure: error loading image $url: $error".toLowerCase());
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 30,
                      color: Colors.grey[400],
                    ),
                    const Gap(4),
                    Text(
                      "Image Failed",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontFamily: AppFonts.manRope),
                    )
                  ],
                ),
              ),
            );
          },
          imageBuilder: (context, imageProvider) {
            return _LoggedImage(imageProvider: imageProvider, url: widget.url);
          },
        ),
      ),
    );
  }
}

class _LoggedImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final String url;

  const _LoggedImage({required this.imageProvider, required this.url});

  @override
  State<_LoggedImage> createState() => _LoggedImageState();
}

class _LoggedImageState extends State<_LoggedImage> {
  @override
  void initState() {
    super.initState();
    // Log success message exactly as requested
    // dev.log("success: image loaded ${widget.url}".toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.imageProvider,
      fit: BoxFit.cover,
    );
  }
}
