import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
// import 'package:marquee/marquee.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import '../../../core/import/imports.dart';
import '../../utils/bottom_navigation.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/shimmer_loading.dart';
import 'widgets/image_slider_widget.dart';
import 'widgets/scrolling_news_widget.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class HomeScreenPage extends GetView<HomeScreenController> {
  const HomeScreenPage({super.key});

  InlineSpan _getNewsSpan() {
    return TextSpan(
      children: [
        TextSpan(
          text: controller.dashboardData?.news ?? 'Welcome to Mega Cheap Data',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.grey.shade600,
            fontFamily: AppFonts.manRope,
          ),
        ),
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.checkClipboardForPhoneNumber();
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context) ?? false;
      },
      child: Obx(() => Scaffold(
            appBar: PaylonyAppBar(
              titleWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Welcome back,",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  Text(
                    "${controller.dashboardData?.user.userName ?? 'User'} 👋🏼",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                ],
              ),
              elevation: 0,
              actions: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 242, 242, 242),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                        onTap: () {
                          Get.toNamed(Routes.QRCODE_MODULE);
                        },
                        child: SvgPicture.asset(
                          'assets/icons/bx_scan.svg',
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                              Colors.black, BlendMode.srcIn),
                        )),
                  ),
                ),
                // const Gap(10),
                // TouchableOpacity(
                //     child: InkWell(
                //         onTap: () {
                //           // Get.toNamed(Routes.VIRTUAL_CARD_DETAILS);
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => const VirtualCardHomePage(),
                //             ),
                //           );
                //         },
                //         child: SvgPicture.asset(
                //           'assets/icons/bank-card-two.svg',
                //           colorFilter: const ColorFilter.mode(
                //               Colors.black, BlendMode.srcIn),
                //         ))),
                const Gap(10),
                // TouchableOpacity(
                //     child: InkWell(
                //         onTap: () {
                //           Get.toNamed(Routes.ACCOUNT_INFO);
                //         },
                //         child: SvgPicture.asset(AppAsset.profileIicon))),
                // const Gap(10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 242, 242, 242),
                      shape: BoxShape.circle,
                    ),
                    child: InkWell(
                        onTap: () {
                          Get.toNamed(Routes.NOTIFICATION_MODULE);
                        },
                        child: SvgPicture.asset(
                          AppAsset.notificationIicon,
                          height: 20,
                          width: 20,
                          colorFilter: const ColorFilter.mode(
                              Colors.black, BlendMode.srcIn),
                        )),
                  ),
                ),
                const Gap(12)
              ],
            ),
            body: RefreshIndicator(
              color: AppColors.primaryColor,
              backgroundColor: AppColors.white,
              onRefresh: controller.refreshDashboard,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView(
                  children: [
                    const Gap(10),
                    Row(
                      children: [
                        Obx(() => GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.MORE_MODULE,
                                    arguments: {'initialTab': 1});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 14),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withOpacity(0.08),
                                  border: Border.all(
                                      color: AppColors.primaryColor
                                          .withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // const Icon(
                                    //   Icons.stars_rounded,
                                    //   color: AppColors.primaryColor,
                                    //   size: 18,
                                    // ),
                                    // const Gap(6),
                                    controller.isLoading &&
                                            controller.dashboardData == null
                                        ? const ShimmerLoading(
                                            width: 50,
                                            height: 14,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                          )
                                        : TextSemiBold(
                                            controller
                                                        .dashboardData
                                                        ?.user
                                                        .referralPlan
                                                        .isNotEmpty ==
                                                    true
                                                ? controller.dashboardData!.user
                                                    .referralPlan
                                                    .toUpperCase()
                                                : "FREE PLAN",
                                            fontSize: 13,
                                            color: AppColors.primaryColor,
                                          ),
                                    const Gap(4),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.primaryColor,
                                      size: 18,
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),

                    const Gap(30),
                    Obx(() => controller.isLoading &&
                            controller.dashboardData == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: ShimmerLoading(
                              width: double.infinity,
                              height: 160,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/images/epin/design-3.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // foregroundDecoration: BoxDecoration(
                              //   color: Colors.black.withOpacity(0.1),
                              // ),
                              child: Column(
                                children: [
                                  // main balance + add money
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 30, 18, 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  "Wallet Balance",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        AppFonts.manRope,
                                                  ),
                                                ),
                                                const Gap(8),
                                                Obx(() => InkWell(
                                                      onTap: controller
                                                          .toggleBalance,
                                                      child: Icon(
                                                        controller.showBalance
                                                            ? Icons
                                                                .visibility_outlined
                                                            : Icons
                                                                .visibility_off_outlined,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Get.toNamed(
                                                  Routes.ADD_MONEY_MODULE,
                                                  arguments: {
                                                    'dashboardData': controller
                                                        .dashboardData,
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 16),
                                                    Gap(4),
                                                    Text(
                                                      "Add Money",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            AppFonts.manRope,
                                                      ),
                                                    ),
                                                    Gap(4),
                                                    Icon(Icons.arrow_outward,
                                                        color: Colors.white,
                                                        size: 16),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Gap(8),
                                        Obx(() => Text(
                                              controller.showBalance
                                                  ? "₦${AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.wallet ?? '0') ?? 0)}"
                                                  : "₦****",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 34,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                                letterSpacing: -0.5,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),

                                  // divider
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.2),
                                      height: 1,
                                    ),
                                  ),

                                  // sub-balances row
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 20, 18, 30),
                                    child: Obx(() => Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            dataItem(
                                                "Commission",
                                                controller.showBalance
                                                    ? "₦${AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.commission ?? '0') ?? 0)}"
                                                    : "₦****"),
                                            dataItem(
                                                "Points",
                                                controller.showBalance
                                                    ? AmountUtil.formatFigure(
                                                        double.tryParse(controller
                                                                    .dashboardData
                                                                    ?.balance
                                                                    .points ??
                                                                '0') ??
                                                            0)
                                                    : "****"),
                                            dataItem(
                                                "Bonus",
                                                controller.showBalance
                                                    ? "₦${AmountUtil.formatFigure(double.tryParse(controller.dashboardData?.balance.bonus ?? '0') ?? 0)}"
                                                    : "₦****"),
                                            dataItem(
                                                "General Market",
                                                controller.showBalance
                                                    ? "₦${AmountUtil.formatFigure(double.tryParse(controller.gmBalance ?? '0') ?? 0)}"
                                                    : "₦****"),
                                          ],
                                        )),
                                  ),
                                ],
                              ),
                            ))),

                    const Gap(15),
                    // marquee
                    Obx(() =>
                        controller.isLoading && controller.dashboardData == null
                            ? const Center(
                                child: ShimmerLoading(
                                  width: double.infinity,
                                  height: 35,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                              )
                            : SizedBox(
                                height: 30,
                                child: ScrollingNewsWidget(
                                  content: _getNewsSpan(),
                                ),
                              )),
                    const Divider(
                      color: AppColors.boxColor,
                    ),

                    const Gap(10),
                    GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: controller.actionButtonz.length,
                        itemBuilder: (BuildContext ctx, index) {
                          final button = controller.actionButtonz[index];
                          final serviceKey = controller.getServiceKey(
                              button.text, button.link);
                          final isAvailable = serviceKey.isEmpty ||
                              controller.isServiceAvailable(serviceKey);

                          return Opacity(
                            opacity: isAvailable ? 1.0 : 0.5,
                            child: TouchableOpacity(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xffF3FFF7),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: InkWell(
                                    onTap: () async {
                                      // Check service availability first
                                      final isAvailable = await controller
                                          .handleServiceNavigation(
                                              controller.actionButtonz[index]);

                                      if (!isAvailable) {
                                        return; // Service not available, dialog already shown
                                      }

                                      // Proceed with navigation if service is available
                                      if (controller
                                              .actionButtonz[index].link ==
                                          Routes.RESULT_CHECKER_MODULE) {
                                        _showResultCheckerOptions(context);
                                      } else if (controller
                                              .actionButtonz[index].link ==
                                          "epin") {
                                        _showEpinOptionsBottomSheet(context);
                                      } else if (controller
                                              .actionButtonz[index].link ==
                                          Routes.AIRTIME_MODULE) {
                                        _showAirtimeSelectionBottomSheet(
                                            context);
                                      } else if (controller
                                              .actionButtonz[index].link ==
                                          Routes.DATA_MODULE) {
                                        _showDataSelectionBottomSheet(context);
                                      }
                                      // else if (controller
                                      //         .actionButtonz[index].text ==
                                      //     "Mega Bulk Service") {
                                      //   try {
                                      //     final url = Uri.parse(
                                      //         'https://megabulk.5starcompany.com.ng/');
                                      //     await launcher.launchUrl(url);
                                      //   } catch (e) {
                                      //     Get.snackbar(
                                      //       "Error",
                                      //       "Could not open Mega Bulk Service",
                                      //       backgroundColor:
                                      //           AppColors.errorBgColor,
                                      //       colorText:
                                      //           AppColors.textSnackbarColor,
                                      //     );
                                      //   }
                                      else if (controller.actionButtonz[index]
                                          .link.isNotEmpty) {
                                        Get.toNamed(controller
                                            .actionButtonz[index].link);
                                      }
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                            controller
                                                .actionButtonz[index].icon,
                                            colorFilter: const ColorFilter.mode(
                                                AppColors.primaryColor2,
                                                BlendMode.srcIn)),
                                        const Gap(5),
                                        TextSemiBold(
                                          controller.actionButtonz[index].text,
                                          textAlign: TextAlign.center,
                                          color: AppColors.primaryColor2,
                                          fontSize: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          );
                        }),
                    const Divider(
                      color: AppColors.boxColor,
                    ),

                    const Gap(10),
                    // image slider carousel
                    Obx(() => controller.imageSliders.isNotEmpty
                        ? ImageSliderWidget(
                            images: controller.imageSliders,
                          )
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavigation(
              selectedIndex: 0,
            ),
          )),
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

  void _showResultCheckerOptions(BuildContext context) {
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

  void _showEpinOptionsBottomSheet(BuildContext context) {
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
                          Column(
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
                            ],
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

  void _showAirtimeSelectionBottomSheet(BuildContext context) {
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
                          Column(
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
                            ],
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

  void _showDataSelectionBottomSheet(BuildContext context) {
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
                          Column(
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
                            ],
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          amount,
          style: GoogleFonts.plusJakartaSans(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
        const Gap(4),
        Text(
          name.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
            fontFamily: AppFonts.manRope,
            letterSpacing: 0.5,
          ),
        )
      ],
    );
  }

  }

