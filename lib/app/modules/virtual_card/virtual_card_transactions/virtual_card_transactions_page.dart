import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mcd/app/modules/virtual_card/models/virtual_card_transaction_model.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/shimmer_loading.dart';
import 'package:mcd/core/constants/fonts.dart';
import './virtual_card_transactions_controller.dart';

class VirtualCardTransactionsPage
    extends GetView<VirtualCardTransactionsController> {
  const VirtualCardTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Transactions",
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(20),

            // Virtual Card Display
            Obx(() {
              if (controller.cardModel == null) {
                return const SizedBox.shrink();
              }

              final card = controller.cardModel!;
              final balance = controller.cardBalance.value;

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: _buildVirtualCard(
                  balance: '\$${balance.toStringAsFixed(2)}',
                  cardNumber: card.masked,
                  color: _getCardColor(card.brand),
                  brand: card.brand,
                  isActive: card.status == 1,
                  cardHolderName: card.name,
                ),
              );
            }),
            const Gap(30),

            Text(
              'Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: AppFonts.manRope,
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildTransactionShimmer();
                }
                if (controller.transactions.isEmpty) {
                  return Center(
                    child: TextSemiBold(
                      'No transactions yet',
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = controller.transactions[index];
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(50 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildTransactionItem(transaction),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(VirtualCardTransactionModel transaction) {
    final isDebit = transaction.type.toLowerCase() == 'debit';
    final formattedDate =
        DateFormat('MMM dd, yyyy hh:mm a').format(transaction.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSemiBold(
                  transaction.description,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const Gap(4),
                TextSemiBold(
                  formattedDate,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
          Gap(10),
          TextBold(
            '${isDebit ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
            fontSize: 16,
            color: isDebit ? const Color(0xFFF44336) : AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualCard({
    required String balance,
    required String cardNumber,
    required Color color,
    required bool isActive,
    String? brand,
    String? cardHolderName,
  }) {
    String formattedCardNumber = _formatCardNumber(cardNumber);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
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

                  // card holder name + balance
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                      TextBold(
                        balance,
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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

  Color _getCardColor(String? brand) {
    if (brand == null) return Colors.blueGrey;
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1E3A8A);
      case 'mastercard':
        return AppColors.primaryGreen;
      case 'verve':
        return AppColors.primaryGreen;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildTransactionShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        width: double.infinity,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const Gap(6),
                      ShimmerLoading(
                        width: 120,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                ShimmerLoading(
                  width: 80,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          );
        },
      ),
    );
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
}
