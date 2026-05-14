import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mcd/app/routes/app_pages.dart';

import '../../core/constants/app_asset.dart';
import '../../core/constants/fonts.dart';
import '../../core/utils/ui_helpers.dart';
import '../styles/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  const BottomNavigation({super.key, required this.selectedIndex});

  void onItemTapped(int index) {
    if (selectedIndex == index) return;

    switch (index) {
      case 0:
        Get.offNamed(Routes.HOME_SCREEN);
        break;
      case 1:
        Get.offNamed(Routes.HISTORY_SCREEN);
        break;
      // case 2:
      //   Get.offNamed(Routes.SHOP_SCREEN);
      //   break;
      case 2:
        Get.offNamed(Routes.ASSISTANT_SCREEN);
        break;
      case 3:
        Get.offNamed(Routes.MORE_MODULE);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    /// To switch to the modern design:
    /// 1. Uncomment the [Container] block below.
    /// 2. Comment out the [SizedBox] block further down.
    /*
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, 'Home', AppAsset.systemIcon,
              AppAsset.systemActiveIcon),
          _buildNavItem(context, 1, 'History', AppAsset.historyIcon,
              AppAsset.historyActiveIcon),
          _buildNavItem(context, 2, 'Assistant', AppAsset.assistantIcon,
              AppAsset.assistantActiveIcon),
          _buildNavItem(context, 3, 'More', AppAsset.moreIcon,
              AppAsset.moreActiveIcon),
        ],
      ),
    );
    */

    // Old Bottom Navigation Bar
    return SizedBox(
        child: BottomNavigationBar(
      iconSize: 60,
      type: BottomNavigationBarType.fixed,
      elevation: 30,
      selectedItemColor: AppColors.primaryColor,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      currentIndex: selectedIndex,
      enableFeedback: true,
      selectedLabelStyle: const TextStyle(
          color: AppColors.primaryColor,
          fontSize: 12,
          fontFamily: AppFonts.manRope,
          fontWeight: FontWeight.w500),
      unselectedLabelStyle: const TextStyle(
          color: AppColors.textPrimaryColor2,
          fontSize: 12,
          fontFamily: AppFonts.manRope,
          fontWeight: FontWeight.w500),
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppAsset.systemIcon,
            width: screenWidth(context) * 0.06,
          ),
          activeIcon: SvgPicture.asset(
            AppAsset.systemActiveIcon,
            width: screenWidth(context) * 0.06,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppAsset.historyIcon,
            width: screenWidth(context) * 0.06,
          ),
          activeIcon: SvgPicture.asset(
            AppAsset.historyActiveIcon,
            width: screenWidth(context) * 0.06,
          ),
          label: 'History',
        ),
        // BottomNavigationBarItem(
        //   icon: SvgPicture.asset(
        //     'assets/icons/shop-inactive.svg',
        //     width: screenWidth(context) * 0.06,
        //   ),
        //   activeIcon: SvgPicture.asset(
        //     'assets/icons/shop-active.svg',
        //     width: screenWidth(context) * 0.06,
        //   ),
        //   label: 'Shop',
        // ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppAsset.assistantIcon,
            width: screenWidth(context) * 0.06,
          ),
          activeIcon: SvgPicture.asset(AppAsset.assistantActiveIcon),
          label: 'Assistant',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppAsset.moreIcon,
            width: screenWidth(context) * 0.06,
          ),
          activeIcon: SvgPicture.asset(
            AppAsset.moreActiveIcon,
            width: screenWidth(context) * 0.06,
          ),
          label: 'More',
        ),
      ],
    ));
  }

  Widget _buildNavItem(BuildContext context, int index, String label,
      String icon, String activeIcon) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? activeIcon : icon,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected ? Colors.white : Colors.grey.shade600,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: AppFonts.manRope,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
