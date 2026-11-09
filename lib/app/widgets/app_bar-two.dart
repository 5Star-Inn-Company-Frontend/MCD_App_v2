import 'package:flutter/material.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';
import 'package:mcd/app/widgets/app_back_button.dart';
import 'package:mcd/app/widgets/touchableOpacity.dart';

import 'package:get/get.dart';

class PaylonyAppBarTwo extends StatelessWidget implements PreferredSizeWidget {
  const PaylonyAppBarTwo({
    super.key,
    required this.title,
    this.actions = const [],
    this.centerTitle = true,
    this.elevation,
  });

  final String title;
  final List<Widget> actions;
  final bool centerTitle;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      // backgroundColor: Color(0xffFBFBFB),
      // systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: AppColors.white, statusBarIconBrightness: Brightness.dark),
      leading: TouchableOpacity(
        onTap: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Get.back();
          }
        },
        child: const AppBackButton(),
      ),
      title: TextBold(
        title,
        fontSize: 18,
      ),
      actions: actions,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}