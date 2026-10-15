import 'package:flutter/material.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/styles/fonts.dart';

class PaylonyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PaylonyAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.elevation,
    this.actions = const [],
    this.centerTitle = false,
    this.toolbarHeight,
    this.backgroundColor = Colors.white,
    this.preferredHeight,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final double? elevation;
  final bool centerTitle;
  final double? toolbarHeight;
  final Color backgroundColor;
  final double? preferredHeight;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      title: titleWidget ??
          TextBold(
            title ?? '',
            fontSize: 20,
            color: AppColors.textPrimaryColor,
            fontWeight: FontWeight.w700,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      actions: actions,
      elevation: elevation ?? 0.0,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(preferredHeight ?? (toolbarHeight ?? 30));
}