import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';

Future<void> showLoadingDialog({String? lottie, BuildContext? context}) async {
  Get.dialog(
    WillPopScope(
      onWillPop: willpop,
      child: Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: LottieBuilder.asset(
            lottie ?? 'assets/images/loadingcubes.json',
            height: 120,
            width: 120,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

Future<bool> willpop() async {
  return false;
}