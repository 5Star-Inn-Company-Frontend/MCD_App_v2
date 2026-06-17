import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'package:mcd/app/modules/virtual_card/virtual_card_top_up/virtual_card_top_up_controller.dart';
import 'package:mcd/core/import/imports.dart';

class VcardReceipt extends StatefulWidget {
  const VcardReceipt({super.key});

  @override
  State<VcardReceipt> createState() => _VcardReceiptState();
}

class _VcardReceiptState extends State<VcardReceipt> {
  late ConfettiController _confettiController;
  final GlobalKey _receiptKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    // Start confetti animation
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get data from navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final amount = args?['amount'] as double? ?? 0.0;
    final timestamp = args?['timestamp'] as DateTime? ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(timestamp);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(16, 93, 56, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(16, 93, 56, 1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () => Get.offAllNamed(Routes.HOME_SCREEN),
              child: TextSemiBold(
                'Go Home',
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const Gap(40),
              Center(
                child: TextSemiBold(
                  'Payment Receipt',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Gap(20),
              RepaintBoundary(
                key: _receiptKey,
                child: Container(
                  height: MediaQuery.sizeOf(context).height * 0.75,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/virtual_card/vcard_receipt.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Image.asset(
                              'assets/images/virtual_card/success-icon.png',
                              width: 90,
                              height: 90),
                          const Gap(30),

                          TextBold(
                            'Payment Success',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          const Gap(12),

                          // Success Message
                          TextSemiBold(
                            'You have successfully funded your dollar card',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            textAlign: TextAlign.center,
                          ),
                          const Gap(30),

                          TextSemiBold(
                            'Total Payment',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          const Gap(8),

                          TextBold(
                            '\$${amount.toStringAsFixed(2)}',
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ],
                      ),

                      // Divider(
                      //   color: Colors.grey.shade300,
                      //   thickness: 1,
                      // ),
                      // const Gap(20),

                      Column(
                        children: [
                          // const Gap(40),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextSemiBold(
                              'Payment for',
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const Gap(16),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.credit_card,
                                    color: AppColors.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextBold(
                                        'Top Up',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
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
                              ],
                            ),
                          ),
                          Gap(40),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.offNamed(Routes.VIRTUAL_CARD_DETAILS);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: TextBold(
                                'Done',
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Gap(16),

                          TextButton(
                            onPressed: () {
                              Get.offNamed(Routes.VIRTUAL_CARD_TOP_UP);
                            },
                            child: TextSemiBold(
                              'Top up again',
                              fontSize: 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // radians (downward)
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Color(0xFFFDB750),
                Color(0xFF105D38),
                Colors.green,
                Colors.orange,
                Colors.yellow,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
