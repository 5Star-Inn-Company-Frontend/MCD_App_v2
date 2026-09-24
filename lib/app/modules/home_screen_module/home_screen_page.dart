import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:mcd/app/modules/home_screen_module/model/button_model.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/import/imports.dart';
import '../../utils/bottom_navigation.dart';
import '../../widgets/app_bar.dart';
import 'package:mcd/core/services/leaderboard_service.dart';
import 'package:mcd/app/modules/leaderboard_module/models/leaderboard_model.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;

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
                            'assets/icons/home/qr-code.svg',
                          ))),
                  const Gap(10),
                  TouchableOpacity(
                      child: InkWell(
                          onTap: () {
                            Get.toNamed(Routes.NOTIFICATION_MODULE);
                          },
                          child: SvgPicture.asset('assets/icons/home/alarm-icon.svg'))),
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
                        effect: ShimmerEffect(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                        ),
                        child: ListView(
                          children: [
                            const Gap(20),
                            _buildWalletCard(controller, context),
                            const Gap(20),
                            _buildQuickActionsRow(controller, context),
                            const Gap(20),
                            Skeleton.ignore(
                              child: _buildStaticCarousel(context),
                            ),
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
  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} sec${diff.inSeconds == 1 ? '' : 's'} ago";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago";
    } else {
      return "${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago";
    }
  }

  Widget _buildWalletCard(
      HomeScreenController controller, BuildContext context) {
    final accs = controller.dashboardData?.virtualAccounts;
    String accountText = "Loading...";
    if (accs != null) {
      if (accs.hasPrimary) {
        accountText =
            "${accs.primaryAccountNumber} | ${accs.primaryBankName} | MCD-${controller.dashboardData?.user.userName ?? ''}";
      } else {
        accountText = "No Virtual Account";
      }
    }

    return Skeleton.leaf(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: 60,
              bottom: -50,
              child: Transform.rotate(
                angle: 0.4,
                child: Container(
                  width: 35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.02)],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -20,
              right: 120,
              bottom: -50,
              child: Transform.rotate(
                angle: 0.4,
                child: Container(
                  width: 35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.02)],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (accs?.hasPrimary ?? false) {
                        Clipboard.setData(
                            ClipboardData(text: accs!.primaryAccountNumber));
                        Get.snackbar('Copied', 'Account number copied to clipboard',
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            accountText,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFonts.manRope),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        const Gap(8),
                        Skeleton.ignore(
                          child: SvgPicture.asset(
                            'assets/icons/home/copy-icon.svg',
                            width: 16,
                            height: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Gap(20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        controller.isBalanceVisible.value ? '₦ ' : '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.manRope),
                      ),
                      controller.isBalanceVisible.value
                          ? Text(
                              AmountUtil.formatFigure(double.tryParse(
                                      controller.dashboardData?.balance.wallet ??
                                          '0') ??
                                  0),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppFonts.manRope),
                            )
                          : const Text(
                              '****',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppFonts.manRope),
                            ),
                      const Gap(10),
                      GestureDetector(
                        onTap: () => controller.toggleBalanceVisibility(),
                        child: Icon(
                          controller.isBalanceVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const Gap(5),
                  Skeleton.ignore(
                    child: StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return Obx(() {
                          final time = controller.lastUpdated.value;
                          return Text(
                            "Last Updated: ${_getTimeAgo(time)}",
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontFamily: AppFonts.manRope),
                          );
                        });
                      },
                    ),
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      _walletActionButton(
                          icon: Icons.add,
                          text: 'Add money',
                          onTap: () {
                            Get.toNamed(Routes.ADD_MONEY_MODULE,
                                arguments: {'dashboardData': controller.dashboardData});
                          }),
                      const Gap(12),
                      _walletActionButton(
                          svgIcon: 'assets/icons/home/history.svg',
                          text: 'History',
                          onTap: () {
                            Get.offAllNamed(Routes.HISTORY_SCREEN);
                          }),
                      const Spacer(),
                      _walletActionButton(
                          svgIcon: 'assets/icons/home/wallet.svg',
                          text: 'Wallets',
                          onTap: () {
                            _showWalletsBottomSheet(context, controller);
                          }),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _walletActionButton(
      {IconData? icon,
      String? svgIcon,
      required String text,
      required VoidCallback onTap}) {
    return Skeleton.ignore(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF6EC38C),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 16),
              if (svgIcon != null)
                SvgPicture.asset(svgIcon,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    height: 16),
              const Gap(6),
              Text(text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.manRope)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(
      HomeScreenController controller, BuildContext context) {
    if (controller.isLoading && controller.actionButtonz.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
              5,
              (index) => Skeleton.leaf(
                    child: Container(
                      width: 66,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(8),
                        const Text("...", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ))),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.actionButtonz.asMap().entries.map((entry) {
          final index = entry.key;
          final button = entry.value;
          final serviceKey = controller.getServiceKey(button.text, button.link);
          final isAvailable =
              serviceKey.isEmpty || controller.isServiceAvailable(serviceKey);

          return _BouncingQuickActionButton(
            button: button,
            isAvailable: isAvailable,
            onTap: () async {
              final isAvailable =
                  await controller.handleServiceNavigation(button);
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
          )
              .animate(delay: (index * 100).ms)
              .slideY(begin: 0.2, curve: Curves.easeOutQuad)
              .fadeIn();
        }).toList(),
      ),
    );
  }

  Widget _walletItemWithIcon(String title, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const Gap(15),
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: AppFonts.manRope, color: AppColors.background)),
          const Gap(8),
          Text(amount,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: AppFonts.manRope, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showWalletsBottomSheet(
      BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Gap(15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  const Text("Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: AppFonts.manRope, color: AppColors.background)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 20, color: Colors.grey),
                  ),
                ],
              ),
              const Gap(30),
              _walletItemWithIcon("Commission",
                  "(₦${AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.commission ?? '0.00') ?? 0)})",
                  Icons.account_balance_wallet_outlined),
              _walletItemWithIcon(
                  "Point",
                  "(${AmountUtil.formatFigure(double.tryParse(
                          controller.dashboardData?.balance.points ?? '0') ??
                      0)})",
                  Icons.adjust),
              _walletItemWithIcon("Bonus",
                  "(₦${AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.bonus ?? '0.00') ?? 0)})",
                  Icons.stars_outlined),
              _walletItemWithIcon("General Market",
                  "(₦${AmountUtil.formatFigure(double.tryParse(controller.gmBalance) ?? 0)})",
                  Icons.storefront_outlined),
              const Gap(20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticCarousel(BuildContext context) {
    return const Skeleton.leaf(child: HomePromoCarousel());
  }
}

