import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/app/widgets/abstract_bottom_sheet_content.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor = Colors.white,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
}) {
  BuildContext effectiveContext = context;
  if (!effectiveContext.mounted || Navigator.maybeOf(effectiveContext) == null) {
    if (Get.context != null && Get.context!.mounted) {
      effectiveContext = Get.context!;
    } else {
      return Future.value(null);
    }
  }

  return showModalBottomSheet<T>(
    context: effectiveContext,
    builder: (context) {
      return AbstractBottomSheetContent(
        child: builder(context),
      );
    },
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
  );
}
