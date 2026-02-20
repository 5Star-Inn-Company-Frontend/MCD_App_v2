import 'dart:async';
import 'dart:developer' as dev;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:marquee/marquee.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../../core/import/imports.dart';
import '../../utils/bottom_navigation.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/shimmer_loading.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class HomeScreenPage extends GetView<HomeScreenController> {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context) ?? false;
      },
      child: Obx(() => Scaffold(
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
                // TouchableOpacity(
                //     child: InkWell(
                //         onTap: () {
                //           Get.toNamed(Routes.VIRTUAL_CARD_DETAILS);
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
                child: ListView(
                  children: [
                    const Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => GestureDetector(
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
                                    controller.isLoading &&
                                            controller.dashboardData == null
                                        ? const ShimmerLoading(
                                            width: 60,
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
                                                : "FREE",
                                            fontSize: 14,
                                            color: AppColors.background
                                                .withOpacity(0.7),
                                          ),
                                    const Icon(Icons.arrow_forward_ios_outlined)
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),

                    const Gap(30),
                    Obx(() => Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 6),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xff1B1B1B)),
                              borderRadius: BorderRadius.circular(6)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              controller.isLoading &&
                                      controller.dashboardData == null
                                  ? const ShimmerLoading(
                                      width: 100,
                                      height: 20,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                    )
                                  : RichText(
                                      text: TextSpan(
                                        text: '₦ ',
                                        style: const TextStyle(
                                          color: AppColors.background,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: AmountUtil.formatFigure(
                                                double.tryParse(controller
                                                            .dashboardData
                                                            ?.balance
                                                            .wallet ??
                                                        '0') ??
                                                    0),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: AppFonts.manRope,
                                                color: AppColors.background),
                                          ),
                                        ],
                                      ),
                                      // textAlign: TextAlign.center,
                                      textDirection: TextDirection.ltr,
                                      softWrap: true,
                                      overflow: TextOverflow.clip,
                                      maxLines: 10,
                                      textWidthBasis: TextWidthBasis.parent,
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: true,
                                        applyHeightToLastDescent: true,
                                      ),
                                      key: const Key('myRichTextWidgetKey'),
                                    ),
                              InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    Routes.ADD_MONEY_MODULE,
                                    arguments: {
                                      'dashboardData': controller.dashboardData,
                                    },
                                  );
                                },
                                child: Row(
                                  children: [
                                    TextSemiBold(
                                      "Add Money",
                                      fontSize: 14,
                                    ),
                                    const Gap(8),
                                    const Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: AppColors.primaryGrey2,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),

                    Obx(() => controller.isLoading &&
                            controller.dashboardData == null
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: ShimmerLoading(
                              width: double.infinity,
                              height: 120,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 40),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: AppColors.primaryGrey2,
                                  ),
                                  right: BorderSide(
                                    width: 1,
                                    color: AppColors.primaryGrey2,
                                  ),
                                  left: BorderSide(
                                    width: 1,
                                    color: AppColors.primaryGrey2,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    dataItem(
                                        "Commision",
                                        AmountUtil.formatFigure(double.tryParse(
                                                controller.dashboardData
                                                        ?.balance.commission ??
                                                    '0') ??
                                            0)),
                                    dataItem(
                                        "Points",
                                        AmountUtil.formatFigure(double.tryParse(
                                                controller.dashboardData
                                                        ?.balance.points ??
                                                    '0') ??
                                            0)),
                                    dataItem(
                                        "Bonus",
                                        AmountUtil.formatFigure(double.tryParse(
                                                controller.dashboardData
                                                        ?.balance.bonus ??
                                                    '0') ??
                                            0)),
                                    dataItem(
                                        "General Market",
                                        AmountUtil.formatFigure(double.tryParse(
                                                controller.gmBalance ?? '0') ??
                                            0))
                                  ],
                                ),
                              ],
                            ),
                          )),

                    const Gap(15),
                    // marquee
                    Obx(() => SizedBox(
                          height: screenHeight(context) * 0.03,
                          child: controller.isLoading &&
                                  controller.dashboardData == null
                              ? const Center(
                                  child: ShimmerLoading(
                                    width: double.infinity,
                                    height: 20,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                )
                              : Marquee(
                                  text: controller.dashboardData?.news ??
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
                                      } else if (controller
                                              .actionButtonz[index].text ==
                                          "Mega Bulk Service") {
                                        try {
                                          final url = Uri.parse(
                                              'https://megabulk.5starcompany.com.ng/');
                                          await launcher.launchUrl(url);
                                        } catch (e) {
                                          Get.snackbar(
                                            "Error",
                                            "Could not open Mega Bulk Service",
                                            backgroundColor:
                                                AppColors.errorBgColor,
                                            colorText:
                                                AppColors.textSnackbarColor,
                                          );
                                        }
                                      } else if (controller.actionButtonz[index]
                                          .link.isNotEmpty) {
                                        Get.toNamed(controller
                                            .actionButtonz[index].link);
                                      }
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(controller
                                            .actionButtonz[index].icon, colorFilter: const ColorFilter.mode(
                              AppColors.primaryColor, BlendMode.srcIn)),
                                        const Gap(5),
                                        TextSemiBold(
                                          controller.actionButtonz[index].text,
                                          textAlign: TextAlign.center,
                                          color: AppColors.primaryColor,
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
                        ? _buildImageSlider()
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
                      await controller.checkAndNavigate(
                        option['serviceKey'] as String,
                        serviceName: option['title'] as String,
                        onAvailable: () {
                          Navigator.pop(context);
                          Get.toNamed(option['route'] as String);
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
      children: [
        Text(
          amount,
          style: const TextStyle(
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

  Widget _buildImageSlider() {
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
        // Indicators
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
          height: 150,
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
    dev.log("success: image loaded ${widget.url}".toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.imageProvider,
      fit: BoxFit.cover,
    );
  }
}
