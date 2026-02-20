import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/constants/fonts.dart';
import './virtual_card_change_pin_controller.dart';

class VirtualCardChangePinPage extends GetView<VirtualCardChangePinController> {
  const VirtualCardChangePinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Change Pin",
        elevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                TextBold(
                  'Enter code',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
                const Gap(16),

                // Subtitle
                Obx(() => TextSemiBold(
                      controller.isOldPinStep.value
                          ? 'Enter your Old PIN'
                          : controller.isNewPinStep.value
                              ? 'Enter the New PIN'
                              : 'Confirm the New PIN',
                      fontSize: 16,
                      color: Colors.black87,
                    )),
                const Gap(40),

                // PIN Display
                Obx(() {
                  final pin = controller.isOldPinStep.value
                      ? controller.oldPin.value
                      : controller.isNewPinStep.value
                          ? controller.newPin.value
                          : controller.confirmPin.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: index < pin.length
                              ? Colors.grey.shade200
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: index < pin.length
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),

          // Numeric Keypad
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 100 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const Gap(12),
                  _buildKeypadRow(['4', '5', '6']),
                  const Gap(12),
                  _buildKeypadRow(['7', '8', '9']),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80, height: 80), // Empty space
                      _buildKeypadButton('0'),
                      _buildBackspaceButton(),
                    ],
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) => _buildKeypadButton(number)).toList(),
    );
  }

  Widget _buildKeypadButton(String number) {
    return InkWell(
      onTap: () => controller.addDigit(number),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.manRope,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: () => controller.removeDigit(),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 28,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
