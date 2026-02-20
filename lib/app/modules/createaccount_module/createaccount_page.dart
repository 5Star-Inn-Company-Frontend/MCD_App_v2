import 'package:mcd/core/import/imports.dart';
import 'createaccount_controller.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class createaccountPage extends GetView<createaccountController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: BackButton(
          color: AppColors.primaryColor,
          onPressed: () {
            Get.offNamed(Routes.LOGIN_SCREEN);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Obx(() {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSemiBold(
                    "Create an account",
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  const Gap(15),

                  /// Username
                  TextSemiBold("Username"),
                  const Gap(8),
                  TextFormField(
                    controller: controller.usernameController,
                    validator: (value) =>
                        CustomValidator.isEmptyString(value!, "username"),
                    onChanged: (_) => controller.validateForm(),
                    style: const TextStyle(fontFamily: AppFonts.manRope),
                    decoration: textInputDecoration.copyWith(
                      hintText: "samji222",
                      hintStyle: const TextStyle(
                          color: AppColors.primaryGrey2,
                          fontFamily: AppFonts.manRope),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: controller.usernameController.text.isNotEmpty
                              ? AppColors.primaryColor
                              : AppColors.primaryGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const Gap(25),

                  /// Email
                  TextSemiBold("Email address"),
                  const Gap(8),
                  TextFormField(
                    controller: controller.emailController,
                    validator: (value) {
                      CustomValidator.isEmptyString(value!, "email");
                      if (!CustomValidator.validEmail(value)) {
                        return "Invalid Email";
                      }
                      return null;
                    },
                    style: const TextStyle(fontFamily: AppFonts.manRope),
                    onChanged: (_) => controller.validateForm(),
                    keyboardType: TextInputType.emailAddress,
                    decoration: textInputDecoration.copyWith(
                      hintText: "name@mail.com",
                      hintStyle: const TextStyle(
                          color: AppColors.primaryGrey2,
                          fontFamily: AppFonts.manRope),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: controller.emailController.text.isNotEmpty
                              ? AppColors.primaryColor
                              : AppColors.primaryGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  const Gap(25),

                  /// Phone
                  TextSemiBold("Phone number"),
                  const Gap(8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: controller.phoneNumberController.text.isNotEmpty
                            ? AppColors.primaryColor
                            : AppColors.primaryGrey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // flag and country code
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: AppColors.primaryGrey),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icons/nigeria-flag.png',
                                width: 24,
                                height: 18,
                              ),
                              const Gap(8),
                              TextSemiBold(
                                "+234",
                                fontSize: 14,
                                color: AppColors.textPrimaryColor,
                              ),
                            ],
                          ),
                        ),
                        // phone number input
                        Expanded(
                          child: TextFormField(
                            controller: controller.phoneNumberController,
                            validator: (value) =>
                                CustomValidator.isEmptyString(value!, "phone"),
                            onChanged: (_) => controller.validateForm(),
                            keyboardType: TextInputType.phone,
                            style:
                                const TextStyle(fontFamily: AppFonts.manRope),
                            decoration: InputDecoration(
                              hintText: "8012345678",
                              hintStyle: const TextStyle(
                                color: AppColors.primaryGrey2,
                                fontFamily: AppFonts.manRope,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(25),

                  /// Password
                  TextSemiBold("Password"),
                  const Gap(8),
                  TextFormField(
                    controller: controller.passwordController,
                    obscureText: !controller.isPasswordVisible,
                    obscuringCharacter: '•',
                    validator: (value) =>
                        CustomValidator.validateStrongPassword(value),
                    onChanged: (_) => controller.validateForm(),
                    style: const TextStyle(fontFamily: AppFonts.manRope),
                    decoration: textInputDecoration.copyWith(
                      hintText: "••••••••••••••",
                      hintStyle: const TextStyle(
                        color: AppColors.primaryGrey2,
                        fontSize: 20,
                        letterSpacing: 3,
                        fontFamily: AppFonts.manRope,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: controller.passwordController.text.isNotEmpty
                              ? AppColors.primaryColor
                              : AppColors.primaryGrey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.primaryColor, width: 2),
                      ),                                                                          
                      suffixIcon: IconButton(
                          onPressed: () {
                            controller.isPasswordVisible =
                                !controller.isPasswordVisible;
                          },
                          icon: controller.isPasswordVisible
                              ? const Icon(Icons.visibility_off_outlined,
                                  color: AppColors.background)
                              : const Icon(Icons.visibility_outlined,
                                  color: AppColors.background)),
                    ),
                  ),
                  const Gap(12),

                  /// Password Strength Indicator
                  if (controller.passwordController.text.isNotEmpty) ...[
                    Row(
                      children: [
                        TextSemiBold(
                          "Password Strength: ",
                          fontSize: 12,
                          color: AppColors.primaryGrey2,
                        ),
                        TextSemiBold(
                          controller.passwordStrengthLabel,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStrengthColor(controller.passwordStrength),
                        ),
                      ],
                    ),
                    const Gap(8),
                    // Strength bar
                    Row(
                      children: List.generate(4, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                            decoration: BoxDecoration(
                              color: index < controller.passwordStrength
                                  ? _getStrengthColor(
                                      controller.passwordStrength)
                                  : AppColors.primaryGrey2.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const Gap(12),

                    /// Password Requirements Checklist
                    _buildRequirement(
                      "At least 8 characters",
                      controller.hasMinLength,
                    ),
                    const Gap(6),
                    _buildRequirement(
                      "Starts with uppercase letter",
                      controller.startsWithUppercase,
                    ),
                    const Gap(6),
                    _buildRequirement(
                      "Contains uppercase letter (A-Z)",
                      controller.hasUppercase,
                    ),
                    const Gap(6),
                    _buildRequirement(
                      "Contains lowercase letter (a-z)",
                      controller.hasLowercase,
                    ),
                    const Gap(6),
                    _buildRequirement(
                      "Contains number (0-9)",
                      controller.hasNumber,
                    ),
                    const Gap(6),
                    _buildRequirement(
                      "Contains special character (!@#\$%^&*)",
                      controller.hasSpecialChar,
                    ),
                    const Gap(20),
                  ],

                  /// Submit
                  GestureDetector(
                    onTap: () async {
                      if (controller.formKey.currentState == null) return;
                      if (controller.formKey.currentState!.validate()) {
                        var result = await Get.toNamed(Routes.VERIFY_OTP,
                            arguments: controller.emailController.text.trim());
                        if (result != null) {
                          controller.createaccount(result, context);
                        } else {
                          Get.snackbar(
                            "Verification Cancelled",
                            "You cancelled the verification process. Please try again when ready.",
                            backgroundColor: AppColors.infoBgColor,
                            colorText: AppColors.textSnackbarColor,
                            icon: const Icon(Icons.info_outline,
                                color: Colors.white),
                          );
                        }
                      }
                    },
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: controller.isFormValid
                            ? AppColors.primaryColor
                            : AppColors.primaryGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock,
                              color: AppColors.white.withOpacity(0.3)),
                          const Gap(5),
                          TextSemiBold(
                            "Proceed Securely",
                            color: AppColors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                  // const Gap(20),

                  // /// Social
                  // Center(
                  //     child: TextSemiBold(
                  //   "Or",
                  //   textAlign: TextAlign.center,
                  // )),
                  // const Gap(20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     SvgPicture.asset(AppAsset.facebook, width: 50),
                  //     const Gap(10),
                  //     Image.asset(AppAsset.google, width: 50),
                  //   ],
                  // ),
                  const Gap(100),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Helper method to build password requirement item
  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.cancel,
          color: isMet ? Colors.green : AppColors.primaryGrey2,
          size: 16,
        ),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : AppColors.primaryGrey2,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ],
    );
  }

  /// Helper method to get color based on password strength
  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow[700]!;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.red;
    }
  }
}
