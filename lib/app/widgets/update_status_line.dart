import 'package:flutter/material.dart';
import 'package:mcd/core/services/app_updates.dart';

/// A status line displaying over-the-air (OTA) update status.
class UpdateStatusLine extends StatelessWidget {
  const UpdateStatusLine({super.key});

  static const double height = 28;

  @override
  Widget build(BuildContext context) {
    final updates = AppUpdates();

    return ListenableBuilder(
      listenable: updates,
      builder: (context, _) {
        final Widget? line = switch (updates.state) {
          UpdateState.checking => _line(
            context,
            const _Spinner(),
            'Checking for updates…',
          ),
          UpdateState.downloading => _line(
            context,
            const _Spinner(),
            'Downloading an update…',
          ),
          UpdateState.ready => _line(
            context,
            const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF00BFA5)),
            'Update ready! Close and reopen app to apply.',
          ),
          _ => null,
        };

        return SizedBox(
          height: height,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: line ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _line(BuildContext context, Widget lead, String text) {
    return Padding(
      key: ValueKey<String>(text),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          lead,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 12,
    child: CircularProgressIndicator(
      strokeWidth: 1.8,
      color: Colors.grey.shade600,
    ),
  );
}
