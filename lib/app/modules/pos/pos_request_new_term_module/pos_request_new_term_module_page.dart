import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import './pos_request_new_term_module_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PosRequestNewTermModulePage extends GetView<PosRequestNewTermModuleController> {
  const PosRequestNewTermModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "Select Terminal Type",
        elevation: 0,
        centerTitle: false,
        actions: [],
      ),
      backgroundColor: const Color.fromRGBO(251, 251, 251, 1),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color.fromRGBO(90, 187, 123, 1),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.terminals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                Gap(16.h),
                Text(
                  controller.errorMessage.value,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: const Color.fromRGBO(112, 112, 112, 1),
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(16.h),
                ElevatedButton(
                  onPressed: controller.fetchAvailableTerminals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(90, 187, 123, 1),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.terminals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Color.fromRGBO(112, 112, 112, 1),
                ),
                Gap(16.h),
                Text(
                  'No terminals available',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: const Color.fromRGBO(112, 112, 112, 1),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          child: Column(
            children: controller.terminals.map((terminal) {
              return InkWell(
                onTap: () => controller.selectTerminal(terminal),
                child: _terminalTypeContainer(terminal),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  Widget _terminalTypeContainer(dynamic terminal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Network image with loading and error states
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(246, 244, 255, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: terminal.image,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      strokeWidth: 2,
                      color: const Color.fromRGBO(90, 187, 123, 1),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Color.fromRGBO(112, 112, 112, 1),
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  terminal.name,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromRGBO(51, 51, 51, 1),
                  ),
                ),
                Gap(7.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Outright Purchase',
                            style: GoogleFonts.manrope(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                          Text(
                            'N${terminal.formattedOutright}',
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lease',
                            style: GoogleFonts.manrope(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                          Text(
                            'N${terminal.formattedLease}',
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Installment',
                            style: GoogleFonts.manrope(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                          Text(
                            'N${terminal.formattedInstallment}',
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Initial Amount',
                            style: GoogleFonts.manrope(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                          Text(
                            'N${terminal.formattedInstallmentInitial}',
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap(5.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Repayment',
                            style: GoogleFonts.manrope(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                          Text(
                            'N${terminal.formattedRepayment}',
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Frequency',
                            style: GoogleFonts.manrope(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                          Text(
                            terminal.frequencyText,
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromRGBO(112, 112, 112, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
