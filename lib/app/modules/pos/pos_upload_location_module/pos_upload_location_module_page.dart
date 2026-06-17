import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/core/utils/ui_helpers.dart';
import './pos_upload_location_module_controller.dart';

class PosUploadLocationModulePage extends GetView<PosUploadLocationModuleController> {
  const PosUploadLocationModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaylonyAppBarTwo(
        title: "",
        elevation: 0,
        centerTitle: false,
        actions: [],
      ),
      backgroundColor: const Color.fromRGBO(251, 251, 251, 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: screenHeight(context) * 0.8,
              child: Column(
                children: [
                  const Gap(20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Location',
                        style: GoogleFonts.manrope(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color.fromRGBO(51, 51, 51, 1)
                        ),
                      ),
                    ],
                  ),
                  
                  const Gap(30),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Take a picture of your Business Location',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromRGBO(51, 51, 51, 1)
                        ),
                      ),
                      const Gap(10),
                      Text(
                        '2. Upload image',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromRGBO(51, 51, 51, 1)
                        ),
                      ),
                      const Gap(10),
                      Text(
                        '3. Submit image',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromRGBO(51, 51, 51, 1)
                        ),
                      ),
                    ],
                  ),
                  
                  const Gap(30),
                  
                  _fileUploadContainer(context),
                ],
              ),
            ),

            Obx(() => InkWell(
              onTap: () {
                if (controller.fileUploaded.value) {
                  Get.toNamed(Routes.POS_TERM_AGREEMENT);
                } else {
                  _selectFile();
                }
              },
              child: Container(
                height: screenHeight(context) * 0.065,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(51, 160, 88, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    controller.fileUploaded.value ? 'Proceed' : 'Upload Image',
                    style: GoogleFonts.manrope(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _fileUploadContainer(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: _selectFile,
      child: Container(
        height: screenHeight(context) * 0.25,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage('assets/images/${controller.fileUploaded.value
                ? "greenborder" : "greyborder"}.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/image.svg',
              height: screenHeight(context) * 0.08,
            ),
            const Gap(20),
            Text(
              controller.fileUploaded.value
                  ? controller.selectedFileName.value
                  : 'Click to upload image',
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color.fromRGBO(112, 112, 112, 1)
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      controller.selectFile(result.files.single.name);
    }
  }
}
