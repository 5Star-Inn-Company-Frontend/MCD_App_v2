import 'package:mcd/core/import/imports.dart';
import 'dart:developer' as dev;

/// GetX Template Generator - fb.com/htngu.99
///

class VerifyResetPwdOtpPage extends GetView<ResetPasswordController> {
  const VerifyResetPwdOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get email from arguments safely
    final args = Get.arguments as Map<String, dynamic>?;
    final email = args?['email'] ?? controller.emailController.text;
    
    return Scaffold(
      appBar: const PaylonyAppBarTwo(title: ""),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSemiBold("Reset Password", fontSize: 20, fontWeight: FontWeight.w500,),
              
              const Gap(15),
              RichText(
                text: TextSpan(
                  text: "We've sent you a one time verification code to ",
                  style: const TextStyle(
                    color: AppColors.background,
                    fontFamily: AppFonts.manRope,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontFamily: AppFonts.manRope,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Gap(40),
              OTPTextField(
                controller: controller.otpController,
                length: 6,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                width: MediaQuery.of(context).size.width,
                fieldWidth: (MediaQuery.of(context).size.width - 40) / 8,
                spaceBetween: 4,
                otpFieldStyle: OtpFieldStyle(
                  backgroundColor: AppColors.boxColor,
                  borderColor: AppColors.white,
                  enabledBorderColor: Colors.transparent,
                  focusBorderColor: AppColors.primaryColor,
                ),
                style: const TextStyle(
                    fontSize: 17
                ),
                textFieldAlignment: MainAxisAlignment.spaceBetween,
                fieldStyle: FieldStyle.box,
                keyboardType: TextInputType.number,
                onChanged: (pin) {
                  dev.log("OTP Changed: $pin");
                  controller.codeController.text = pin;
                },
                onCompleted: (pin) {
                  dev.log("OTP Completed: $pin, verifying...");
                  final emailToUse = email.isNotEmpty ? email : controller.emailController.text.trim();
                  controller.resetPasswordCheck(context, emailToUse, pin);
                },
              ),

              const Gap(40),
              TextSemiBold("Your 6 digit code is on its way. This can sometimes take a few moments to arrive.", color: AppColors.primaryGrey2,),
              
              const Gap(20),
              Obx(() {
                // Show countdown and a Resend button when timer is 0:00
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Resend code in ',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: AppFonts.manRope,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '${controller.minutes.value} :${controller.seconds.value.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.manRope,
                                color: AppColors.background
                            ),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    // Show resend button only when countdown reached 0:00
                    if (controller.canResend) ...[
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          // call resend; controller will restart the timer on success
                          final emailToUse = email.isNotEmpty ? email : controller.emailController.text.trim();
                          controller.resendOtp(context, emailToUse);
                        },
                        child: TextSemiBold("Resend code", color: AppColors.primaryColor,),
                      )
                    ]
                  ],
                );
              }),

              // Spacer(),



            ],
          ),
        ),
      )
    );
  }
}