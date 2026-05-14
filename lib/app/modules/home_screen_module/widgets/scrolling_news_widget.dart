import 'dart:async';
import 'package:flutter/material.dart';

class ScrollingNewsWidget extends StatefulWidget {
  final InlineSpan content;
  const ScrollingNewsWidget({super.key, required this.content});

  @override
  State<ScrollingNewsWidget> createState() => _ScrollingNewsWidgetState();
}

class _ScrollingNewsWidgetState extends State<ScrollingNewsWidget> {
  late ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (_scrollController.hasClients) {
        if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            _scrollController.offset + 1,
            duration: const Duration(milliseconds: 45),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Text.rich(widget.content),
        );
      },
    );
  }
}
