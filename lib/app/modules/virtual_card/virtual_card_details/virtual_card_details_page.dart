import 'package:mcd/core/import/imports.dart';
import './virtual_card_details_controller.dart';

class VirtualCardDetailsPage extends GetView<VirtualCardDetailsController> {
  const VirtualCardDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Virtual Card",
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Gap(10),

            // My Card Title
            TextBold(
              'My Card',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            const Gap(30),

            // Card Display with Carousel
            Obx(() {
              if (controller.cards.isEmpty && controller.isFetchingCards.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.cards.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: Text("No cards found"),
                  ),
                );
              }

              return Column(
                children: [
                  // Manual Carousel
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: (index) {
                        controller.currentCardIndex.value = index;
                      },
                      itemCount: controller.cards.length,
                      itemBuilder: (context, index) {
                        final card = controller.cards[index];
                        
                        return Obx(() {
                          final balance = controller.cardBalances[card.id] ?? 0.0;
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _buildVirtualCard(
                              balance: '\$${balance.toStringAsFixed(2)}',
                              cardNumber: card.masked,
                              color: _getCardColor(card.brand),
                              brand: card.brand,
                              isActive: card.status == 1,
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  const Gap(16),
                  
                  // Carousel Indicators
                  if (controller.cards.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.cards.length,
                        (index) => Obx(() {
                          final isActive = controller.currentCardIndex.value == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryColor
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              );
            }),
            const Gap(30),

            // Action Buttons Row
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 700),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.receipt_long_outlined,
                    label: 'Transactions',
                    onTap: () {
                      if (controller.currentCard != null) {
                        Get.toNamed(Routes.VIRTUAL_CARD_TRANSACTIONS,
                            arguments: {
                              'cardId': controller.currentCard!.id,
                              'cardModel': controller.currentCard,
                            });
                      }
                    },
                  ),
                  const Gap(8),
                  Obx(() {
                    final card = controller.currentCard;
                    final isFrozen = card != null && card.status == 0;
                    return _buildActionButton(
                      icon: Icons.ac_unit_outlined,
                      label: isFrozen ? 'Unfreeze' : 'Freeze',
                      onTap: () => _showFreezeDialog(context),
                    );
                  }),
                  const Gap(8),
                  _buildActionButton(
                    icon: Icons.credit_card_outlined,
                    label: 'Details',
                    onTap: () {
                      if (controller.currentCard != null) {
                        Get.toNamed(Routes.VIRTUAL_CARD_FULL_DETAILS,
                            arguments: {'cardModel': controller.currentCard});
                      }
                    },
                  ),
                ],
              ),
            ),
            const Gap(30),

            // Deposit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.currentCard != null) {
                    Get.toNamed(Routes.VIRTUAL_CARD_TOP_UP,
                        arguments: {'cardId': controller.currentCard!.id});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: TextBold(
                  'Deposit',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Gap(50),

            // Manage card Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextSemiBold(
                  'Manage card',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ],
            ),
            const Gap(16),

            // Limits Option
            // _buildManageOption(
            //   icon: Icons.speed_outlined,
            //   iconColor: AppColors.primaryColor,
            //   label: 'Limits',
            //   onTap: () => Get.toNamed(Routes.VIRTUAL_CARD_LIMITS),
            // ),
            // const Gap(12),

            // Change PIN Option
            _buildManageOption(
              icon: Icons.lock_outline,
              iconColor: AppColors.primaryColor,
              label: 'Change PIN',
              onTap: () => Get.toNamed(Routes.VIRTUAL_CARD_CHANGE_PIN),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualCard({
    required String balance,
    required String cardNumber,
    required Color color,
    required bool isActive,
    String? brand,
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
            // Base gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withOpacity(0.85),
                  ],
                ),
              ),
            ),

            // Wave pattern layer 1 (darkest)
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 400,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.3),
                ),
              ),
            ),

            // Wave pattern layer 2
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 350,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.25),
                ),
              ),
            ),

            // Wave pattern layer 3 (lighter)
            Positioned(
              top: -60,
              right: -100,
              child: Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
              ),
            ),

            // Bottom wave layer 1
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 350,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.08),
                ),
              ),
            ),

            // Bottom wave layer 2
            Positioned(
              bottom: -120,
              left: -50,
              child: Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Logo and Contactless Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (brand != null && brand.toLowerCase() == 'mastercard')
                        // Mastercard logo (two circles)
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEB001B),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-12, 0),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF79E1B),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (brand != null)
                        TextBold(
                          brand.toUpperCase(),
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )
                      else
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      const Icon(
                        Icons.contactless_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Balance
                  TextBold(
                    balance,
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  const Gap(16),

                  // Card Number
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextSemiBold(
                      formattedCardNumber,
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.black87,
                size: 24,
              ),
              const Gap(4),
              TextSemiBold(
                label,
                fontSize: 12,
                color: Colors.black87,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageOption({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const Gap(12),
            TextSemiBold(
              label,
              fontSize: 15,
              color: Colors.black87,
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showFreezeDialog(BuildContext context) {
    if (controller.currentCard == null) return;
    
    final card = controller.currentCard!;
    final isActive = card.status == 1;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextBold(
                isActive ? 'Freeze' : 'Unfreeze',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              const Gap(16),
              TextSemiBold(
                isActive
                    ? 'Are you sure you want to freeze your Card?'
                    : 'Are you sure you want to unfreeze your Card?',
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
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Obx(() {
                      final isLoading = controller.isFreezing.value || 
                                       controller.isUnfreezing.value;
                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                Get.back(); // Close confirmation dialog
                                
                                if (isActive) {
                                  await controller.freezeCard(card.id);
                                } else {
                                  await controller.unfreezeCard(card.id);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : TextBold(
                                'Yes',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                      );
                    }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                        'Cancel',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Card has been deleted',
                          backgroundColor: AppColors.successBgColor,
                          colorText: AppColors.textSnackbarColor,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: TextBold(
                        'Delete',
                        fontSize: 16,
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
}
