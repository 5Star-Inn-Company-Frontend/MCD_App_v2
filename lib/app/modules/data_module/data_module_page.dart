import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/data_module/network_provider.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/utils/amount_formatter.dart';

import './data_module_controller.dart';

class DataModulePage extends GetView<DataModuleController> {
  const DataModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaylonyAppBarTwo(
        title: controller.isForeign ? "Foreign Data Bundle" : "Data Bundle",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => Get.toNamed(Routes.HISTORY_SCREEN),
              child: TextSemiBold("History",
                  fontWeight: FontWeight.w700, fontSize: 16),
            ),
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight - kToolbarHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNetworkSelector(),
                  const Gap(30),
                  // _buildBonusSection(),
                  // const Gap(20),
                  _buildPlanContent(context),
                  // const Spacer(),
                  const Gap(16),
                  Obx(() => BusyButton(
                        title: "Buy Plan",
                        isLoading: controller.isPaying.value,
                        onTap: controller.pay,
                      )),
                  const Gap(25),
                  // SizedBox(width: double.infinity, child: Image.asset(AppAsset.banner)),
                  // const Gap(20)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNetworkSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.primaryGrey)),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Obx(() => DropdownButtonHideUnderline(
                  child: DropdownButton2<NetworkProvider>(
                    isExpanded: true,
                    iconStyleData: const IconStyleData(
                        icon:
                            Icon(Icons.keyboard_arrow_down_rounded, size: 30)),
                    items: controller.networkProviders
                        .map((provider) => DropdownMenuItem<NetworkProvider>(
                              value: provider,
                              child:
                                  Image.asset(provider.imageAsset, width: 50),
                            ))
                        .toList(),
                    value: controller.selectedNetworkProvider.value,
                    onChanged: (value) => controller.onNetworkSelected(value),
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      height: 40,
                      width: 140,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 70,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      elevation: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                    ),
                  ),
                )),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 3,
            height: 30,
            decoration: const BoxDecoration(color: AppColors.primaryGrey),
          ),
          Flexible(
            flex: 3,
            child: TextFormField(
                readOnly: true,
                controller: controller.phoneController,
                style: TextStyle(
                  fontFamily: AppFonts.manRope,
                ),
                decoration: textInputDecoration.copyWith(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Image.asset('assets/icons/contact-person-icon.png',
                          width: 24, height: 24),
                      onPressed: controller.pickContact,
                    ))),
          ),
        ],
      ),
    );
  }

  // Widget _buildBonusSection() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //     decoration: BoxDecoration(
  //       color: const Color(0xffF3FFF7),
  //       border: Border.all(color: AppColors.primaryColor),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         const Text("Bonus ₦10", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
  //         Container(
  //           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
  //           decoration: BoxDecoration(
  //               color: AppColors.primaryColor,
  //               borderRadius: BorderRadius.circular(5)),
  //           child: TextSemiBold("Claim", color: AppColors.white),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPlanContent(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ));
      }
      if (controller.errorMessage.value != null) {
        return Center(
            child: Text(controller.errorMessage.value!,
                style: TextStyle(
                  fontFamily: AppFonts.manRope,
                )));
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCategoryTabs(),
          const Gap(20),
          _buildAmountFilters(),
          const Gap(20),
          Flexible(
            child: SizedBox(
                height: screenHeight(context) * 0.450, child: _buildPlanGrid()),
          ),
        ],
      );
    });
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryGrey.withOpacity(0.4)),
        ),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: controller.tabBarItems.map((item) {
                bool isSelected = item == controller.selectedTab.value;
                return TouchableOpacity(
                  onTap: () => controller.onTabSelected(item),
                  child: Container(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        right: item == controller.tabBarItems.last
                            ? BorderSide.none
                            : const BorderSide(color: AppColors.primaryGrey),
                      ),
                    ),
                    child: TextSemiBold(
                      item,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.textPrimaryColor,
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildAmountFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryGrey.withOpacity(0.4)),
        ),
        child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: controller.amountFilters.map((filter) {
                bool isSelected = filter == controller.selectedAmountFilter.value;
                return TouchableOpacity(
                  onTap: () => controller.onAmountFilterSelected(filter),
                  child: Container(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        right: filter == controller.amountFilters.last
                            ? BorderSide.none
                            : const BorderSide(color: AppColors.primaryGrey),
                      ),
                    ),
                    child: TextSemiBold(
                      filter,
                      color: isSelected
                          ? AppColors.primaryColor
                          : AppColors.textPrimaryColor,
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildPlanGrid() {
    return Obx(() {
      if (controller.filteredDataPlans.isEmpty) {
        return Center(
            child: TextSemiBold("No plans available for this category."));
      }
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 2.3,
        ),
        itemCount: controller.filteredDataPlans.length,
        itemBuilder: (context, index) {
          final plan = controller.filteredDataPlans[index];
          return Obx(() {
            final isSelected = controller.selectedPlan.value == plan;
            return TouchableOpacity(
              onTap: () => controller.onPlanSelected(plan),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryColor
                        : AppColors.primaryGrey.withOpacity(0.4),
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: TextSemiBold(plan.name, fontSize: 14, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '₦${AmountUtil.formatFigure(double.tryParse(plan.price.toString()) ?? 0)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                        )),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }
}