class PromoCardModel {
  final String iconAsset;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final Color subtitle1Color;
  final String buttonText;
  final String imageAsset;
  final String route;

  PromoCardModel({
    required this.iconAsset,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.subtitle1Color,
    required this.buttonText,
    required this.imageAsset,
    required this.route,
  });
}


class HomePromoCarousel extends StatefulWidget {
  const HomePromoCarousel({super.key});

  @override
  State<HomePromoCarousel> createState() => _HomePromoCarouselState();
}

class _HomePromoCarouselState extends State<HomePromoCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  static const _kStartPage = 1000;

  final List<PromoCardModel> items = [
    PromoCardModel(
      iconAsset: 'assets/icons/home/daily-bonus-icon.svg',
      title: 'Daily Bonus',
      subtitle1: 'Claim ₦750 today',
      subtitle2: 'Your daily reward is waiting.',
      subtitle1Color: AppColors.primaryColor,
      buttonText: 'Claim Now',
      imageAsset: 'assets/images/home_carousel/green-gift.png',
      route: '/free_money',
    ),
    PromoCardModel(
      iconAsset: 'assets/icons/home/mega-sale-icon.svg',
      title: 'Mega Sale',
      subtitle1: 'Save more on every purchase',
      subtitle2: '',
      subtitle1Color: Colors.grey.shade600,
      buttonText: 'Shop Now',
      imageAsset: 'assets/images/home_carousel/mega-sale.png',
      route: Routes.STORE_FRONT,
    ),
    PromoCardModel(
      iconAsset: 'assets/icons/home/refer-icon.svg',
      title: 'Refer & Earn',
      subtitle1: 'Earn ₦1,000',
      subtitle2: 'for every friend',
      subtitle1Color: AppColors.primaryColor,
      buttonText: 'Invite Now',
      imageAsset: 'assets/images/home_carousel/refer.png',
      route: Routes.REFERRAL_LIST_MODULE,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = _kStartPage;
    _pageController = PageController(initialPage: _currentPage);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
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
    return Column(
      children: [
        SizedBox(
          height: 160,
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
                final actualIndex = index % items.length;
                return _PromoCarouselItem(item: items[actualIndex]);
              },
            ),
          ),
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (index) {
              final isActive = (_currentPage % items.length) == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primaryColor : Colors.grey[300],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PromoCarouselItem extends StatelessWidget {
  final PromoCardModel item;

  const _PromoCarouselItem({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // the light green design blob on the right
            Positioned(
              right: -30,
              top: -10,
              child: Transform.rotate(
                angle: 46.97 * (3.1415926535897932 / 180),
                child: Container(
                  width: 170,
                  height: 230,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(218, 248, 223, 0.82),
                    borderRadius: BorderRadius.circular(115),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 10, top: 16, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // circular icon on the far left
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      item.iconAsset,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  const Gap(12),
                  // Text and Button Column
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.manRope,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(2),
                        Text(
                          item.subtitle1,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.manRope,
                            color: item.subtitle1Color,
                          ),
                        ),
                        if (item.subtitle2.isNotEmpty) ...[
                          const Gap(2),
                          Text(
                            item.subtitle2,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: AppFonts.manRope,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                        const Gap(10),
                        GestureDetector(
                          onTap: () {
                             if (item.route.isNotEmpty) {
                               Get.toNamed(item.route);
                             }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  item.buttonText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFonts.manRope,
                                  ),
                                ),
                                const Gap(4),
                                const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Image on the far right
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        item.imageAsset,
                        fit: BoxFit.contain,
                        height: 200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BouncingQuickActionButton extends StatefulWidget {
  final ButtonModel button;
  final bool isAvailable;
  final VoidCallback onTap;

  const _BouncingQuickActionButton({
    required this.button,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  State<_BouncingQuickActionButton> createState() =>
      _BouncingQuickActionButtonState();
}

class _BouncingQuickActionButtonState
    extends State<_BouncingQuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.isAvailable ? 1.0 : 0.5,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: Container(
          width: 66,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          decoration: BoxDecoration(
            color: widget.button.text.toLowerCase() == 'more' ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: widget.button.text.toLowerCase() == 'more' ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                widget.button.icon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                    widget.button.text.toLowerCase() == 'more' ? Colors.white : AppColors.primaryColor, BlendMode.srcIn),
              ),
              const Gap(8),
              Text(
                widget.button.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.button.text.toLowerCase() == 'more' ? Colors.white : AppColors.background,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.manRope,
                ),
              ),
            ],
          ),
        ).animate(target: _isPressed ? 1 : 0).scale(
              begin: const Offset(1, 1),
              end: const Offset(0.9, 0.9),
              duration: 100.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }
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
              "Leaderboard",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.manRope,
                color: AppColors.background,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.LEADERBOARD_MODULE),
              child: const Text(
                "See all",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.manRope,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const Gap(15),
        Obx(() {
          final topThree = LeaderboardService.to.topThree;
          if (topThree.isEmpty) {
            return const Center(child: Text("No top earners yet.", style: TextStyle(fontFamily: AppFonts.manRope)));
          }
          return Column(
            children: topThree.asMap().entries.map((entry) {
              int index = entry.key;
              LeaderboardUser user = entry.value;
              String imagePath = index == 0 ? 'assets/images/leaderboard/lead1.png' : 
                                 index == 1 ? 'assets/images/leaderboard/lead2.png' : 
                                 'assets/images/leaderboard/lead3.png';
              return _buildLeaderboardListItem(user, imagePath, index);
            }).toList(),
          );
        }),
      ],
    ),
  );
}

Widget _buildLeaderboardListItem(LeaderboardUser user, String imagePath, int index) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.grey.shade200, width: 1.0),
    ),
    child: Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.manRope,
                  color: AppColors.background,
                ),
              ),
              // const Gap(2),
              // Text(
              //   "₦${AmountUtil.formatFigure((user.pointsValue).toDouble())} volume",
              //   style: TextStyle(
              //     fontSize: 13,
              //     fontWeight: FontWeight.w500,
              //     fontFamily: AppFonts.manRope,
              //     color: Colors.grey.shade600,
              //   ),
              // ),
            ],
          ),
        ),
        Text(
          "${AmountUtil.formatFigure(user.pointsValue.toDouble())} pts",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.manRope,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    ),
  ).animate(delay: (index * 100).ms).slideY(begin: 0.2, curve: Curves.easeOutQuad).fadeIn();
}

// Widget _walletItem(String title, String amount) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 16),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(title,
//             style: const TextStyle(fontSize: 14, fontFamily: AppFonts.manRope)),
//         TextSemiBold(amount, fontSize: 14, color: AppColors.primaryColor),
//       ],
//     ),
//   );
// }

Widget _buildImageSlider(HomeScreenController controller) {
  return ImageSliderWidget(
    images: controller.imageSliders,
  );
}

class ImageSliderWidget extends StatefulWidget {
  final List<String> images;

  const ImageSliderWidget({super.key, required this.images});

  @override
  State<ImageSliderWidget> createState() => ImageSliderWidgetState();
}

class ImageSliderWidgetState extends State<ImageSliderWidget> {
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
  void didUpdateWidget(ImageSliderWidget oldWidget) {
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
                return ImageItem(url: widget.images[actualIndex]);
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

class ImageItem extends StatefulWidget {
  final String url;

  const ImageItem({super.key, required this.url});

  @override
  State<ImageItem> createState() => ImageItemState();
}

class ImageItemState extends State<ImageItem> {
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
