import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Where an over-the-air update stands on this phone.
enum UpdateState {
  none,
  checking,
  downloading,
  ready,
  upToDate,
  unavailable,
  failed,
}

/// Over-the-air updates management service using standard Flutter ChangeNotifier.
class AppUpdates extends ChangeNotifier {
  static final AppUpdates _instance = AppUpdates._internal();
  factory AppUpdates() => _instance;
  AppUpdates._internal();

  final ShorebirdUpdater _updater = ShorebirdUpdater();

  UpdateState _state = UpdateState.none;
  int? _currentPatch;
  int? _downloadedPatch;

  UpdateState get state => _state;
  int? get currentPatch => _currentPatch;
  int? get downloadedPatch => _downloadedPatch;

  static const Duration downloadWait = Duration(minutes: 2);
  static const Duration _poll = Duration(seconds: 3);

  bool get isAvailable => _updater.isAvailable;

  /// Asks for a newer patch, and downloads it if there is one.
  Future<void> check() async {
    if (_state == UpdateState.checking || _state == UpdateState.downloading) {
      return;
    }
    if (!_updater.isAvailable) {
      _state = UpdateState.unavailable;
      notifyListeners();
      return;
    }
    _state = UpdateState.checking;
    notifyListeners();

    _currentPatch = await _patch(next: false);

    final UpdateStatus status;
    try {
      status = await _updater.checkForUpdate();
    } catch (error) {
      debugPrint('update check failed: $error');
      _state = UpdateState.failed;
      notifyListeners();
      return;
    }

    switch (status) {
      case UpdateStatus.restartRequired:
        await _ready();
      case UpdateStatus.outdated:
        await _download();
      case UpdateStatus.upToDate:
        _state = UpdateState.upToDate;
        notifyListeners();
      case UpdateStatus.unavailable:
        _state = UpdateState.unavailable;
        notifyListeners();
    }
  }

  Future<void> _download() async {
    _state = UpdateState.downloading;
    notifyListeners();

    debugPrint('update found, downloading');
    try {
      await _updater.update();
      await _ready();
    } catch (error) {
      if (await _downloadedMeanwhile()) {
        await _ready();
        return;
      }
      debugPrint('update download failed: $error');
      _state = UpdateState.failed;
      notifyListeners();
    }
  }

  Future<bool> _downloadedMeanwhile() async {
    final int polls = downloadWait.inMilliseconds ~/ _poll.inMilliseconds;
    for (int i = 0; i <= polls; i++) {
      final int? next = await _patch(next: true);
      if (next != null && next != _currentPatch) return true;
      if (i < polls) await Future<void>.delayed(_poll);
    }
    return false;
  }

  Future<void> _ready() async {
    _downloadedPatch = await _patch(next: true);
    _state = UpdateState.ready;
    notifyListeners();
    debugPrint(
      'update ${_downloadedPatch ?? ''} ready, applies on next start',
    );
  }

  Future<int?> _patch({required bool next}) async {
    try {
      final Patch? patch = next
          ? await _updater.readNextPatch()
          : await _updater.readCurrentPatch();
      return patch?.number;
    } catch (_) {
      return null;
    }
  }
}
