import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mcd/app/modules/virtual_card/models/virtual_card_model.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/shimmer_loading.dart';
import 'package:mcd/core/constants/fonts.dart';
import './virtual_card_full_details_controller.dart';

class VirtualCardFullDetailsPage
    extends GetView<VirtualCardFullDetailsController> {
  const VirtualCardFullDetailsPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Virtual Card",
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isFetching.value) {
          return _buildShimmerLoading();
        }

        if (controller.card.value == null) {
          return const Center(child: Text("Card not found"));
        }

        final card = controller.card.value!;

        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: AnimatedBuilder(
                  animation: controller.flipAnimation,
                  builder: (context, child) {
                    final angle = controller.flipAnimation.value;
                    final showBack = angle > math.pi / 2;

                    // counter-rotate the back face so text reads correctly
                    final displayAngle = showBack ? angle - math.pi : angle;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(displayAngle),
                      child: showBack
                          ? _buildVirtualCardBack(
                              card: card,
                              color: _getCardColor(card.brand),
                            )
                          : _buildVirtualCard(
                              cardNumber: card.masked,
                              color: _getCardColor(card.brand),
                              brand: card.brand,
                              isActive: card.status == 1,
                              cardHolderName: card.name,
                            ),
                    );
                  },
                ),
              ),
            ),

            // Show/Hide Detail Button
            GestureDetector(
              onTap: controller.toggleDetails,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextSemiBold(
                      controller.isDetailsVisible.value
                          ? 'Hide Detail'
                          : 'Show Detail',
                      fontSize: 14,
                      color: AppColors.primaryColor,
                    ),
                    const Gap(8),
                    Icon(
                      controller.isDetailsVisible.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(
                  0,
                  controller.isDetailsVisible.value ? 0 : -500,
                  0,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: controller.isDetailsVisible.value ? 1.0 : 0.0,
                  child: Visibility(
                    visible: controller.isDetailsVisible.value,
                    maintainAnimation: true,
                    maintainState: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            context,
                            'Name',
                            card.name,
                          ),
                          const Gap(20),
                          _buildDetailRow(
                            context,
                            'Card Number',
                            card.cardNumber,
                          ),
                          const Gap(20),
                          _buildDetailRow(
                            context,
                            'CVV',
                            card.cvv,
                          ),
                          const Gap(20),
                          _buildDetailRow(
                            context,
                            'Expiry Date',
                            card.expiryDate,
                          ),
                          const Gap(20),
                          _buildDetailRow(
                            context,
                            'Currency',
                            card.currency,
                          ),
                          const Gap(20),
                          _buildDetailRow(
                            context,
                            'Address',
                            _formatAddress(card.address),
                          ),
                          const Gap(40),

                          // Delete Card Button
                          if (controller.isDeleting.value)
                            const CircularProgressIndicator()
                          else
                            TextButton(
                              onPressed: () {
                                _showDeleteConfirmation(context);
                              },
                              child: TextSemiBold(
                                'Delete Card',
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextSemiBold(
          label,
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
        const Gap(12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: TextSemiBold(
                  value,
                  fontSize: 14,
                  color: Colors.black87,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Get.snackbar(
                    'Copied',
                    '$label copied to clipboard',
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    colorText: AppColors.primaryColor,
                    duration: const Duration(seconds: 2),
                    snackPosition: SnackPosition.TOP,
                    margin: const EdgeInsets.all(20),
                  );
                },
                child: Icon(
                  Icons.copy,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBold(
                'Delete Card',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              const Gap(16),
              TextSemiBold(
                'Are you sure you want to delete this card?',
                fontSize: 15,
                color: Colors.grey.shade600,
                textAlign: TextAlign.center,
              ),
              const Gap(30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextSemiBold(
                        'No',
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        controller.deleteCard();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextBold(
                        'Yes',
                        fontSize: 15,
                        color: Colors.white,
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

  Widget _buildVirtualCard({
    required String cardNumber,
    required Color color,
    required bool isActive,
    String? brand,
    String? cardHolderName,
  }) {
    String formattedCardNumber = _formatCardNumber(cardNumber);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // card background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/virtual_card/mycard.png',
                fit: BoxFit.cover,
              ),
            ),

            // card content overlay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // brand logo
                  _buildBrandLogo(brand),
                  const Spacer(),

                  // masked card number
                  TextBold(
                    formattedCardNumber,
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  const Gap(12),

                  // card holder name
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextSemiBold(
                              'Card Holder name',
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const Gap(2),
                            TextBold(
                              cardHolderName ?? '',
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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

  Widget _buildVirtualCardBack({
    required VirtualCardModel card,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // card background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/virtual_card/mycard.png',
                fit: BoxFit.cover,
              ),
            ),

            // magnetic stripe
            Positioned(
              top: 36,
              left: 0,
              right: 0,
              child: Container(
                height: 44,
                color: Colors.black.withOpacity(0.85),
              ),
            ),

            // cvv + expiry
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // cvv strip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CVV',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontFamily: AppFonts.manRope,
                          ),
                        ),
                        Text(
                          card.cvv.isNotEmpty ? card.cvv : '•••',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: AppFonts.manRope,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(10),

                  // expiry date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        card.expiryDate.isNotEmpty
                            ? 'Exp: ${card.expiryDate}'
                            : '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.manRope,
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

  Widget _buildBrandLogo(String? brand) {
    if (brand == null) {
      return const SizedBox(height: 30);
    }
    switch (brand.toLowerCase()) {
      case 'visa':
        return TextBold(
          'VISA',
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.w800,
        );
      case 'mastercard':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEB001B),
              ),
            ),
            Transform.translate(
              offset: const Offset(-10, 0),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF79E1B),
                ),
              ),
            ),
          ],
        );
      default:
        return TextBold(
          brand.toUpperCase(),
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        );
    }
  }

  String _formatCardNumber(String cardNumber) {
    String cleaned = cardNumber.replaceAll(RegExp(r'[\s\-\*]'), '');

    if (cardNumber.contains('*')) {
      if (cardNumber.split(' ').length == 4) {
        return cardNumber;
      }
      return cardNumber.replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    if (cleaned.length >= 16) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)} ${cleaned.substring(12, 16)}';
    } else if (cleaned.length >= 12) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)} ${cleaned.substring(12)}';
    } else if (cleaned.length >= 8) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8)}';
    } else if (cleaned.length >= 4) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4)}';
    }

    return cardNumber;
  }

  String _formatAddress(String? address) {
    if (address == null || address.isEmpty) return 'N/A';

    try {
      dynamic decoded = jsonDecode(address);

      // handle double-encoded json strings
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }

      if (decoded is Map<String, dynamic>) {
        final street = decoded['street']?.toString() ?? '';
        final city = decoded['city']?.toString() ?? '';
        final state = decoded['state']?.toString() ?? '';
        final country = decoded['country']?.toString() ?? '';
        final postalCode = decoded['postal_code']?.toString() ?? '';

        List<String> addressParts = [];
        if (street.isNotEmpty) addressParts.add(street);
        if (city.isNotEmpty) addressParts.add(city);
        if (state.isNotEmpty) addressParts.add(state);
        if (country.isNotEmpty) addressParts.add(country);
        if (postalCode.isNotEmpty) addressParts.add(postalCode);

        return addressParts.isEmpty ? 'N/A' : addressParts.join(', ');
      }

      return address;
    } catch (e) {
      // not json, return as-is
      return address;
    }
  }

  Color _getCardColor(String? brand) {
    if (brand == null) return Colors.blueGrey;
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1E3A8A); // Blue
      case 'mastercard':
        return AppColors.primaryGreen;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ShimmerLoading(
                width: double.infinity,
                height: 220,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ShimmerLoading(
            width: 120,
            height: 40,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                8,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerLoading(
                        width: 100,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      ShimmerLoading(
                        width: 150,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
