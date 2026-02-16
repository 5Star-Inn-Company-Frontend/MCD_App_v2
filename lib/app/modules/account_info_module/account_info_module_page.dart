import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/app/widgets/skeleton_loader.dart';
import './account_info_module_controller.dart';
import 'dart:developer' as dev;

class AccountInfoModulePage extends GetView<AccountInfoModuleController> {
  const AccountInfoModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget _buildAmountColumn(String amount, String text) {
      return Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: String.fromCharCode(0x20A6),
                  style: const TextStyle(
                    fontFamily: 'plusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                TextSpan(
                  text: amount,
                  style: const TextStyle(
                    fontFamily: AppFonts.manRope,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Gap(4),
          TextSemiBold(
            text,
            fontSize: 11,
          ),
        ],
      );
    }

    Widget columnText(String amount, String text) {
      return Column(
        children: [
          TextSemiBold(
            amount,
            fontSize: 13,
          ),
          const Gap(4),
          TextSemiBold(
            text,
            fontSize: 11,
          ),
        ],
      );
    }

    Widget rowText(String text, String subtext) {
      return Row(
        children: [
          TextSemiBold(
            text,
            fontSize: 14,
          ),
          const Spacer(),
          TextSemiBold(
            subtext,
            fontSize: 14,
          ),
          // const Gap(5),
          // const Icon(Icons.more_horiz_outlined)
        ],
      );
    }

    // mask value with asterisks
    String maskValue(String value,
        {int visibleChars = 3, bool isPhone = false, bool isUsername = false}) {
      if (value.isEmpty || value == 'N/A') return value;

      // for phone numbers and username, mask only the last 4 characters
      if (isPhone || isUsername) {
        if (value.length <= 4) {
          return '*' * value.length;
        }
        final visiblePart = value.substring(0, value.length - 4);
        return '$visiblePart****';
      }

      // for email, show first 3 chars + asterisks + @domain
      if (value.contains('@')) {
        final parts = value.split('@');
        if (parts.length == 2) {
          final name = parts[0];
          final domain = parts[1];
          if (name.length <= visibleChars) {
            return '${name}***@$domain';
          }
          return '${name.substring(0, visibleChars)}${'*' * 8}@$domain';
        }
      }

      // for other values, show first chars + asterisks
      if (value.length <= visibleChars) {
        return '$value***';
      }
      return '${value.substring(0, visibleChars)}${'*' * 3}';
    }

    Widget rowcard(
        String name, VoidCallback onTap, bool isText, String? subText) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: TouchableOpacity(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryGrey, width: 0.5),
                color: AppColors.white,
                borderRadius: BorderRadius.circular(3)),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  TextSemiBold(name),
                  const Spacer(),
                  isText == false
                      ? SvgPicture.asset(AppAsset.arrowRight)
                      : TextSemiBold(subText!),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        centerTitle: false,
        title: "My Profile",
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            dev.log("AccountInfoModulePage: Pull to refresh triggered");
            return controller.refreshProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Obx(() {
                dev.log(
                    "AccountInfoModulePage: Obx rebuild - isLoading: ${controller.isLoading}, hasProfile: ${controller.profileData != null}");

                if (controller.isLoading && controller.profileData == null) {
                  dev.log("AccountInfoModulePage: Showing skeleton loader");
                  return Column(
                    children: [
                      const Gap(20),
                      const SkeletonProfileHeader(),
                      const Gap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          SkeletonText(width: 60, height: 40),
                          SkeletonText(width: 60, height: 40),
                          SkeletonText(width: 60, height: 40),
                        ],
                      ),
                      const Gap(30),
                      const SkeletonCard(height: 50),
                      const Gap(12),
                      const SkeletonCard(height: 50),
                      const Gap(12),
                      const SkeletonCard(height: 50),
                      const Gap(12),
                      const SkeletonCard(height: 50),
                      const Gap(12),
                      const SkeletonCard(height: 50),
                    ],
                  );
                }

                final profile = controller.profileData;

                return Column(
                  children: [
                    const Gap(20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 0),
                            color: AppColors.background.withOpacity(0.1),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          color: AppColors.lightGreen,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: profile?.photo != null &&
                                              profile!.photo!.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                profile.photo!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Padding(
                                                  padding: const EdgeInsets.all(
                                                      25.0),
                                                  child: SvgPicture.asset(
                                                      AppAsset.camera),
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(25.0),
                                              child: SvgPicture.asset(
                                                  AppAsset.camera),
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Obx(() => TouchableOpacity(
                                            onTap: controller.isUploading
                                                ? null
                                                : () {
                                                    dev.log(
                                                        "AccountInfoModulePage: Upload photo button tapped");
                                                    controller
                                                        .uploadProfilePicture();
                                                  },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: controller.isUploading
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors.white,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.camera_alt,
                                                      color: AppColors.white,
                                                      size: 16,
                                                    ),
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                TextSemiBold(
                                  profile?.fullName ?? "N/A",
                                  fontSize: 16,
                                ),
                                const Gap(6),
                                TextSemiBold(
                                  '@${profile?.userName ?? "N/A"}',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: AppColors.filledBorderIColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildAmountColumn(profile?.totalFunding ?? '0',
                                    'Total Funding'),
                                _buildAmountColumn(
                                    profile?.totalTransaction ?? '0',
                                    'Total Transaction'),
                                columnText('${profile?.totalReferral ?? 0}',
                                    'Total Referral'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(20),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 0),
                            color: AppColors.background.withOpacity(0.1),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            rowText('Name', profile?.fullName ?? "N/A"),
                            const Gap(20),
                            rowText(
                                'Email', maskValue(profile?.email ?? "N/A")),
                            const Gap(20),
                            rowText(
                                'Phone',
                                maskValue(profile?.phoneNo ?? "N/A",
                                    isPhone: true)),
                            const Gap(20),
                            rowText(
                                'Username', '@${profile?.userName ?? "N/A"}'),
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),
                    rowcard('Plan (${profile?.referralPlan})', () {
                      Get.toNamed(Routes.MORE_MODULE,
                          arguments: {'initialTab': 1});
                    }, false, ''),
                    rowcard('Target (${profile?.target})', () {
                      Get.toNamed(Routes.AGENT_REQUEST_MODULE);
                    }, true, '(Level ${profile?.level ?? 0})'),
                    rowcard('General Market', () {
                      _showGeneralMarketDialog(context);
                    }, false, ''),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _showGeneralMarketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextSemiBold(
                'General Market',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              const Gap(16),
              Text(
                'General Market get funded by buying data and using free money.\n\n'
                'The fund is available to everyone for use but subject to terms and conditions.\n\n'
                '1. You must have buy data on the day you want to use it.\n\n'
                '2. On checkout with General Market option, advertisement will be displayed thrice before your request will be processed.\n\n'
                '3. In case someone checkout before you, your request will not be served.\n\n'
                '4. The minimum balance is ₦300.\n\n'
                '5. You must be clicking on free money once in a while to keep general market active',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: TextSemiBold(
                        'OK',
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
