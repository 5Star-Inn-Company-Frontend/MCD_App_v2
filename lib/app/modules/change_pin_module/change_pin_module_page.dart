import 'package:mcd/core/import/imports.dart';
import './change_pin_module_controller.dart';

class ChangePinModulePage extends GetView<ChangePinModuleController> {
    
    const ChangePinModulePage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                leading: BackButton(
                    color: AppColors.primaryColor,
                ),
                title: TextSemiBold(
                    'Change pin',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                ),
                centerTitle: false,
            ),
            body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Form(
                        key: controller.formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                const Gap(20),
                                
                                // Old PIN
                                TextSemiBold('Old pin'),
                                const Gap(8),
                                TextFormField(
                                    controller: controller.oldPinController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please enter old pin";
                                        }
                                        if (value.length != 6) {
                                            return "PIN must be 6 digits";
                                        }
                                        return null;
                                    },
                                    decoration: textInputDecoration.copyWith(
                                        hintText: 'Enter old pin (Default is 123456)',
                                        hintStyle: TextStyle(
                                            color: AppColors.primaryGrey,
                                            fontSize: 14, fontFamily: AppFonts.manRope,
                                        ),
                                        counterText: '',
                                        filled: true,
                                        fillColor: AppColors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: AppColors.primaryGrey.withOpacity(0.3),
                                            ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: AppColors.primaryColor,
                                            ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                                color: Colors.red,
                                            ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                                color: Colors.red,
                                            ),
                                        ),
                                    ),
                                ),
                                const Gap(25),
                                
                                // New PIN
                                TextSemiBold('New pin'),
                                const Gap(8),
                                TextFormField(
                                    controller: controller.newPinController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please enter new pin";
                                        }
                                        if (value.length != 6) {
                                            return "PIN must be 4 digits";
                                        }
                                        return null;
                                    },
                                    decoration: textInputDecoration.copyWith(
                                        hintText: 'Enter new pin',
                                        hintStyle: TextStyle(
                                            color: AppColors.primaryGrey,
                                            fontSize: 14,
                                        ),
                                        counterText: '',
                                        filled: true,
                                        fillColor: AppColors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: AppColors.primaryGrey.withOpacity(0.3),
                                            ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: AppColors.primaryColor,
                                            ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                                color: Colors.red,
                                            ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                                color: Colors.red,
                                            ),
                                        ),
                                    ),
                                ),
                                const Gap(25),
                                
                                // Confirm PIN
                                TextSemiBold('Confirm pin'),
                                const Gap(8),
                                TextFormField(
                                    controller: controller.confirmPinController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    validator: (value) {
                                        if (value == null || value.isEmpty) {
                                            return "Please confirm new pin";
                                        }
                                        if (value != controller.newPinController.text) {
                                            return "PINs do not match";
                                        }
                                        return null;
                                    },
                                    decoration: textInputDecoration.copyWith(
                                        hintText: 'Confirm new pin',
                                        hintStyle: TextStyle(
                                            color: AppColors.primaryGrey,
                                            fontSize: 14,
                                        ),
                                        counterText: '',
                                        filled: true,
                                        fillColor: AppColors.white,
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: AppColors.primaryGrey.withOpacity(0.3),
                                            ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(
                                                color: AppColors.primaryColor,
                                            ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                                color: Colors.red,
                                            ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                                color: Colors.red,
                                            ),
                                        ),
                                    ),
                                ),
                                const Gap(120),
                                
                                // Submit Button
                                Obx(() => GestureDetector(
                                    onTap: controller.isLoading.value
                                        ? null
                                        : () => controller.changePin(),
                                    child: Container(
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                            color: controller.isLoading.value
                                                ? AppColors.primaryColor.withOpacity(0.6)
                                                : AppColors.primaryColor,
                                            borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Center(
                                            child: controller.isLoading.value
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                )
                                                : TextSemiBold(
                                                    'Confirm',
                                                    fontSize: 16,
                                                    color: AppColors.white,
                                                    fontWeight: FontWeight.w600,
                                                ),
                                        ),
                                    ),
                                )),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}