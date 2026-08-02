import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import './qrcode_transfer_details_module_controller.dart';

class QrcodeTransferDetailsModulePage
    extends GetView<QrcodeTransferDetailsModuleController> {
  const QrcodeTransferDetailsModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: 'Transfer',
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
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(224, 224, 224, 1),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Username',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppFonts.manRope,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Obx(() => Text(
                                    controller.scannedUsername,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: AppFonts.manRope,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Email address',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: AppFonts.manRope,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Obx(() => controller.isFetchingUserData
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      controller.scannedEmail,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: AppFonts.manRope,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    )),
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     const Text(
                        //       'Current Wallet',
                        //       style: TextStyle(
                        //         color: Colors.black,
                        //         fontFamily: AppFonts.manRope,
                        //         fontWeight: FontWeight.w500,
                        //         fontSize: 15,
                        //       ),
                        //     ),
                        //     Obx(() => Text(
                        //           '₦${AmountUtil.formatFigure(controller.currentWallet)}',
                        //           style: GoogleFonts.plusJakartaSans(
                        //             color: Colors.black,
                        //             fontWeight: FontWeight.w500,
                        //             fontSize: 15,
                        //           ),
                        //         )),
                        //   ],
                        // ),
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
                        color: Colors.grey,
                        fontFamily: AppFonts.manRope,
                        fontWeight: FontWeight.w400,
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
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Wallet: ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: AppFonts.manRope,
                          fontSize: 13,
                        ),
                      ),
                      Obx(() => Text(
                            '₦${AmountUtil.formatFigure(controller.currentWallet)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: AppFonts.manRope,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: screenHeight(context) * 0.08),
                  Obx(() => BusyButton(
                        title: "Transfer",
                        onTap: controller.transfer,
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
