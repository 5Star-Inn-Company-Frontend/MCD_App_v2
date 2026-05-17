import 'package:flutter/material.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/constants/constants.dart';

class PrimaryAppButton extends StatefulWidget {
  const PrimaryAppButton({
    required this.title,
    required this.onTap,
    this.disabled = false,
    this.color = AppColors.primaryColor,
    this.textColor = AppColors.white,
    this.width,
    this.height,
    this.borderRadius,
    super.key,
  });

  final String title;
  final Future<void> Function()? onTap;
  final bool disabled;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<PrimaryAppButton> createState() => _PrimaryAppButtonState();
}

class _PrimaryAppButtonState extends State<PrimaryAppButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.disabled || _isLoading || widget.onTap == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.onTap!();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEffectivelyDisabled =
        widget.disabled || _isLoading || widget.onTap == null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (!isEffectivelyDisabled) {
          _animationController.forward();
        }
      },
      onTapUp: (_) {
        if (!isEffectivelyDisabled) {
          _animationController.reverse();
        }
      },
      onTapCancel: () {
        if (!isEffectivelyDisabled) {
          _animationController.reverse();
        }
      },
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: isEffectivelyDisabled && !widget.disabled ? 0.7 : 1.0,
            child: Container(
              height: widget.height ?? 48,
              width: widget.width ?? double.infinity,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(5),
                color: widget.disabled ? Colors.grey.shade400 : widget.color,
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.textColor,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFonts.manRope,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
