import 'package:mcd/core/import/imports.dart';
import 'banner_list_module_controller.dart';

class BannerListModulePage extends GetView<BannerListModuleController> {
  const BannerListModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: 'Banner Ads',
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Gap(10),
            // Header Filter Chips
            _buildFilterHeader(context),
            const Gap(10),
            // Controls section (High / Low count adjustments)
            _buildControlsSection(context),
            const Gap(10),
            // Banner List View
            Expanded(
              child: Obx(() {
                final items = controller.bannerItems;
                if (items.isEmpty) {
                  return Center(
                    child: TextBody(
                      'No banners selected',
                      color: AppColors.primaryGrey,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Gap(16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildBannerCard(context, item);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    return Obx(() {
      final currentFilter = controller.selectedFilter.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'All Banners',
              isSelected: currentFilter == BannerFilterType.all,
              onTap: () => controller.setFilter(BannerFilterType.all),
            ),
            const Gap(8),
            _buildFilterChip(
              label: 'High Banners Only',
              isSelected: currentFilter == BannerFilterType.high,
              onTap: () => controller.setFilter(BannerFilterType.high),
            ),
            const Gap(8),
            _buildFilterChip(
              label: 'Low Banners Only',
              isSelected: currentFilter == BannerFilterType.low,
              onTap: () => controller.setFilter(BannerFilterType.low),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.primaryColor.withOpacity(0.2),
          ),
        ),
        child: TextSemiBold(
          label,
          color: isSelected ? AppColors.white : AppColors.primaryColor,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildControlsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // High Banners Counter
              Obx(() => _buildCounterRow(
                    label: 'High ',
                    count: controller.highBannerCount.value,
                    onDecrement: controller.decrementHighBanners,
                    onIncrement: controller.incrementHighBanners,
                    badgeColor: Colors.purple,
                  )),
              const SizedBox(height: 24, child: VerticalDivider()),
              // Low Banners Counter
              Obx(() => _buildCounterRow(
                    label: 'Low ',
                    count: controller.lowBannerCount.value,
                    onDecrement: controller.decrementLowBanners,
                    onIncrement: controller.incrementLowBanners,
                    badgeColor: Colors.orange,
                  )),
            ],
          ),
          const Gap(8),
          const Divider(height: 1),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => TextBody(
                    'Total Shown: ${controller.bannerItems.length}',
                    color: AppColors.primaryGrey2,
                    fontSize: 12,
                  )),
              InkWell(
                onTap: controller.refreshBanners,
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                    const Gap(4),
                    TextSemiBold(
                      'Reload Ads',
                      color: AppColors.primaryColor,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required Color badgeColor,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(6),
        TextBody(
          label,
          fontSize: 12,
        ),
        const Gap(8),
        InkWell(
          onTap: onDecrement,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.remove, size: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextBold(
            '$count',
            fontSize: 13,
          ),
        ),
        InkWell(
          onTap: onIncrement,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.add, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, BannerItemModel item) {
    final isHigh = item.type == BannerFilterType.high;
    final badgeColor = isHigh ? Colors.purple : Colors.orange;
    final badgeText = isHigh ? 'HIGH BANNER' : 'LOW BANNER';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Item Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSemiBold(
                  item.title,
                  fontSize: 12,
                  color: Colors.black,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextBold(
                    badgeText,
                    fontSize: 9,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Banner Ad Container
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              final key = ValueKey('${item.id}_${controller.refreshKey.value}');
              return KeyedSubtree(
                key: key,
                child: isHigh
                    ? controller.adsService.showHighBannerAdWidget()
                    : controller.adsService.showLowBannerAdWidget(),
              );
            }),
          ),
        ],
      ),
    );
  }
}
