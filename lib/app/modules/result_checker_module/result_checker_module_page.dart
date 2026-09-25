import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/app/widgets/touchableOpacity.dart';
import 'package:mcd/core/constants/textField.dart';
import 'package:mcd/core/utils/ui_helpers.dart';
import './result_checker_module_controller.dart';
import 'package:mcd/app/widgets/custom_bottom_sheet.dart';

class ResultCheckerModulePage extends GetView<ResultCheckerModuleController> {
  const ResultCheckerModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => PaylonyAppBarTwo(
              title: controller.pageTitle.value,
              elevation: 0,
              centerTitle: false,
              actions: const [],
            )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.exams.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No exam options available'),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSemiBold(
                  "Fill out the form below and get your request in your mail inbox"),
              const Gap(40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextSemiBold("Select Exam"),
                  Obx(() => Text(
                        "Price: ₦${controller.examPrice}",
                        style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xffFF9F9F),
                            fontWeight: FontWeight.w500),
                      )),
                ],
              ),
              const Gap(8),
              TouchableOpacity(
                onTap: () => _showExamPicker(context),
                child: Obx(() => TextFormField(
                      enabled: false,
                      decoration: textInputDecoration.copyWith(
                        filled: true,
                        fillColor: const Color(0xffFFFFFF),
                        suffixIcon:
                            const Icon(Icons.arrow_forward_ios_outlined),
                        hintText: controller.examName.isNotEmpty
                            ? controller.examName
                            : "Select exam",
                        hintStyle: const TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    const Color(0xffD9D9D9).withOpacity(0.6))),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    const Color(0xffD9D9D9).withOpacity(0.6))),
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    const Color(0xffD9D9D9).withOpacity(0.6))),
                      ),
                    )),
              ),
              const Gap(30),
              TextSemiBold("Enter Quantity"),
              const Gap(8),
              TextFormField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                decoration: textInputDecoration.copyWith(
                  filled: true,
                  fillColor: const Color(0xffFFFFFF),
                  hintText: "1-10",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xffD9D9D9).withOpacity(0.6))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xffD9D9D9).withOpacity(0.6))),
                ),
              ),
              const Gap(70),
              Center(
                child: BusyButton(
                  width: screenWidth(context) * 0.6,
                  title: "Pay",
                  onTap: controller.handlePayment,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showExamPicker(BuildContext context) {
    showCustomBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Exam',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(16),
                ...controller.exams.map((exam) {
                  final isSelected =
                      controller.selectedExam.value?['code'] == exam['code'];
                  return TouchableOpacity(
                    onTap: () {
                      controller.selectExam(exam);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : const Color(0xffD9D9D9),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            exam['name'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.background,
                            ),
                          ),
                          Text(
                            '₦${exam['price'] ?? exam['amount'] ?? 0}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        });
  }
}
