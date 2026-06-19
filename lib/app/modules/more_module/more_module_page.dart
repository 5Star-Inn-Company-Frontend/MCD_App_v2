import 'package:mcd/app/modules/plans_module/plans_module_page.dart';
import 'package:mcd/app/utils/bottom_navigation.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../../core/utils/confirmlogout.dart';
import './more_module_controller.dart';

class MoreModulePage extends GetView<MoreModuleController> {
  const MoreModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitDialog(context) ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextBold(
            'More',
            fontSize: 20,
            color: AppColors.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),

          elevation: 0.0,
          centerTitle: false,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: AppColors.primaryGrey, width: 1),
                        top: BorderSide(color: AppColors.primaryGrey))),
                child: TabBar(
                    controller: controller.tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorPadding: EdgeInsets.zero,
                    labelColor: AppColors.primaryGreen,
                    dividerHeight: 0,
                    indicatorColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryGreen,
                    ),
                    padding: EdgeInsets.zero,
                    tabs: const [
                      Text(
                        'General',
                        style: TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      Text(
                        'Subscriptions',
                        style: TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      Text(
                        'Referrals',
                        style: TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      Text(
                        'Support',
                        style: TextStyle(fontFamily: AppFonts.manRope),
                      ),
                      Text(
                        'API',
                        style: TextStyle(fontFamily: AppFonts.manRope),
                      ),
                    ]),
              )),
          // foregroundColor: AppColors.white,
        ),
        body: TabBarView(
            controller: controller.tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    rowcard('Account Information', () {
                      Get.toNamed(Routes.ACCOUNT_INFO);
                    }, false),
                    rowcard('KYC Update', () {
                      Get.toNamed(Routes.KYC_UPDATE_MODULE);
                    }, false),
                    rowcard('Agent Request', () {
                      Get.toNamed(Routes.AGENT_REQUEST_MODULE);
                    }, false),
                    rowcard('Transaction History', () {
                      Get.offAllNamed(Routes.HISTORY_SCREEN);
                    }, false),
                    rowcard('Withdraw Bonus', () {
                      Get.toNamed(Routes.WITHDRAW_BONUS_MODULE);
                    }, false),
                    rowcard('Settings', () {
                      Get.toNamed(Routes.SETTINGS_SCREEN);
                    }, false),
                    rowcard('Logout', () {
                      Confirmlogout.confirmLogout();
                    }, true),
                    rowcard('Delete Account', () {
                      controller.deleteAccount();
                    }, true),
                  ],
                ),
              ),
              const PlansModulePage(isAppbar: false),
              _buildReferralsTab(context),
              _buildSupportTab(),
              _buildApiTab()
            ]),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
      ),
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
            child: TextSemiBold('No', color: AppColors.textPrimaryColor),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: TextSemiBold('Yes', color: AppColors.textPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.25,
              child: SvgPicture.asset(
                'assets/icons/referral_banner.svg',
                fit: BoxFit.cover,
              ),
            ),
            const Gap(24),

            // Referral Code Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSemiBold(
                    'Your Referral Code',
                    fontSize: 14,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(8),
                  TextSemiBold(
                    'Use this referral code to invite your friends to MEGA Cheap Data',
                    fontSize: 12,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryGreen),
                          ),
                          child: TextSemiBold(
                            controller.getReferralCode(),
                            fontSize: 18,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Gap(8),
                      IconButton(
                        onPressed: controller.copyReferralCode,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.copy,
                            color: AppColors.white, size: 20),
                      ),
                      const Gap(4),
                      IconButton(
                        onPressed: controller.shareReferralCode,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.share,
                            color: AppColors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Add Referral Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.ADD_REFERRAL_MODULE);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextSemiBold(
                  'Add Referral Code',
                  fontSize: 16,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(12),

            // Referral List Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: controller.viewReferralList,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: AppColors.primaryGreen, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextSemiBold(
                  'View Referral List',
                  fontSize: 16,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(24),

            TextSemiBold(
              'Invite your friends and earn',
              fontSize: 16,
              // color: AppColors.primaryGrey,
            ),
            const Gap(24),

            // App Referral Card
            _buildReferralCard(
              icon: 'assets/icons/app_referral.svg',
              title: 'App Referral',
              description:
                  'Get FREE 250MB instantly, when you refer a friend to download Mega Cheap Data App. While your friends gts 1GB data bonus.',
              // iconColor: const Color(0xFF4CAF50),
            ),
            const Gap(16),

            // Data Referral Card
            _buildReferralCard(
              icon: 'assets/icons/data_referral.svg',
              title: 'Data Referral',
              description:
                  'Get FREE 250MB instantly, when you refer a friend to download Mega Cheap Data App. While your friends gts 1GB data bonus.',
              // iconColor: const Color(0xFF2196F3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCard({
    required String icon,
    required String title,
    required String description,
    // required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          SvgPicture.asset(
            icon,
            // colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const Gap(12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 15,
                  children: [
                    TextSemiBold(
                      title,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    // Icon(
                    //   Icons.arrow_forward_ios,
                    //   size: 16,
                    //   // color: AppColors.primaryGrey,
                    // ),
                  ],
                ),
                const Gap(8),
                TextSemiBold(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    // color: AppColors.primaryGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: ListView(
        children: [
          _buildSupportCard(
            title: 'Chat with us on Whatsapp',
            onTap: () async {
              try {
                final username = controller.dashboardData?.user.userName ?? 'User';
                String url =
                    "https://wa.me/2347011223737?text=Hi, my user name is $username";
                await launcher.launchUrl(Uri.parse(url));
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not open WhatsApp',
                  backgroundColor: AppColors.errorBgColor,
                  colorText: AppColors.textSnackbarColor,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
          ),
          const Gap(16),
          _buildSupportCard(
            title: 'Join our community',
            onTap: () async {
              try {
                String url =
                    "https://whatsapp.com/channel/0029Va5yrz9JkK70XgXPEO0R";
                if (await launcher.canLaunchUrl(Uri.parse(url))) {
                  await launcher.launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not open community link',
                  backgroundColor: AppColors.errorBgColor,
                  colorText: AppColors.textSnackbarColor,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
          ),
          const Gap(16),
          _buildSupportCard(
            title: 'Send a mail',
            onTap: () async {
              try {
                final username =
                    controller.dashboardData?.user.userName ?? 'User';
                String mail =
                    "mailto:info@5starcompany.com.ng?subject=Support Needed by $username";
                await launcher.launchUrl(Uri.parse(mail));
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not open email client',
                  backgroundColor: AppColors.errorBgColor,
                  colorText: AppColors.textSnackbarColor,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
          ),
          const Gap(16),
          // _buildSupportCard(
          //   title: 'Suggestion Link',
          //   onTap: () async {
          //     try {
          //       String url = "https://docs.google.com/forms/d/e/1FAIpQLSdZzwrGUPkqWEdSCEIPIo7d7fIGFuvHHhavrZHGLH948di1UQ/viewform?pli=1";
          //       if (await launcher.canLaunchUrl(Uri.parse(url))) {
          //         await launcher.launchUrl(Uri.parse(url));
          //       } else {
          //         throw 'Could not launch $url';
          //       }
          //     } catch (e) {
          //       Get.snackbar(
          //         'Error',
          //         'Could not open suggestion box',
          //         backgroundColor: AppColors.errorBgColor,
          //         colorText: AppColors.textSnackbarColor,
          //         snackPosition: SnackPosition.TOP,
          //       );
          //     }
          //   },
          // ),
          // const Gap(16),
          _buildSupportCard(
            title: 'Suggestion Box',
            onTap: () async {
              try {
                String url = "https://forms.gle/vEqQmNK1BYuUF9iNA";
                if (await launcher.canLaunchUrl(Uri.parse(url))) {
                  await launcher.launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not open suggestion box',
                  backgroundColor: AppColors.errorBgColor,
                  colorText: AppColors.textSnackbarColor,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
          ),
          const Gap(16),
          _buildSupportCard(
            title: 'Rate us',
            onTap: () async {
              try {
                String url =
                    "https://play.google.com/store/apps/details?id=a5starcompany.com.megacheapdata";
                if (await launcher.canLaunchUrl(Uri.parse(url))) {
                  await launcher.launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Could not open Play Store',
                  backgroundColor: AppColors.errorBgColor,
                  colorText: AppColors.textSnackbarColor,
                  snackPosition: SnackPosition.TOP,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return TouchableOpacity(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.primaryGrey, width: 0.5),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextSemiBold(
                title,
                fontSize: 15,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSemiBold(
            'API Documentation',
            fontSize: 20,
          ),
          const Gap(8),
          const Text(
            'Access our comprehensive API documentation to integrate Mega Cheap Data services into your application.',
            style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryGrey2,
                fontFamily: AppFonts.manRope),
          ),
          const Gap(32),

          Center(
            child: BusyButton(
              width: screenWidth(Get.context!) * 0.8,
              title: "View API Documentation",
              onTap: () async {
                final url = Uri.parse(
                    'https://documenter.getpostman.com/view/9781740/T17Q43hr');
                try {
                  await launcher.launchUrl(url);
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Could not open API documentation",
                    backgroundColor: AppColors.errorBgColor,
                    colorText: AppColors.textSnackbarColor,
                    snackPosition: SnackPosition.TOP,
                  );
                }
              },
            ),
          ),

          const Gap(40),

          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: AppColors.primaryGrey.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(color: AppColors.primaryGrey.withOpacity(0.3)),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(Icons.info_outline, color: AppColors.primaryColor),
          //           const Gap(8),
          //           TextSemiBold('API Features', fontSize: 16),
          //         ],
          //       ),
          //       const Gap(16),
          //       _buildFeatureItem('Complete REST API documentation'),
          //       _buildFeatureItem('Authentication guides'),
          //       _buildFeatureItem('Request/Response examples'),
          //       _buildFeatureItem('Error handling reference'),
          //       _buildFeatureItem('Rate limiting information'),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  // Widget _buildFeatureItem(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           margin: const EdgeInsets.only(top: 6),
  //           width: 6,
  //           height: 6,
  //           decoration: BoxDecoration(
  //             color: AppColors.primaryColor,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //         const Gap(12),
  //         Expanded(
  //           child: Text(
  //             text,
  //             style: const TextStyle(fontSize: 14),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget rowcard(String name, VoidCallback onTap, bool isLogout) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: TouchableOpacity(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: name == "Delete Account"
                      ? Colors.red
                      : AppColors.primaryGrey,
                  width: 0.5),
              color: AppColors.white,
              borderRadius: BorderRadius.circular(3)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                TextSemiBold(name),
                const Spacer(),
                name == "Delete Account"
                    ? Icon(Icons.delete)
                    : SvgPicture.asset(isLogout == false
                        ? AppAsset.arrowRight
                        : AppAsset.logout),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
