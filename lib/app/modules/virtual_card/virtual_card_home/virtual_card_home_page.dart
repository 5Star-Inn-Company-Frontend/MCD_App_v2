import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/core/import/imports.dart';

import './virtual_card_home_controller.dart';

class VirtualCardHomePage extends GetView<VirtualCardHomeController> {
  const VirtualCardHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.offAllNamed(Routes.HOME_SCREEN),
          ),
          title: TextSemiBold(
            'Virtual Card',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          centerTitle: false,
        ),
        body: _buildEmptyState());
  }

  Widget _buildEmptyState() {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(20),

              // Top circular icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleIcon(
                      Color.fromRGBO(51, 160, 88, 0.1),
                      Image.asset(
                          'assets/images/virtual_card/transfer-icon.png')),
                  Gap(80),
                  _buildCircleIcon(
                      Color.fromRGBO(51, 160, 85, 0.1),
                      Image.asset(
                          'assets/images/virtual_card/transfer2-icon.png',
                          width: 48,
                          height: 48)),
                ],
              ),
              Gap(10),

              // Center icon
              Center(
                  child: _buildCircleIcon(Color.fromRGBO(51, 160, 85, 0.1),
                      Image.asset('assets/images/virtual_card/card-icon.png'))),

              Gap(30),

              // Stacked Cards Image
              Center(
                child: Image.asset(
                  'assets/images/virtual_card/vcards_home_screen.png',
                  height: 220,
                  width: 220,
                ),
              ),

              const Gap(20),

              Text(
                'Your international',
                style: GoogleFonts.montserrat(
                    fontSize: 24, fontWeight: FontWeight.w900),
              ),

              Text(
                'payments just got easier',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryColor2,
                ),
              ),
              const Gap(24),

              // Description
              TextSemiBold(
                'You now have access to Reserved Virtual USD cards. With them, you can make international payments, manage software subscriptions, and all foreign expenses. Want to get started? Click the button below.',
                fontSize: 14,
                color: Colors.black,
                maxLines: 10,
              ),
              const Gap(40),

              SizedBox(
                width: 200,
                height: 56,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.VIRTUAL_CARD_REQUEST);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffE0F1E6),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Gap(40),
                            TextBold(
                              'Get Started',
                              fontSize: 16,
                              color: AppColors.primaryColor2,
                              fontWeight: FontWeight.w900,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(17.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor2,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleIcon(Color bgColor, Image image) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: image,
    );
  }
}
