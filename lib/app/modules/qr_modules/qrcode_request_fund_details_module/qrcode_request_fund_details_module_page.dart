import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import './qrcode_request_fund_details_module_controller.dart';

class QrcodeRequestFundDetailsModulePage
    extends GetView<QrcodeRequestFundDetailsModuleController> {
  const QrcodeRequestFundDetailsModulePage({super.key});

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
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  Container(
                    height: screenHeight(context) * 0.14,
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 24,
                      bottom: 24,
                      right: 10,
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(224, 224, 224, 1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Username',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: AppFonts.manRope,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            Obx(() => Text(
                                  controller.scannedUsername,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: AppFonts.manRope,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Email address',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: AppFonts.manRope,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            Obx(() => Text(
                                  controller.scannedEmail,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: AppFonts.manRope,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight(context) * 0.04),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Amount',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: AppFonts.manRope,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: controller.amountController,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: AppFonts.manRope,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontFamily: AppFonts.manRope,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(224, 224, 224, 1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(224, 224, 224, 1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight(context) * 0.02),
                  // Hidden QR code for capturing
                  Opacity(
                    opacity: 0.0,
                    child: SizedBox(
                      height: 1,
                      width: 1,
                      child: RepaintBoundary(
                        key: controller.qrKey,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Fund Request',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: AppFonts.manRope,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(() => Text(
                                    'Amount: ₦${controller.amountController.text}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: AppFonts.manRope,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  )),
                              const SizedBox(height: 10),
                              Obx(() => Text(
                                    'To: @${controller.scannedUsername}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: AppFonts.manRope,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  )),
                              const SizedBox(height: 20),
                              Obx(() => QrImageView(
                                    data: '${controller.scannedUsername}|${controller.amountController.text}',
                                    version: QrVersions.auto,
                                    size: 300,
                                    gapless: true,
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: Color.fromRGBO(51, 160, 88, 1),
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.square,
                                      color: Color.fromRGBO(51, 160, 88, 1),
                                    ),
                                    embeddedImage: const AssetImage('assets/images/mcdagentlogo.png'),
                                    embeddedImageStyle: const QrEmbeddedImageStyle(
                                      size: Size(60, 60),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight(context) * 0.08),
                  Obx(() => BusyButton(
                        title: "Request Transfer",
                        onTap: controller.requestFund,
                        isLoading: controller.isLoading,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
