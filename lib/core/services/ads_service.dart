import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:advert/advert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'connectivity_service.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  final _advertPlugin = Advert();
  bool _isInitialized = false;
  bool _isSequenceActive = false;
  Timer? _sequenceTimer;

  // test-only: bypass real plugin calls entirely
  @visibleForTesting
  bool testMode = false;

  @visibleForTesting
  bool testIsShowingAds = false;

  @visibleForTesting
  void setInitializedForTesting(bool value) => _isInitialized = value;

  @visibleForTesting
  void resetForTesting() {
    _isInitialized = false;
    _isSequenceActive = false;
    _sequenceTimer?.cancel();
    _sequenceTimer = null;
    testMode = false;
    testIsShowingAds = false;
  }

  static final String bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/3287545689'
      : 'ca-app-pub-6117361441866120/1488443500';

  static final String rewardVideoUnitId = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/4412338366'
      : 'ca-app-pub-6117361441866120/2609953488';

  static String interstitialUnitId = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/8563923098'
      : 'ca-app-pub-6117361441866120/8759030065';

  static String nativeAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/7557970286'
      : 'ca-app-pub-6117361441866120/5123378631';

  static String rewardInterstitialUnitId = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/4577116553'
      : 'ca-app-pub-6117361441866120/6040874481';

  // spin and win uses interstitial ad unit
  static String spinandwinUnitId = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/8563923098'
      : 'ca-app-pub-6117361441866120/8759030065';

  // free money uses the reward ad unit (previously misassigned to spin and win)
  static String freeMoneyUnitId = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/5165063317'
      : 'ca-app-pub-6117361441866120/9202838992';

  final gameid = Platform.isAndroid ? "3717787" : '3717786';
  final bannerAdPlacementId =
      Platform.isAndroid ? ['newandroidbanner'] : ['iOS_Banner'];
  final interstitialVideoAdPlacementId =
      Platform.isAndroid ? ['video'] : ['iOS_Interstitial'];
  final rewardedVideoAdPlacementId = Platform.isAndroid
      ? ['Android_Rewarded', "rewardedVideo"]
      : ['iOS_Rewarded'];

  Future<void> initialize({bool testMode = false}) async {
    if (_isInitialized) {
      dev.log('Ads already initialized');
      return;
    }
    Googlemodel googlemodel = Googlemodel()
      ..bannerAdUnitId = [bannerAdUnitId]
      // ..nativeadUnitId = _nativeadUnitId
      ..rewardedInterstitialAdUnitId = [rewardInterstitialUnitId]
      ..rewardedAdUnitId = [rewardVideoUnitId]
      ..spinAndWin = [freeMoneyUnitId]
      ..freemoney = [freeMoneyUnitId]
      ..interstitialAdUnitId = [interstitialUnitId];
    Unitymodel unitymodel = Unitymodel()
      ..gameId = gameid
      ..interstitialVideoAdPlacementId = interstitialVideoAdPlacementId
      ..rewardedVideoAdPlacementId = rewardedVideoAdPlacementId
      ..bannerAdPlacementId = bannerAdPlacementId;
    try {
      await _advertPlugin.initialize(
        testmode: testMode,
        adsmodel: Adsmodel(googlemodel: googlemodel, unitymodel: unitymodel),
      );
      _isInitialized = true;
      dev.log('Ads initialized successfully');
    } catch (e) {
      dev.log('Error initializing ads: $e');
    }
  }

  void showBannerAd() {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return;
    }

    try {
      _advertPlugin.adsProv.showBannerAd();
      dev.log('Banner ad shown');
    } catch (e) {
      dev.log('Error showing banner ad: $e');
    }
  }

  Widget showBannerAdWidget() {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return const SizedBox.shrink();
    }

    try {
      dev.log('Banner ad shown');
      return _advertPlugin.adsProv.showBannerAd();
    } catch (e) {
      dev.log('Error showing banner ad: $e');
    }

    return const SizedBox.shrink();
  }

  void showInterstitialAd() {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return;
    }

    try {
      _advertPlugin.adsProv.showInterstitialAd();
      dev.log('Interstitial ad shown');
    } catch (e) {
      dev.log('Error showing interstitial ad: $e');
    }
  }

  Future<bool> showRewardedAd({
    VoidCallback? onRewarded,
    Map<String, String>? customData,
    Function? onAdClicked,
    Function? onAdImpression,
  }) async {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return false;
    }

    try {
      final completer = Completer<void>();
      final defaultCustomData =
          customData ?? {"username": "", "platform": "", "type": ""};

      final response = await _advertPlugin.adsProv.showRewardedAd(
        onRewarded: () {
          if (!completer.isCompleted) {
            completer.complete();
            onRewarded?.call();
          }
        },
        customData: defaultCustomData,
        onAdClicked: onAdClicked,
        onAdImpression: onAdImpression,
      );

      if (response.status) {
        await completer.future;
        dev.log('Rewarded ad completed successfully');
        return true;
      } else {
        dev.log('Error: Rewarded ad failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing rewarded ad: $e');
      return false;
    }
  }

  void showspinAndWinAd(
    BuildContext context, {
    VoidCallback? onRewarded,
    Map<String, String>? customData,
    Function? onAdClicked,
    Function? onAdImpression,
    required int total,
  }) async {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return;
    }
    final defaultCustomData =
        customData ?? {"username": "", "platform": "", "type": ""};

    _advertPlugin.adsProv.startAdSequence(
      context,
      total: total,
      adType: 'spinAndWin',
      reason: "Spin and Win",
      customData: defaultCustomData,
      onComplete: onRewarded ?? () {},
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
    );
  }

  Future<bool> showfreemoney({
    VoidCallback? onRewarded,
    Map<String, String>? customData,
    Function? onAdClicked,
    Function? onAdImpression,
  }) async {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return false;
    }

    try {
      final completer = Completer<void>();
      final defaultCustomData =
          customData ?? {"username": "", "platform": "", "type": ""};

      final response = await _advertPlugin.adsProv.showfreemoney(
        onRewarded: () {
          if (!completer.isCompleted) {
            completer.complete();
            onRewarded?.call();
          }
        },
        customData: defaultCustomData,
        onAdClicked: onAdClicked,
        onAdImpression: onAdImpression,
      );

      if (response.status) {
        await completer.future;
        dev.log('Freemoney ad completed successfully');
        return true;
      } else {
        dev.log('Error: Freemoney ad failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing freemoney ad: $e');
      return false;
    }
  }

  void showMultipleRewardedAds(
    BuildContext context, {
    required int maxAds,
    Map<String, String>? customData,
    VoidCallback? onAdCompleted,
    Function(String)? onAdFailed,
    required String reason,
    Function? onAdClicked,
    Function? onAdImpression,
  }) async {
    if (_isSequenceActive) {
      dev.log('Ad sequence is already active. Ignoring duplicate request.');
      return;
    }

    if (!ConnectivityService.to.isConnected.value) {
      dev.log('Ad sequence failed: No internet connection.');
      if (onAdFailed != null) {
        onAdFailed(
            'No internet connection. Please check your network and try again.');
      }
      return;
    }

    if (!_isInitialized) {
      dev.log('Ads not initialized yet, initializing now...');
      await initialize(testMode: false);

      if (!_isInitialized) {
        dev.log('Error: Failed to initialize ads');
        if (onAdFailed != null) {
          onAdFailed('Unable to load ads. Please try again later.');
        }
        return;
      }
    }

    try {
      _isSequenceActive = true;
      final defaultCustomData =
          customData ?? {"username": "", "platform": "", "type": ""};

      bool sequenceCompleted = false;
      bool wasShowing = false;

      if (!context.mounted) {
        _isSequenceActive = false;
        return;
      }

      if (!testMode) {
        // reset plugin counters before starting new sequence
        _advertPlugin.adsProv.adsWatched = 0;

        _advertPlugin.adsProv.startAdSequence(
          context,
          total: maxAds,
          adType: 'mergeRewarded',
          reason: reason,
          customData: defaultCustomData,
          onComplete: () {
            sequenceCompleted = true;
            _isSequenceActive = false;
            _sequenceTimer?.cancel();
            if (onAdCompleted != null) onAdCompleted();
          },
          onAdClicked: onAdClicked,
          onAdImpression: onAdImpression,
        );
      }

      // watchdog: detect stalls, network drops, and stuck native activities
      int noAdShowingTicks = 0;
      int totalTicks = 0;
      // absolute max timeout (60 ticks * 500ms = 30 seconds)
      const int absoluteMaxTicks = 60;

      _sequenceTimer =
          Timer.periodic(const Duration(milliseconds: 500), (timer) {
        if (sequenceCompleted) {
          timer.cancel();
          return;
        }

        totalTicks++;
        bool isShowing =
            testMode ? testIsShowingAds : _advertPlugin.adsProv.isShowingAds.value;

        // absolute timeout - prevent infinite stuck states
        if (totalTicks >= absoluteMaxTicks) {
          dev.log(
              'Ad sequence failed: Absolute timeout reached (${totalTicks * 500}ms).');
          _cleanupSequenceState();
          timer.cancel();
          if (onAdFailed != null) {
            onAdFailed('Ad session timed out. Please try again.');
          }
          return;
        }

        // abort if network drops while no ad is actively on screen
        if (!isShowing && !ConnectivityService.to.isConnected.value) {
          dev.log('Ad sequence failed: Network lost while waiting for ad.');
          _cleanupSequenceState();
          timer.cancel();
          if (onAdFailed != null) {
            onAdFailed(
                'Network connection lost. Please check your internet and try again.');
          }
          return;
        }

        if (!isShowing) {
          noAdShowingTicks++;

          if (wasShowing) {
            // ad was showing before but stopped; grace period for next ad
            if (noAdShowingTicks > 6) {
              dev.log(
                  'Ad sequence failed: Sequence aborted by user or failed to load next ad.');
              _cleanupSequenceState();
              timer.cancel();
              if (onAdFailed != null) {
                onAdFailed(
                    'Ad sequence was interrupted or you closed the ad early. You must watch the full ad to proceed.');
              }
              return;
            }
          } else {
            // waiting for first ad to appear
            if (noAdShowingTicks > 10) {
              dev.log('Ad sequence failed: Timeout waiting for ad to load.');
              _cleanupSequenceState();
              timer.cancel();
              if (onAdFailed != null) {
                onAdFailed(
                    'Ads are temporarily unavailable. Please try again or choose another payment method.');
              }
              return;
            }
          }
        } else {
          noAdShowingTicks = 0;
          if (!wasShowing) {
            wasShowing = true;
          }
        }
      });
    } catch (e) {
      dev.log('Error showing multiple rewarded ads: $e');
      _isSequenceActive = false;
      if (onAdFailed != null) {
        onAdFailed(
            'An error occurred while loading ads. Please check your network and try again.');
      }
      return;
    }
  }

  bool get isInitialized => _isInitialized;
  bool get isSequenceActive => _isSequenceActive;

  // cleanup shared by watchdog abort and manual cancellation
  void _cleanupSequenceState() {
    _isSequenceActive = false;
    if (!testMode) {
      _advertPlugin.adsProv.isShowingAds.value = false;
      _advertPlugin.adsProv.adsWatched = 0;
    }
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void cancelSequence() {
    _isSequenceActive = false;
    _sequenceTimer?.cancel();
    _sequenceTimer = null;
    if (!testMode) {
      _advertPlugin.adsProv.isShowingAds.value = false;
      _advertPlugin.adsProv.adsWatched = 0;
    }
  }

  bool isCurrentlyShowingAds() {
    return testMode ? testIsShowingAds : _advertPlugin.adsProv.isShowingAds.value;
  }

  void forceResetAdState() {
    dev.log('Force resetting ad state and cancelling sequence.');
    cancelSequence();
  }
}
