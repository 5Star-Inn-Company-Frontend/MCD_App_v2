import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/general_payout/general_payout_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/app/widgets/touchableOpacity.dart';
import 'package:mcd/core/constants/fonts.dart';
import 'package:mcd/core/services/general_market_payment_service.dart';
import 'package:mcd/core/utils/amount_formatter.dart';

class GeneralPayoutPage extends GetView<GeneralPayoutController> {
  const GeneralPayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: const PaylonyAppBarTwo(title: "Payout", centerTitle: false),
        body: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Gap(30),
                _buildHeader(),
                const Gap(30),
                _buildDetailsCard(),

                // Cable-specific bouquet card
                if (controller.paymentType == PaymentType.cable) ...[
                  const Gap(20),
                  _buildBouquetCard(),
                ],

                // Cable action buttons or package selection
                if (controller.paymentType == PaymentType.cable) ...[
                  const Gap(20),
                  Obx(() {
                    if (!controller.isRenewalMode.value &&
                        !controller.showPackageSelection.value) {
                      return _buildCableActionButtons();
                    } else if (controller.showPackageSelection.value) {
                      return Column(
                        children: [
                          _buildMonthTabs(),
                          const Gap(20),
                          _buildPackageSelection(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],

                // // Points widget (electricity only)
                // if (controller.paymentType == PaymentType.electricity) ...[
                //   const Gap(20),
                //   _buildPointsSwitch(),
                // ],

                if (_isPromoEnabled()) ...[
                  const Gap(20),
                  _buildPromoCodeField(),
                ],

                const Gap(20),
                _buildPaymentMethod(),
                const Gap(40),
                Obx(() => BusyButton(
                      title: "Confirm & Pay",
                      onTap: controller.confirmAndPay,
                      isLoading: controller.isPaying.value,
                    )),
                const Gap(20),
              ],
            ),
          ),
        ));
  }

