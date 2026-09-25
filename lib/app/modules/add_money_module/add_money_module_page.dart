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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xffF3FFF7),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BANK NAME",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.2,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                    const Gap(4),
                    TextSemiBold(
                      bankName,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onCopy,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.copy,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const Gap(8),
                  InkWell(
                    onTap: onShare,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        AppAsset.share,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const Gap(24),
          Text(
            "ACCOUNT NUMBER",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
              fontFamily: AppFonts.manRope,
            ),
          ),
          const Gap(4),
          TextBold(
            accountNumber,
            fontSize: 28,
            color: AppColors.primaryColor,
          ),
          const Gap(24),
          Text(
            "ACCOUNT NAME",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 1.2,
              fontFamily: AppFonts.manRope,
            ),
          ),
          const Gap(4),
          TextSemiBold(
            accountName,
            fontSize: 15,
          ),
        ],
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
