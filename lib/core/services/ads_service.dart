import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:advert/advert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  final _advertPlugin = Advert();
  bool _isInitialized = false;

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
    }

    try {
      dev.log('Banner ad shown');
      return _advertPlugin.adsProv.showBannerAd();
    } catch (e) {
      dev.log('Error showing banner ad: $e');
    }

    return Container();
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
          onRewarded:() {
        if (!completer.isCompleted) {
          completer.complete();
          onRewarded?.call();
        }
      }, customData: defaultCustomData,
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


  void showspinAndWinAd(BuildContext context,{
    VoidCallback? onRewarded,
    Map<String, String>? customData,
    Function? onAdClicked,
    Function? onAdImpression,
    required int total,
  }) async {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return ;
    }
    final defaultCustomData =
        customData ?? {"username": "", "platform": "", "type": ""};

    _advertPlugin.adsProv.startAdSequence(
      context,
      total: total,
      adType: 'spinAndWin',
      reason: "Spin and Win",
      customData: defaultCustomData,
      onComplete: onRewarded ?? (){},
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
        onRewarded:() {
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
    if (!_isInitialized) {
      dev.log('Ads not initialized yet, initializing now...');
      await initialize(testMode: false);

      if (!_isInitialized) {
        dev.log('Error: Failed to initialize ads');
        return;
      }
    }

    try {
      final defaultCustomData =
          customData ?? {"username": "", "platform": "", "type": ""};

      bool sequenceCompleted = false;
      bool wasShowing = false; // track ad activation

      if (!context.mounted) return;
      _advertPlugin.adsProv.startAdSequence(
        context,
        total: maxAds,
        adType: 'mergeRewarded',
        reason: reason,
        customData: defaultCustomData,
        onComplete: () {
          sequenceCompleted = true;
          if (onAdCompleted != null) onAdCompleted();
        },
        onAdClicked: onAdClicked,
        onAdImpression: onAdImpression,
      );

      // watch for premature abort
      Worker? watcher;
      watcher = ever(_advertPlugin.adsProv.isShowingAds, (bool isShowing) {
        if (isShowing) {
          wasShowing = true;
        } else {
          // delay check to allow next ad to load
          Future.delayed(const Duration(seconds: 2), () {
            if (!sequenceCompleted && !_advertPlugin.adsProv.isShowingAds.value) {
              dev.log('Ad sequence failed or was aborted prematurely.');
              if (onAdFailed != null) {
                if (wasShowing) {
                  onAdFailed(
                      'Ad sequence closed early. You must watch the advertisements completely to pay with General Market.');
                } else {
                  onAdFailed(
                      'Ads are temporarily unavailable. Please try again in a few minutes or choose another payment method.');
                }
              }
              watcher?.dispose();
            }
          });
        }
      });
    } catch (e) {
      dev.log('Error showing multiple rewarded ads: $e');
      if (onAdFailed != null) {
        onAdFailed(
            'An error occurred while loading ads. Please check your network and try again.');
      }
      return ;
    }
  }

  bool get isInitialized => _isInitialized;

  bool isCurrentlyShowingAds() {
    return _advertPlugin.adsProv.isShowingAds.value;
  }

  void forceResetAdState() {
    _advertPlugin.adsProv.isShowingAds.value = false;
  }
}