  Widget _buildHeader() {
    // Multiple airtime special header
    if (controller.paymentType == PaymentType.airtime &&
        controller.isMultipleAirtime.value) {
      final totalAmount = controller.multipleAirtimeList
          .fold<double>(0, (sum, item) => sum + double.parse(item['amount']));
      return Column(
        children: [
          const Icon(Icons.people_alt, size: 60, color: Color(0xFF5ABB7B)),
          const Gap(10),
          const Text(
            'Multiple Airtime',
            style: TextStyle(
                fontFamily: AppFonts.manRope,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          const Gap(5),
          Text(
            '${controller.multipleAirtimeList.length} Recipients',
            style: TextStyle(
                fontFamily: AppFonts.manRope, fontSize: 14, color: Colors.grey),
          ),
          const Gap(10),
          Text(
            '₦${AmountUtil.formatFigure(totalAmount)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5ABB7B),
            ),
          ),
        ],
      );
    }

    // Standard header with image
    return Column(
      children: [
        if (controller.serviceImage.isNotEmpty)
          Image.asset(
            controller.serviceImage,
            height: 80,
            width: 80,
            errorBuilder: (context, error, stackTrace) => Icon(
              _getDefaultIcon(),
              size: 80,
              color: AppColors.primaryColor,
            ),
          ),
        const Gap(10),
        Text(
          controller.serviceName,
          style: TextStyle(
              fontFamily: AppFonts.manRope,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  IconData _getDefaultIcon() {
    switch (controller.paymentType) {
      case PaymentType.airtime:
      case PaymentType.airtimePin:
        return Icons.phone_android;
      case PaymentType.data:
      case PaymentType.dataPin:
        return Icons.data_usage;
      case PaymentType.electricity:
        return Icons.bolt;
      case PaymentType.cable:
        return Icons.tv;
      case PaymentType.ninValidation:
        return Icons.credit_card;
      case PaymentType.resultChecker:
        return Icons.school;
      case PaymentType.epin:
        return Icons.confirmation_number;
      case PaymentType.betting:
        return Icons.sports_esports;
    }
  }

  Widget _buildDetailsCard() {
    // Multiple airtime list
    if (controller.paymentType == PaymentType.airtime &&
        controller.isMultipleAirtime.value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSemiBold('Recipients', fontSize: 15),
          const Gap(10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.multipleAirtimeList.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final item = controller.multipleAirtimeList[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.asset(item['networkImage'] ?? '',
                        width: 30, height: 30),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['phoneNumber'] ?? 'N/A',
                            style: TextStyle(
                                fontFamily: AppFonts.manRope,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            (item['provider']?.network)?.toUpperCase() ?? 'N/A',
                            style: TextStyle(
                                fontFamily: AppFonts.manRope,
                                fontSize: 12,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₦${AmountUtil.formatFigure(double.tryParse((item['amount'] ?? '0').toString()) ?? 0)}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }

    // Standard details card
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: controller.detailsRows
            .map((row) => _rowCard(row['label']!, row['value']!))
            .toList(),
      ),
    );
  }

  Widget _buildBouquetCard() {
    return Obx(() => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _rowCard('Current Bouquet',
                  controller.cableBouquetDetails['currentBouquet'] ?? 'N/A'),
              _rowCard('Bouquet Price',
                  '₦${AmountUtil.formatFigure(double.tryParse((controller.cableBouquetDetails['bouquetPrice'] ?? '0').toString()) ?? 0)}'),
              _rowCard('Due Date',
                  controller.cableBouquetDetails['dueDate'] ?? 'N/A'),
              _rowCard(
                  'Status', controller.cableBouquetDetails['status'] ?? 'N/A'),
            ],
          ),
        ));
  }

  Widget _buildCableActionButtons() {
    return Column(
      children: [
        BusyButton(
          title: "Renew Current Bouquet",
          onTap: controller.selectRenewal,
        ),
        const Gap(15),
        BusyButton(
          title: "Change Bouquet",
          onTap: controller.selectNewPackage,
        ),
      ],
    );
  }

  Widget _buildMonthTabs() {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryGrey.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: controller.cableMonthTabs.map((item) {
                bool isSelected = item == controller.selectedCableMonth.value;
                return TouchableOpacity(
                  onTap: () => controller.onCableMonthSelected(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      border: Border(
                        right: item == controller.cableMonthTabs.last
                            ? BorderSide.none
                            : const BorderSide(color: AppColors.primaryGrey),
                      ),
                    ),
                    child: TextSemiBold(
                      item,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.textPrimaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ));
  }

  Widget _buildPackageSelection() {
    return Obx(() {
      if (controller.isLoadingPackages.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      if (controller.cablePackages.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: const Text(
            'No packages available',
            style: TextStyle(fontFamily: AppFonts.manRope, color: Colors.grey),
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(maxHeight: 400),
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.cablePackages.length,
            itemBuilder: (context, index) {
              final package = controller.cablePackages[index];
              final isSelected =
                  controller.selectedCablePackage.value?['id']?.toString() ==
                      package['id']?.toString();

              return TouchableOpacity(
                onTap: () => controller.onCablePackageSelected(package),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryColor
                          : const Color(0xffE0E0E0),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          package['name'] ?? 'N/A',
                          style: TextStyle(
                            fontFamily: AppFonts.manRope,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  // Widget _buildPointsSwitch() {
  //   return Obx(() => Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: const Color(0xffE0E0E0)),
  //           borderRadius: BorderRadius.circular(8),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             TextSemiBold('Points', fontSize: 14),
  //             Row(
  //               children: [
  //                 Text(
  //                   '₦${AmountUtil.formatFigure(double.tryParse(controller.pointsBalance.value.toString()) ?? 0)} available',
  //                   style: GoogleFonts.plusJakartaSans(fontSize: 14),
  //                 ),
  //                 const Gap(8),
  //                 Switch(
  //                   value: controller.usePoints.value,
  //                   onChanged: controller.toggleUsePoints,
  //                   activeColor: AppColors.primaryColor,
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ));
  // }

  Widget _buildPromoCodeField() {
    final box = GetStorage();
    final savedPromoCode = box.read('saved_promo_code');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSemiBold('Promo Code', fontSize: 14),
          const Gap(9),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.promoCodeController,
                  style: TextStyle(
                    fontFamily: AppFonts.manRope,
                    fontSize: 14,
                    color: AppColors.background,
                  ),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter promo code',
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.manRope,
                      fontSize: 14,
                      color: AppColors.primaryGrey2,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primaryGrey2,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (controller.promoCodeController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: controller.clearPromoCode,
                ),
            ],
          ),
          // saved promo code suggestion
          if (savedPromoCode != null &&
              savedPromoCode.toString().isNotEmpty) ...[
            const Gap(12),
            GestureDetector(
              onTap: () {
                controller.promoCodeController.text = savedPromoCode.toString();
                controller.promoCodeController.text = savedPromoCode.toString();
                // clear saved promo after applied - MOVED to controller success
                box.remove('saved_promo_code');
                box.remove('saved_promo_message');
                Get.snackbar(
                  'Applied!',
                  'Promo code applied',
                  backgroundColor: AppColors.successBgColor,
                  colorText: AppColors.textSnackbarColor,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.card_giftcard,
                        size: 16, color: AppColors.primaryColor),
                    const Gap(8),
                    Text(
                      'Use saved code: ${_maskPromoCode(savedPromoCode.toString())}',
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Apply',
                      style: TextStyle(
                        fontFamily: AppFonts.manRope,
                        fontSize: 12,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _maskPromoCode(String code) {
    if (code.length <= 4) return code;
    return '${code.substring(0, 4)}${'*' * (code.length - 4)}';
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSemiBold('Payment Method', fontSize: 14),
        const Gap(9),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() {
            final isWalletAvailable =
                controller.isPaymentMethodAvailable('wallet');
            final isGeneralMarketAvailable =
                controller.isPaymentMethodAvailable('pay_gm');
            final isPaystackAvailable =
                controller.isPaymentMethodAvailable('paystack');

            return Column(
              children: [
                Opacity(
                  opacity: isWalletAvailable ? 1.0 : 0.4,
                  child: RadioListTile<int>(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Wallet (₦${AmountUtil.formatFigure(double.tryParse(controller.walletBalance.value) ?? 0)})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: isWalletAvailable
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        if (!isWalletAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Unavailable',
                              style: TextStyle(
                                fontFamily: AppFonts.manRope,
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    value: 1,
                    groupValue: controller.selectedPaymentMethod.value,
                    onChanged: isWalletAvailable
                        ? (value) => controller.selectPaymentMethod(value)
                        : null,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFF5ABB7B),
                  ),
                ),
                const Divider(height: 1),
                Opacity(
                  opacity: isGeneralMarketAvailable ? 1.0 : 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<int>(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'General Market (₦${AmountUtil.formatFigure(double.tryParse(controller.gmBalance.value) ?? 0)})',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: isGeneralMarketAvailable
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            if (!isGeneralMarketAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Unavailable',
                                  style: TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        value: 2,
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: isGeneralMarketAvailable
                            ? (value) => controller.selectPaymentMethod(value)
                            : null,
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF5ABB7B),
                      ),
                      if (isGeneralMarketAvailable)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 14, color: Colors.red),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'FREE for use. But expect ${GeneralMarketPaymentService.requiredAdsCount} ads while the server is processing your order',
                                  style: const TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    fontSize: 11,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Opacity(
                  opacity: isPaystackAvailable ? 1.0 : 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<int>(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Paystack (1.5% Fee)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: isPaystackAvailable
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            if (!isPaystackAvailable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Unavailable',
                                  style: TextStyle(
                                    fontFamily: AppFonts.manRope,
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        value: 3,
                        groupValue: controller.selectedPaymentMethod.value,
                        onChanged: isPaystackAvailable
                            ? (value) => controller.selectPaymentMethod(value)
                            : null,
                        controlAffinity: ListTileControlAffinity.trailing,
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFF5ABB7B),
                      ),
                      if (controller.selectedPaymentMethod.value == 3 &&
                          isPaystackAvailable)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 10),
                          child: Builder(builder: (_) {
                            final base = controller.transactionAmount;
                            final fee =
                                base * GeneralPayoutController.paystackFeeRate;
                            final total = base + fee;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fee: ₦${AmountUtil.formatFigure(fee)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total Fee: ₦${AmountUtil.formatFigure(total)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _rowCard(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextSemiBold(title, fontSize: 15),
          Flexible(
            child: Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(fontSize: 15),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  bool _isPromoEnabled() {
    final box = GetStorage();
    final storedValue = box.read('promo_enabled');
    if (storedValue is bool) {
      return storedValue;
    } else if (storedValue is String) {
      return storedValue.toLowerCase() == 'true';
    }
    return false;
  }
}
