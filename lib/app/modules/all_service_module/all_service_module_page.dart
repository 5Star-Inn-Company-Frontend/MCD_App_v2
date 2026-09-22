import 'package:mcd/core/import/imports.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import './all_service_module_controller.dart';

class AllServiceModulePage extends GetView<AllServiceModuleController> {
  const AllServiceModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
          onPressed: () => Get.back(),
        ),
        title: TextBold(
          'All Service',
          fontSize: 20,
          color: AppColors.textPrimaryColor,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0.0,
        centerTitle: false,
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.categorizedServices.entries.map((entry) {
              final categoryName = entry.key;
              final buttons = entry.value;
              if (buttons.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(10),
                  TextSemiBold(
                    categoryName,
                    fontSize: 14,
                    color: AppColors.primaryGrey2,
                  ),
                  const Gap(15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: buttons.length,
                    itemBuilder: (ctx, index) {
                      final button = buttons[index];
                      return TouchableOpacity(
                        onTap: () async {
                          final hc = Get.find<HomeScreenController>();
                          final isAvailable = await hc.handleServiceNavigation(button);
                          if (!isAvailable) return;
                          
                          // track usage
                          controller.handleServiceTap(button);
                          
                          // check if context is still valid after async operation
                          if (!context.mounted) return;
                          
                          // navigate or show bottom sheets
                          if (button.link == Routes.RESULT_CHECKER_MODULE) {
                            _showResultCheckerOptions(context, hc);
                          } else if (button.link == "epin") {
                            _showEpinOptionsBottomSheet(context, hc);
                          } else if (button.link == Routes.AIRTIME_MODULE) {
                            _showAirtimeSelectionBottomSheet(context, hc);
                          } else if (button.link == Routes.DATA_MODULE) {
                            _showDataSelectionBottomSheet(context, hc);
                          } else if (button.link.isNotEmpty) {
                            Get.toNamed(button.link);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xffF3FFF7),
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                button.icon,
                                colorFilter: const ColorFilter.mode(
                                    AppColors.primaryColor2, BlendMode.srcIn),
                              ),
                              const Gap(5),
                              TextSemiBold(
                                button.text,
                                textAlign: TextAlign.center,
                                color: AppColors.primaryColor2,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Gap(20),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showResultCheckerOptions(BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('WAEC'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.RESULT_CHECKER_MODULE, arguments: {'type': 'WAEC'});
                },
              ),
              ListTile(
                title: const Text('NECO'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.RESULT_CHECKER_MODULE, arguments: {'type': 'NECO'});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEpinOptionsBottomSheet(BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('WAEC E-PIN'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.EPIN_MODULE, arguments: {'type': 'WAEC'});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAirtimeSelectionBottomSheet(BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nigeria'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.NUMBER_VERIFICATION_MODULE, arguments: {'redirectTo': Routes.AIRTIME_MODULE});
                },
              ),
              ListTile(
                title: const Text('Other Countries'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.COUNTRY_SELECTION, arguments: {'redirectTo': Routes.AIRTIME_MODULE});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDataSelectionBottomSheet(BuildContext context, HomeScreenController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nigeria'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.NUMBER_VERIFICATION_MODULE, arguments: {'redirectTo': Routes.DATA_MODULE});
                },
              ),
              ListTile(
                title: const Text('Other Countries'),
                onTap: () {
                  Navigator.pop(context);
                  Get.toNamed(Routes.COUNTRY_SELECTION, arguments: {'redirectTo': Routes.DATA_MODULE});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
