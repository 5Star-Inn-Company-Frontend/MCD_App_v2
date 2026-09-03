import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/store_front_module/store_front_controller.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/payment_method_item.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/pricing_commission_item.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/stat_item_card.dart';
import 'package:mcd/app/modules/store_front_module/widgets/shared/store_info_card.dart';
import 'package:mcd/app/styles/app_colors.dart';

class StoreFrontPage extends GetView<StoreFrontController> {
  const StoreFrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Storefront',
              style: TextStyle(
                color: AppColors.textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Resell on WhatsApp',
              style: TextStyle(
                color: AppColors.textPrimaryColor2,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StoreInfoCard(),
              const SizedBox(height: 24),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatItemCard(
                    title: "Today's Sales",
                    value: 'N12,450',
                    icon: Icons.trending_up,
                    iconColor: AppColors.primaryColor,
                    iconBackgroundColor: AppColors.lightGreen,
                  ),
                  StatItemCard(
                    title: 'Customers',
                    value: '47',
                    icon: Icons.group_outlined,
                    iconColor: AppColors.lightBlue,
                    iconBackgroundColor: AppColors.skyBlue,
                  ),
                  StatItemCard(
                    title: 'Commission',
                    value: 'N3,820',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.primaryColor,
                    iconBackgroundColor: AppColors.lightGreen,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Your WhatsApp Link',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.filledBorderIColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.boxColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.textPrimaryColor2,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'https://wa.me/2348012345678?text=STORE%20ABC123',
                              style: TextStyle(
                                color:
                                    AppColors.textPrimaryColor.withOpacity(0.7),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3FAF6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {},
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(30),
                                right: Radius.circular(30),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.copy,
                                      color: Colors.black87,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Copy',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: AppColors.textPrimaryColor2,
                          fontSize: 10,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                              text:
                                  'When a customer taps your link, WhatsApp opens with '),
                          TextSpan(
                            text: 'STORE\nABC123',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryColor),
                          ),
                          TextSpan(
                              text: ' prefilled. Our bot then serves them '),
                          TextSpan(
                            text: 'under your store\nwith your prices.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pricing & Commission',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tap to edit',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.filledBorderIColor),
                ),
                child: Column(
                  children: [
                    PricingCommissionItem(
                      icon: Icons.phone_in_talk_outlined,
                      iconColor: AppColors.primaryColor,
                      iconBackgroundColor: AppColors.lightGreen,
                      title: 'Airtime',
                      subtitle: '4 providers - Avg 2.0% off',
                      earnValue: '1.13%',
                      onTap: controller.showSelectProviderDialog,
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    PricingCommissionItem(
                      icon: Icons.wifi,
                      iconColor: AppColors.lightBlue,
                      iconBackgroundColor: AppColors.skyBlue,
                      title: 'Data',
                      subtitle: '4 providers - 28 plans',
                      earnValue: 'Avg N63',
                      onTap: controller.showDataProviderDialog,
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    PricingCommissionItem(
                      icon: Icons.tv,
                      iconColor: AppColors.purpleColor,
                      iconBackgroundColor: AppColors.primaryColorLight,
                      title: 'Cable TV',
                      subtitle: '4 providers - 8 plans',
                      earnValue: 'Avg N206',
                      onTap: controller.showTvProviderDialog,
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    PricingCommissionItem(
                      icon: Icons.bolt,
                      iconColor: AppColors.primaryOrange,
                      iconBackgroundColor:
                          AppColors.primaryOrange.withOpacity(0.1),
                      title: 'Electricity',
                      subtitle: '8 providers - Avg 1.0% off',
                      earnValue: '0.5%',
                      onTap: () {},
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    PricingCommissionItem(
                      icon: Icons.emoji_events_outlined,
                      iconColor: Colors.red,
                      iconBackgroundColor: Colors.red.withOpacity(0.1),
                      title: 'Betting',
                      subtitle: '6 providers - Avg 0.5% off',
                      earnValue: '0.5%',
                      onTap: () {},
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    PricingCommissionItem(
                      icon: Icons.language,
                      iconColor: AppColors.primaryBlue,
                      iconBackgroundColor:
                          AppColors.primaryBlue.withOpacity(0.1),
                      title: "Int'l Airtime",
                      subtitle: '6 providers - Avg 2.5% off',
                      earnValue: '1.5%',
                      onTap: () {},
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    PricingCommissionItem(
                      icon: Icons.public,
                      iconColor: Colors.teal,
                      iconBackgroundColor: Colors.teal.withOpacity(0.1),
                      title: "Int'l Data",
                      subtitle: '6 providers - Avg 2.0% off',
                      earnValue: '1.5%',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guardrail: Your discount cannot exceed our base. Markups capped to prevent predatory pricing.',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Methods',
                style: TextStyle(
                  color: AppColors.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.filledBorderIColor),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => PaymentMethodItem(
                        icon: Icons.credit_card,
                        title: 'Pay with Card',
                        subtitle: 'Customer pays via debit card',
                        value: controller.isPayWithCardEnabled.value,
                        onChanged: controller.togglePayWithCard,
                      ),
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    Obx(
                      () => PaymentMethodItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Virtual Account',
                        subtitle: 'Accept virtual card payments',
                        value: controller.isVirtualAccountEnabled.value,
                        onChanged: controller.toggleVirtualAccount,
                      ),
                    ),
                    const Divider(
                        height: 1, color: AppColors.filledBorderIColor),
                    Obx(
                      () => PaymentMethodItem(
                        icon: Icons.phone_android,
                        title: 'Mobile Money',
                        subtitle: 'MoMo wallet payments',
                        value: controller.isMobileMoneyEnabled.value,
                        onChanged: controller.toggleMobileMoney,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Customers will only see payment options you've enabled.",
                style: TextStyle(
                  color: AppColors.textPrimaryColor2,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
