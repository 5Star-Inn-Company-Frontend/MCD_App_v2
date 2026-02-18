import 'package:mcd/core/import/imports.dart';
import './qrcode_module_controller.dart';

class QrcodeModulePage extends GetView<QrcodeModuleController> {
  const QrcodeModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: 'My QR Code',
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
          child: Column(
            children: [
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.MY_QRCODE_MODULE);
                    },
                    child: _qrContainer(
                      context,
                      'assets/icons/bx_scan.svg',
                      'My QR Code',
                      'Your Unique QR Code',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.QRCODE_TRANSFER_MODULE);
                    },
                    child: _qrContainer(
                      context,
                      'assets/icons/qr_transfer.svg',
                      'Transfer',
                      'Transfer to any wallet',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.QRCODE_REQUEST_FUND_MODULE);
                    },
                    child: _qrContainer(
                      context,
                      'assets/icons/qr-request.svg',
                      'Request for Fund',
                      'Request for fund from your friends',
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

  Widget _qrContainer(
    BuildContext context,
    String icon,
    String text1,
    String text2,
  ) {
    return Container(
      alignment: Alignment.center,
      height: screenHeight(context) * 0.2,
      width: screenWidth(context) * 0.4,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(243, 255, 247, 1),
        border: Border.all(
          width: 1,
          color: const Color.fromRGBO(240, 240, 240, 1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            SvgPicture.asset(icon),
            const SizedBox(height: 10),
            TextBold(
              text1,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 17),
            Text(
              text2,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontFamily: AppFonts.manRope,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
