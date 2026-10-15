import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/constants/app_asset.dart';
import 'package:mcd/core/constants/fonts.dart';
import 'package:mcd/core/controllers/service_status_controller.dart';

import './add_money_module_controller.dart';

class AddMoneyModulePage extends GetView<AddMoneyModuleController> {
  const AddMoneyModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Fund Wallet",
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Obx(() {
              final user = controller.dashboardData.value;
              final isBvnAvailable = ServiceStatusController.to
                  .isServiceAvailable('bvn_verification');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSemiBold(
                      "Choose a method to receive money into your wallet"),
                  const Gap(20),
                  TextSemiBold(
                    "Bank Transfer",
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  const Gap(20),

                  // check if user has no accounts
                  if (user?.virtualAccounts.hasPrimary != true &&
                      user?.virtualAccounts.hasSecondary != true) ...[
                    // KYC prompt for users without accounts
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                              const Gap(8),
                              Expanded(
                                child: TextSemiBold(
                                  "Complete KYC to Get Your Account",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Gap(12),
                          TextSemiBold(
                            "You need to complete your KYC verification to receive a dedicated bank account for funding your wallet.",
                            fontSize: 14,
                            color: AppColors.primaryGrey2,
                          ),
                          const Gap(16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isBvnAvailable
                                  ? () {
                                      Get.toNamed(Routes.KYC_UPDATE_MODULE);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isBvnAvailable
                                    ? AppColors.primaryColor
                                    : AppColors.primaryGrey,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: TextSemiBold(
                                "Complete KYC Verification",
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (!isBvnAvailable) ...[
                            const Gap(8),
                            const Center(
                              child: Text(
                                'This service is currently unavailable. Please try again later.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppFonts.manRope,
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    // Primary Account
                    if (user?.virtualAccounts.hasPrimary == true) ...[
                      _buildAccountCard(
                        context: context,
                        accountName: user?.user.userName != null
                            ? "MCD-${user!.user.userName}"
                            : "N/A",
                        bankName: user!.virtualAccounts.primaryBankName,
                        accountNumber:
                            user.virtualAccounts.primaryAccountNumber,
                        onShare: () {
                          controller.shareAccountDetails(
                            user.virtualAccounts.primaryAccountNumber,
                            user.virtualAccounts.primaryBankName,
                          );
                        },
                        onCopy: () {
                          controller.copyToClipboard(
                            user.virtualAccounts.primaryAccountNumber,
                            "Primary Account Number",
                          );
                        },
                      ),
                      const Gap(10),
                    ],

                    // Secondary Account
                    if (user?.virtualAccounts.hasSecondary == true) ...[
                      _buildAccountCard(
                        context: context,
                        accountName: user?.user.userName != null
                            ? "MCD-${user!.user.userName}"
                            : "N/A",
                        bankName: user!.virtualAccounts.secondaryBankName,
                        accountNumber:
                            user.virtualAccounts.secondaryAccountNumber,
                        onShare: () {
                          controller.shareAccountDetails(
                            user.virtualAccounts.secondaryAccountNumber,
                            user.virtualAccounts.secondaryBankName,
                          );
                        },
                        onCopy: () {
                          controller.copyToClipboard(
                            user.virtualAccounts.secondaryAccountNumber,
                            "Secondary Account Number",
                          );
                        },
                      ),
                    ],
                  ],

                  const Gap(20),

                  // Other Funding Options
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
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
                    child: Column(
                      children: [
                        InkWell(
                          onTap: controller.navigateToCardTopUp,
                          child: _buildFundingOption(
                            context: context,
                            icon: AppAsset.card,
                            title: 'Top-up with Card',
                            subtitle: "Add money directly from your bank card",
                          ),
                        ),
                        const Gap(10),
                        const Divider(color: Color(0xffF0F0F0)),
                        const Gap(10),
                        InkWell(
                          onTap: controller.navigateToUssd,
                          child: _buildFundingOption(
                            context: context,
                            icon: AppAsset.ussd,
                            title: 'USSD',
                            subtitle:
                                "Add money to your wallet using ussd on your phone",
                          ),
                        ),
                        const Gap(10),
                        const Divider(color: Color(0xffF0F0F0)),
                        const Gap(10),
                        InkWell(
                          onTap: controller.navigateToMomo,
                          child: _buildFundingOption(
                            context: context,
                            icon: AppAsset.ussd,
                            title: 'MoMo',
                            subtitle: "Add money to your wallet using MoMo",
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required BuildContext context,
    required String accountName,
    required String bankName,
    required String accountNumber,
    required VoidCallback onShare,
    required VoidCallback onCopy,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xff269E5F),
        borderRadius: BorderRadius.circular(26.5),
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
                      stops: [0.0, 0.7],
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
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0x20FFFFFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_rounded,
                                color: Colors.white, size: 14),
                          ),
                          const Gap(8),
                          Text(
                            bankName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFonts.manRope,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onCopy,
                        behavior: HitTestBehavior.opaque,
                        child: SvgPicture.asset(
                          'assets/icons/home/copy-icon.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                  const Gap(14),
                  const Text(
                    "ACCOUNT NUMBER",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  const Gap(4),
                  GestureDetector(
                    onTap: onCopy,
                    child: Text(
                      accountNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    accountName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.manRope,
                    ),
                  ),
                  const Gap(14),
                  Row(
                    children: [
                      _cardActionButton(
                        icon: Icons.copy_rounded,
                        text: 'Copy',
                        onTap: onCopy,
                      ),
                      const Gap(8),
                      _cardActionButton(
                        icon: Icons.share_rounded,
                        text: 'Share',
                        onTap: onShare,
                      ),
                      const Spacer(),
                      Container(
                        height: 29,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x20FFFFFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 13),
                            Gap(4),
                            Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFonts.manRope,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 95,
        height: 29,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x20FFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const Gap(6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.manRope,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingOption({
    required BuildContext context,
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(icon),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSemiBold(title),
                    const Gap(5),
                    TextSemiBold(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.keyboard_arrow_right,
          size: 30,
        )
      ],
    );
  }
}
