import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/utils/ui_helpers.dart';
import './pos_withdrawal_module_controller.dart';

class PosWithdrawalModulePage extends GetView<PosWithdrawalModuleController> {
  const PosWithdrawalModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Amount to Withdraw",
        elevation: 0,
        centerTitle: false,
        actions: [],
      ),
      backgroundColor: const Color.fromRGBO(251, 251, 251, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          children: [
            const Gap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Enter Amount',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromRGBO(51, 51, 51, 1),
                  ),
                )
              ],
            ),
            const Gap(10),
            TextField(
              controller: controller.amountController,
              cursorColor: const Color.fromRGBO(51, 51, 51, 1),
              keyboardType: TextInputType.phone,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color.fromRGBO(51, 51, 51, 1),
              ),
              decoration: InputDecoration(
                enabled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(211, 208, 217, 1),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(211, 208, 217, 1),
                    width: 1,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Color.fromRGBO(211, 208, 217, 1),
                    width: 1,
                  ),
                ),
              ),
            ),
            const Gap(20),
            InkWell(
              onTap: () => _showConfirmationDialog(context),
              child: Container(
                height: screenHeight(context) * 0.065,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(90, 187, 123, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Next',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              child: Stack(
                children: [
                  Container(
                    height: screenHeight(context) * 0.3,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Confirm Withdrawal',
                            style: GoogleFonts.manrope(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color.fromRGBO(51, 51, 51, 1),
                            ),
                          ),
                          const Gap(20),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₦',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromRGBO(51, 51, 51, 1),
                                  ),
                                ),
                                TextSpan(
                                  text: '${controller.amountController.text}.00',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Manrope',
                                    color: const Color.fromRGBO(51, 51, 51, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(20),
                          Text(
                            'Are you sure you want to withdraw to your main account?',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w300,
                              color: const Color.fromRGBO(51, 51, 51, 1),
                            ),
                          ),
                          const Gap(20),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              controller.confirmWithdrawal();
                            },
                            child: Container(
                              height: screenHeight(context) * 0.065,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(90, 187, 123, 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'Confirm',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50.0,
                    right: 30.0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close, size: 30),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}
