import 'package:flutter/material.dart';
import 'package:mcd/app/styles/app_colors.dart';

class AbstractBottomSheetContent extends StatelessWidget {
  final Widget child;
  const AbstractBottomSheetContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: 60,
            bottom: -50,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.05),
                      AppColors.primaryColor.withOpacity(0.01)
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: 120,
            bottom: -50,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 35,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryColor.withOpacity(0.05),
                      AppColors.primaryColor.withOpacity(0.01)
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
