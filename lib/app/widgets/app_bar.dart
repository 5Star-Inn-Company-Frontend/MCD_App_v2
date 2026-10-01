import 'package:flutter/material.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';

class PaylonyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PaylonyAppBar({
    super.key,
    required this.title,
    this.elevation,
    this.actions = const [],
    this.centerTitle = false,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final List<Widget> actions;
  final double? elevation;
  final bool centerTitle;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      title: TextBold(
        title,
        fontSize: 20,
        color: AppColors.textPrimaryColor,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: actions,
      elevation: elevation ?? 0.0,
      centerTitle: centerTitle,
      // foregroundColor: AppColors.white,
    )
    ;
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}