import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:mcd/app/modules/foreign_airtime_module/country_selection_controller.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_bar-two.dart';
import 'package:mcd/app/widgets/busy_button.dart';
import 'package:mcd/core/constants/fonts.dart';

class CountrySelectionPage extends GetView<CountrySelectionController> {
  const CountrySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PaylonyAppBarTwo(
        title: "Select Country",
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search country...',
                hintStyle: TextStyle(
                  color: AppColors.primaryGrey2,
                  fontFamily: AppFonts.manRope,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primaryGrey2,
                ),
                filled: true,
                fillColor: AppColors.primaryGrey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Countries list
          Expanded(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              // Error state
              if (controller.errorMessage.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.primaryGrey2,
                        ),
                        const Gap(16),
                        TextSemiBold(
                          controller.errorMessage.value!,
                          fontSize: 16,
                          color: AppColors.primaryGrey,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),
                        BusyButton(
                          title: 'Retry',
                          onTap: controller.fetchCountries,
                          width: 120,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Empty state
              if (controller.countries.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.public_off,
                          size: 64,
                          color: AppColors.primaryGrey2,
                        ),
                        const Gap(16),
                        TextSemiBold(
                          'No countries available',
                          fontSize: 16,
                          color: AppColors.primaryGrey,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final filteredCountries = controller.filteredCountries;

              // Empty search results
              if (filteredCountries.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.primaryGrey2,
                        ),
                        const Gap(16),
                        TextSemiBold(
                          'No countries found',
                          fontSize: 16,
                          color: AppColors.primaryGrey,
                        ),
                        const Gap(8),
                        Text(
                          'Try a different search term',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryGrey2,
                            fontFamily: AppFonts.manRope,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Countries list
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: filteredCountries.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: AppColors.primaryGrey.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final country = filteredCountries[index];
                  return InkWell(
                    onTap: () => controller.selectCountry(country),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          // Country flag
                          _buildCountryFlag(country.flag),
                          const Gap(16),

                          // Country details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  country.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFonts.manRope,
                                    color: AppColors.background,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  '${country.code} • ${country.currency}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryGrey2,
                                    fontFamily: AppFonts.manRope,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Arrow icon
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primaryGrey2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(String flagUrl) {
    if (flagUrl.isEmpty) {
      return Container(
        width: 70,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryGrey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.flag,
          size: 24,
          color: AppColors.primaryGrey,
        ),
      );
    }

    // Check if the URL is an SVG file
    final isSvg = flagUrl.toLowerCase().endsWith('.svg');

    return Container(
      width: 70,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primaryGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isSvg
            ? SvgPicture.network(
                flagUrl,
                width: 70,
                height: 50,
                fit: BoxFit.cover,
                placeholderBuilder: (context) => Container(
                  width: 70,
                  height: 50,
                  color: AppColors.primaryGrey.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: flagUrl,
                width: 70,
                height: 50,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 50,
                  color: AppColors.primaryGrey.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flag,
                    size: 24,
                    color: AppColors.primaryGrey,
                  ),
                ),
              ),
      ),
    );
  }
}
