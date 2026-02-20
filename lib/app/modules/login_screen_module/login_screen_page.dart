import 'package:mcd/core/import/imports.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:developer' as dev;

/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class LoginScreenPage extends GetView<LoginScreenController> {
  const LoginScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        leading: BackButton(
          color: AppColors.primaryColor,
          onPressed: () {
            Get.offNamed(Routes.CREATEACCOUNT);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextSemiBold("Login",
                            fontSize: 20, fontWeight: FontWeight.w500),
                        const Gap(15),

                        // Animated toggle between Email and Phone
                        Obx(() => Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGrey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    left: controller.isEmail
                                        ? 0
                                        : MediaQuery.of(context).size.width *
                                                0.5 -
                                            20,
                                    right: controller.isEmail
                                        ? MediaQuery.of(context).size.width *
                                                0.5 -
                                            20
                                        : 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.isEmail = true;
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontFamily: AppFonts.manRope,
                                                  fontSize: 14,
                                                  fontWeight: controller.isEmail
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: controller.isEmail
                                                      ? AppColors.white
                                                      : AppColors.primaryGrey2,
                                                ),
                                                child: const Text(
                                                    'Email/Username'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.isEmail = false;
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontFamily: AppFonts.manRope,
                                                  fontSize: 14,
                                                  fontWeight:
                                                      !controller.isEmail
                                                          ? FontWeight.w600
                                                          : FontWeight.w500,
                                                  color: !controller.isEmail
                                                      ? AppColors.white
                                                      : AppColors.primaryGrey2,
                                                ),
                                                child: const Text('Phone'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                        const Gap(25),

                        // Animated field switcher
                        Obx(() => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.1),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: controller.isEmail
                                  ? TextFormField(
                                      key: const ValueKey('email'),
                                      controller: controller.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter your email";
                                        }
                                        return null;
                                      },
                                      onChanged: (_) =>
                                          controller.setFormValidState(),
                                      style: TextStyle(
                                          fontFamily: AppFonts.manRope),
                                      decoration: textInputDecoration.copyWith(
                                        filled: false,
                                        hintText: "name@mail.com or username",
                                        prefixIcon: const Icon(
                                            Icons.email_outlined,
                                            color: AppColors.primaryGrey2),
                                        hintStyle: const TextStyle(
                                            color: AppColors.primaryGrey2,
                                            fontFamily: AppFonts.manRope),
                                      ),
                                    )
                                  : TextFormField(
                                      key: const ValueKey('phone'),
                                      controller:
                                          controller.phoneNumberController,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter your phone number";
                                        }
                                        if (value.length < 10) {
                                          return "Invalid phone number";
                                        }
                                        return null;
                                      },
                                      onChanged: (_) =>
                                          controller.setFormValidState(),
                                      style: TextStyle(
                                          fontFamily: AppFonts.manRope),
                                      decoration: textInputDecoration.copyWith(
                                        filled: false,
                                        hintText: "08012345678",
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
                                          child: Text(
                                            "+234",
                                            style: TextStyle(
                                              fontFamily: AppFonts.manRope,
                                              fontSize: 16,
                                              color: AppColors.textPrimaryColor,
                                            ),
                                          ),
                                        ),
                                        hintStyle: const TextStyle(
                                            color: AppColors.primaryGrey2,
                                            fontFamily: AppFonts.manRope),
                                      ),
                                    ),
                            )),
                        const Gap(25),

                        // Password field
                        Obx(() => TextFormField(
                              controller: controller.passwordController,
                              obscureText: controller.isPasswordVisible.value,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Input password";
                                }
                                if (value.length < 6) {
                                  return "Password must contain 6 characters";
                                }
                                return null;
                              },
                              onChanged: (_) => controller.setFormValidState(),
                              obscuringCharacter: '•',
                              style: TextStyle(fontFamily: AppFonts.manRope),
                              decoration: textInputDecoration.copyWith(
                                hintText: "•••••••••",
                                hintStyle: const TextStyle(
                                    color: AppColors.primaryGrey2,
                                    fontSize: 20,
                                    letterSpacing: 3,
                                    fontFamily: AppFonts.manRope),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.isPasswordVisible.value =
                                        !controller.isPasswordVisible.value;
                                  },
                                  icon: controller.isPasswordVisible.value
                                      ? const Icon(
                                          Icons.visibility_off_outlined,
                                          color: AppColors.background)
                                      : SvgPicture.asset(
                                          "assets/images/preview-close.svg"),
                                ),
                              ),
                            )),
                        const Gap(8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.RESET_PASSWORD);
                                },
                                child: TextSemiBold("Forgot Password?")),
                          ],
                        ),
                        const Gap(40),

                        // Login button
                        Obx(() => TouchableOpacity(
                              disabled: !controller.isFormValid,
                              onTap: () {
                                if (!controller.formKey.currentState!
                                    .validate()) {
                                  return;
                                }

                                final username = controller.isEmail
                                    ? controller.emailController.text.trim()
                                    : controller.phoneNumberController.text
                                        .trim();

                                controller.login(
                                  context,
                                  username,
                                  controller.passwordController.text.trim(),
                                );
                              },
                              child: Container(
                                height: 55,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                                        color:
                                            AppColors.white.withOpacity(0.3)),
                                    const Gap(5),
                                    TextSemiBold("Proceed Securely",
                                        color: AppColors.white),
                                  ],
                                ),
                              ),
                            )),
                        const Gap(20),

                        Center(child: TextSemiBold("Or")),
                        const Gap(20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Facebook login
                            // InkWell(
                            //   onTap: () async {
                            //     try {
                            //       final LoginResult fbResult = await FacebookAuth.instance.login(
                            //         permissions: ['email', 'public_profile'],
                            //       );

                            //       if (fbResult.status == LoginStatus.success) {
                            //         final userData = await FacebookAuth.instance.getUserData();

                            //         final email = userData['email'] ?? '';
                            //         final name = userData['name'] ?? '';
                            //         final avatar = userData['picture']?['data']?['url'] ?? '';
                            //         final accessToken = fbResult.accessToken!.tokenString;
                            //         // Sign in to Firebase with the Facebook credential to keep auth in sync
                            //         final credential = FacebookAuthProvider.credential(accessToken);
                            //         final firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
                            //         final firebaseIdToken = await firebaseUser.user?.getIdToken();
                            //         const source = 'facebook';

                            //         await controller.socialLogin(
                            //           context,
                            //           email,
                            //           name,
                            //           avatar,
                            //           accessToken,
                            //           source,
                            //           firebaseIdToken: firebaseIdToken,
                            //         );
                            //         dev.log('Facebook login successful');
                            //       } else if (fbResult.status == LoginStatus.cancelled) {
                            //         Get.snackbar(
                            //           "Login Cancelled",
                            //           "Facebook login was cancelled",
                            //           backgroundColor: AppColors.errorBgColor,
                            //           colorText: AppColors.textSnackbarColor,
                            //         );
                            //       } else {
                            //         Get.snackbar(
                            //           "Error",
                            //           "Facebook login failed: ${fbResult.message}",
                            //           backgroundColor: AppColors.errorBgColor,
                            //           colorText: AppColors.textSnackbarColor,
                            //         );
                            //       }
                            //     } catch (e) {
                            //       dev.log("Facebook login error: $e");
                            //       Get.snackbar(
                            //         "Error",
                            //         "Facebook login error: $e",
                            //         backgroundColor: AppColors.errorBgColor,
                            //         colorText: AppColors.textSnackbarColor,
                            //       );
                            //     }
                            //   },
                            //   child: SvgPicture.asset(AppAsset.facebook, width: 50),
                            // ),
                            const Gap(10),
                            // Google login
                            // InkWell(
                            //   onTap: () async {
                            //     controller.handleSignIn(context);
                            //     // Get.snackbar(
                            //     //   "Coming Soon",
                            //     //   "Google Sign-In will be available soon",
                            //     //   backgroundColor: AppColors.errorBgColor,
                            //     //   colorText: AppColors.textSnackbarColor,
                            //     // );
                            //   },
                            //   child: Image.asset(AppAsset.google, width: 50),
                            // ),
                          ],
                        ),
                        // const Expanded(child: SetFingerPrint()),

                        const Gap(30),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextSemiBold("Don't have an account? "),
                              GestureDetector(
                                onTap: () {
                                  Get.offNamed(Routes.CREATEACCOUNT);
                                },
                                child: TextSemiBold(
                                  "Sign up now",
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Gap(30),

                        // only show biometric button if it's fully setup (enabled + credentials saved)
                        Obx(() => controller.isBiometricSetup
                            ? Center(
                                child: Container(
                                    margin: const EdgeInsets.only(bottom: 60),
                                    child: InkWell(
                                        onTap: () async {
                                          await controller
                                              .biometricLogin(context);
                                        },
                                        child: Image.asset(
                                          AppAsset.faceId,
                                          width: 50,
                                        ))),
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
