import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/core/services/connectivity_service.dart';

/// global connectivity banner — wraps every screen via MaterialApp.builder
/// offline: persistent red banner at top
/// back online: green banner auto-dismisses after 3 seconds
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _wasOffline = false;
  bool _showBackOnline = false;
  Timer? _backOnlineTimer;

  @override
  void dispose() {
    _backOnlineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = Get.find<ConnectivityService>();
      final isOffline = !service.isConnected.value;

      // track back-online transition
      if (_wasOffline && !isOffline) {
        _showBackOnline = true;
        _backOnlineTimer?.cancel();
        _backOnlineTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showBackOnline = false);
        });
      }
      _wasOffline = isOffline;

      return Column(
        children: [
          // offline banner
          if (isOffline)
            _OfflineBanner(onRetry: service.retryConnection),

          // back online banner
          if (!isOffline && _showBackOnline)
            _BackOnlineBanner(),

          // actual page content
          Expanded(child: widget.child),
        ],
      );
    });
  }
}

class _OfflineBanner extends StatelessWidget {
  final Future<bool> Function() onRetry;
  const _OfflineBanner({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade600,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'No internet connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackOnlineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green.shade600,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Back online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
