import 'package:mcd/core/import/imports.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import './all_service_module_controller.dart';

class AllServiceModulePage extends GetView<AllServiceModuleController> {
  const AllServiceModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
                      onPressed: () {
                        if (controller.isSearchVisible.value) {
                          controller.searchQuery.value = '';
                          controller.toggleSearch();
                        } else {
                          Get.back();
                        }
                      },
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Obx(() => Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  AnimatedOpacity(
                                    opacity: controller.isSearchVisible.value ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextBold(
                                        'All Service',
                                        fontSize: 22,
                                        color: AppColors.textPrimaryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: controller.isSearchVisible.value ? constraints.maxWidth : 0,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: controller.isSearchVisible.value ? AppColors.boxColor : Colors.transparent),
                                    ),
                                    child: ClipRect(
                                      child: controller.isSearchVisible.value 
                                          ? TextField(
                                              autofocus: true,
                                              onChanged: (val) => controller.searchQuery.value = val,
                                              style: TextStyle(fontSize: 16, color: AppColors.textPrimaryColor),
                                              decoration: InputDecoration(
                                                hintText: 'Search...',
                                                hintStyle: TextStyle(color: AppColors.primaryGrey2, fontSize: 16),
                                                border: InputBorder.none,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                ],
                              ));
                        },
                      ),
                    ),
                    Obx(() => IconButton(
                          icon: Icon(
                            controller.isSearchVisible.value ? Icons.close : Icons.search,
                            color: AppColors.primaryGrey2,
                            size: 26,
                          ),
                          onPressed: () {
                            if (controller.isSearchVisible.value) {
                              controller.searchQuery.value = '';
                            }
                            controller.toggleSearch();
                          },
                        )),
                  ],
                ),
                const Gap(20),
                Obx(() {
                final filtered = controller.filteredServices;
                
                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Center(
                      child: Text(
                        "No services found.",
                        style: TextStyle(color: AppColors.primaryGrey2, fontSize: 14),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: filtered.entries.map((entry) {
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              button.icon.endsWith('.png')
                                  ? Image.asset(
                                      button.icon,
                                      width: 24,
                                      height: 24,
                                      color: AppColors.primaryColor,
                                    )
                                  : SvgPicture.asset(
                                      button.icon,
                                      width: 24,
                                      height: 24,
                                      colorFilter: const ColorFilter.mode(
                                          AppColors.primaryColor, BlendMode.srcIn),
                                    ),
                              const Gap(8),
                              Text(
                                button.text,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.background,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.manRope,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate(delay: (index * 50).ms).scale(curve: Curves.easeOutQuad, duration: 400.ms).fadeIn(duration: 400.ms);
                    },
                  ),
                  const Gap(20),
                ],
              );
            }).toList(),
            );
            }),
          ],
        ),
      ),
    )));
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
