import 'package:flutter/material.dart';

class PulsingShimmerCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color shimmerColor;
  final BorderRadius? borderRadius;

  const PulsingShimmerCard({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2400),
    this.shimmerColor = const Color(0x66FFFFFF),
    this.borderRadius,
  });

  @override
  State<PulsingShimmerCard> createState() => _PulsingShimmerCardState();
}

class _PulsingShimmerCardState extends State<PulsingShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double val = _animation.value;
            return LinearGradient(
              begin: Alignment(val - 1.0, -0.3),
              end: Alignment(val, 0.3),
              colors: [
                Colors.transparent,
                widget.shimmerColor,
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );

    if (widget.borderRadius != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return content;
  }
}
