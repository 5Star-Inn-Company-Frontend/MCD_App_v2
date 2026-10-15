import 'package:google_fonts/google_fonts.dart';
import 'package:mcd/app/modules/data_module/model/data_plan_model.dart';
import 'package:mcd/app/modules/data_module/network_provider.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/utils/amount_formatter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mcd/app/widgets/pulsing_shimmer_card.dart';
import 'package:mcd/app/modules/more_module/more_module_page.dart';

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
      body: Form(
          key: controller.formKey,
          child: LayoutBuilder(builder: (context, constraints) {
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
                      const Gap(16),
                      _buildUpgradeInfoCard(),
                      const Gap(20),
                      _buildPlanContent(context),
                      const Gap(16),
                      Obx(() => BusyButton(
                            title: "Buy Plan",
                            isLoading: controller.isPaying.value,
                            onTap: controller.pay,
                          )),
                      const Gap(25),
                    ],
                  ),
                ),
              ),
            );
          })),
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
            child: Obx(() => Skeletonizer(
                  enabled: controller.isLoading.value &&
                      controller.networkProviders.isEmpty,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<NetworkProvider?>(
                      isExpanded: true,
                      iconStyleData: const IconStyleData(
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              size: 30)),
                      items: controller.networkProviders
                          .map((provider) => DropdownMenuItem<NetworkProvider?>(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return ("Please input phone number");
                  }
                  if (!controller.isForeign && value.length != 11) {
                    return ("Please Input valid 11-digit number");
                  }
                  return null;
                },
                readOnly: true,
                controller: controller.phoneController,
                style: const TextStyle(
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

  Widget _buildPlanContent(BuildContext context) {
    return Obx(() {
      return Skeletonizer(
        enabled: controller.isLoading.value,
        child: controller.errorMessage.value != null
            ? Center(
                child: Text(controller.errorMessage.value!,
                    style: const TextStyle(
                      fontFamily: AppFonts.manRope,
                    )))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCategoryTabs(),
                  const Gap(20),
                  _buildAmountFilters(),
                  const Gap(20),
                  Flexible(
                    child: SizedBox(
                        height: screenHeight(context) * 0.50,
                        child: _buildPlanGrid(context)),
                  ),
                ],
              ),
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
                bool isSelected =
                    filter == controller.selectedAmountFilter.value;
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

  Widget _buildPlanGrid(BuildContext context) {
    return Obx(() {
      if (controller.filteredDataPlans.isEmpty && !controller.isLoading.value) {
        return Center(
            child: TextSemiBold("No plans available for this category."));
      }
      final double textScaleFactor = MediaQuery.textScaleFactorOf(context);
      final double aspectRatio = 1.7 / textScaleFactor;

      final items =
          (controller.isLoading.value && controller.filteredDataPlans.isEmpty)
              ? List.generate(
                  6,
                  (index) => DataPlanModel(
                        name: "Loading Plan Name",
                        coded: "coded",
                        price: "0",
                        network: "network",
                        category: "category",
                        id: 0,
                      ))
              : controller.filteredDataPlans;

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: aspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final plan = items[index];
          return Obx(() {
            final isSelected = controller.selectedPlan.value == plan;
            return TouchableOpacity(
              onTap: () => controller.onPlanSelected(plan),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
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
                      child: TextSemiBold(
                        plan.name,
                        fontSize: 13,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${AmountUtil.formatFigure(double.tryParse(plan.price.toString()) ?? 0)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildUpgradeInfoCard() {
    return PulsingShimmerCard(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFCD34D)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: TextBold(
                    'LIGHTNING DELIVERY',
                    fontSize: 10,
                    color: AppColors.white,
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: TextBold(
                    'Priority Speed & Hot Deals',
                    fontSize: 13.5,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
            const Gap(10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
                const Gap(8),
                const Expanded(
                  child: Text(
                    'Upgrade to any paid plan for lightning speed delivery when there is congestion.\nHot Deals only available to paid users',
                    style: TextStyle(
                      fontFamily: AppFonts.manRope,
                      fontSize: 12.5,
                      color: Color(0xFF78350F),
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: MoreModulePage.navigateToSubscriptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flash_on_rounded,
                        color: AppColors.white, size: 18),
                    const Gap(6),
                    TextBold(
                      'Upgrade Plan',
                      fontSize: 13,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
