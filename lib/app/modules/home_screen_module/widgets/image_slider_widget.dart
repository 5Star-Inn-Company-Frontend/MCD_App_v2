import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/core/constants/fonts.dart';

class ImageSliderWidget extends StatefulWidget {
  final List<String> images;

  const ImageSliderWidget({super.key, required this.images});

  @override
  State<ImageSliderWidget> createState() => _ImageSliderWidgetState();
}

class _ImageSliderWidgetState extends State<ImageSliderWidget> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  static const _kStartPage = 1000;

  @override
  void initState() {
    super.initState();
    _currentPage = _kStartPage;
    _pageController = PageController(initialPage: _currentPage);
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(ImageSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != oldWidget.images) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (widget.images.isEmpty || !mounted) return;

      _currentPage++;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GestureDetector(
            onPanDown: (_) => _stopAutoSlide(),
            onPanCancel: () => _startAutoSlide(),
            onPanEnd: (_) => _startAutoSlide(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final actualIndex = index % widget.images.length;
                return ImageItem(url: widget.images[actualIndex]);
              },
            ),
          ),
        ),
        const Gap(10),
        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (index) {
              final isActive = (_currentPage % widget.images.length) == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? AppColors.primaryColor : Colors.grey[300],
                ),
              );
            },
          ),
        ),
        const Gap(15),
      ],
    );
  }
}

class ImageItem extends StatefulWidget {
  final String url;
  const ImageItem({super.key, required this.url});

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 160,
          placeholder: (context, url) => Container(
            color: Colors.grey[100],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 30,
                      color: Colors.grey[400],
                    ),
                    const Gap(4),
                    Text(
                      "Image Failed",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontFamily: AppFonts.manRope),
                    )
                  ],
                ),
              ),
            );
          },
          imageBuilder: (context, imageProvider) {
            return LoggedImage(imageProvider: imageProvider, url: widget.url);
          },
        ),
      ),
    );
  }
}

class LoggedImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final String url;
  const LoggedImage(
      {super.key, required this.imageProvider, required this.url});

  @override
  State<LoggedImage> createState() => _LoggedImageState();
}

class _LoggedImageState extends State<LoggedImage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(
          image: widget.imageProvider,
          fit: BoxFit.cover,
        ),
        // primary color overlay
        Container(
          color: Colors.green.withOpacity(0.35),
        ),
      ],
    );
  }
}
