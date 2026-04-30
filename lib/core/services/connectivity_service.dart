import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _retryTimer;

  final isConnected = true.obs;
  final connectionType = ConnectivityResult.none.obs;
  final showBanner = false.obs;

  static ConnectivityService get to => Get.find<ConnectivityService>();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);
    } catch (e) {
      dev.log('Failed to get connectivity.',
          name: 'ConnectivityService', error: e);
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    connectionType.value = result;

    if (result == ConnectivityResult.none) {
      _setDisconnected();
      return;
    }

    // verify actual internet access
    final hasInternet = await _checkInternet();
    if (hasInternet) {
      _setConnected();
    } else {
      _setDisconnected();
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _setConnected() {
    final wasDisconnected = !isConnected.value;
    isConnected.value = true;
    showBanner.value = false;
    _retryTimer?.cancel();

    if (wasDisconnected) {
      dev.log('Internet connection restored', name: 'ConnectivityService');
    }
  }

  void _setDisconnected() {
    isConnected.value = false;
    showBanner.value = true;
    dev.log('No internet connection', name: 'ConnectivityService');

    // auto retry every 10 seconds
    _retryTimer?.cancel();
    _retryTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => retryConnection());
  }

  Future<bool> retryConnection() async {
    dev.log('Retrying connection...', name: 'ConnectivityService');

    final results = await _connectivity.checkConnectivity();
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;

    if (result == ConnectivityResult.none) {
      return false;
    }

    final hasInternet = await _checkInternet();
    if (hasInternet) {
      _setConnected();
      return true;
    }
    return false;
  }

  String getConnectionTypeString() {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
      }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _retryTimer?.cancel();
    super.onClose();
  }
}
