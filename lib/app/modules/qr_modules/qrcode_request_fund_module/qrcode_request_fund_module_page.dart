import 'package:mcd/core/import/imports.dart';
import './qrcode_request_fund_module_controller.dart';

class QrcodeRequestFundModulePage
    extends GetView<QrcodeRequestFundModuleController> {
  const QrcodeRequestFundModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: 'Request for Fund',
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Scan the other party's QR Code to request fund",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFonts.manRope,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Gap(30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(Routes.SCAN_QRCODE_MODULE);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/scan_icon.svg',
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    height: 20,
                  ),
                  label: const Text(
                    'Scan QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppFonts.manRope,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
