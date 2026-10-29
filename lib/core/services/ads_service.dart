import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:advert/advert.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcd/core/services/remote_config_service.dart';
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

  // --- Ad Unit IDs ---

  // Banner Ads
  static final List<String> bannerHigh = Platform.isAndroid
      ? ['ca-app-pub-6117361441866120/2869480303','ca-app-pub-6117361441866120/1364826947']
      : ['ca-app-pub-6117361441866120/8620500430','ca-app-pub-6117361441866120/3444195379'];

  static final List<String> bannerLow = Platform.isAndroid
      ? ['ca-app-pub-6117361441866120/2869480303','ca-app-pub-6117361441866120/7738663604']
      : ['ca-app-pub-6117361441866120/1488443500','ca-app-pub-6117361441866120/7191868699'];

  // Interstitial Ads
  static String interstitialHigh = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/8563923098'
      : 'ca-app-pub-6117361441866120/8759030065';

  // Rewarded Ads
  static final String rewardedHigh = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/4412338366'
      : 'ca-app-pub-6117361441866120/2609953488';

  static String rewardedInterstitialHigh = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/4577116553'
      : 'ca-app-pub-6117361441866120/6040874481';

  // Free Money (Rewarded)
  static String freeMoneyHigh = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/7295608188'
      : 'ca-app-pub-6117361441866120/4202540985';

  static String freeMoneyLow = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/5165063317'
      : 'ca-app-pub-6117361441866120/9202838992';

  static String freeMoneyLow2 = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/4934435891'
      : 'ca-app-pub-6117361441866120/5585172589';

  static String freeMoneyInterstitial = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/2544949196'
      : 'ca-app-pub-6117361441866120/2980063466';

  // spin and win uses interstitial ad unit
  static String spinandwin = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/8563923098'
      : 'ca-app-pub-6117361441866120/8759030065';


  // Native Ads
  static String nativeHigh = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/7557970286'
      : 'ca-app-pub-6117361441866120/5123378631';

  // Appopen Ads
  static String appopenlow = Platform.isAndroid
      ? 'ca-app-pub-6117361441866120/5533379303'
      : 'ca-app-pub-6117361441866120/7894829083';

  // Unity Config
  final gameid = Platform.isAndroid ? "3717787" : '3717786';
  final apppid = Platform.isAndroid ? "6adde9e558e014823b7cf1c7" : '6addb9bbddd6285c51137bb1';
  final bannerAdPlacementId =
      Platform.isAndroid ? ['newandroidbanner'] : ['iOS_Banner'];
  final interstitialVideoAdPlacementId =
      Platform.isAndroid ? ['video'] : ['iOS_Interstitial'];
  final rewardedVideoAdPlacementId = Platform.isAndroid
      ? ['Android_Rewarded', "rewardedVideo", 'freemoney']
      : ['iOS_Rewarded', 'freemoney'];

  /// Gather GDPR / EEA / UK consent using Google User Messaging Platform (UMP)
  Future<void> gatherConsent() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadAndShowConsentForm(completer);
        } else {
          dev.log('Consent form is not available', name: 'AdsService');
          if (!completer.isCompleted) completer.complete();
        }
      },
      (FormError error) {
        dev.log('Consent info update error: ${error.message}', name: 'AdsService');
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  void _loadAndShowConsentForm(Completer<void> completer) {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        final status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? formError) {
            if (formError != null) {
              dev.log('Consent form error: ${formError.message}', name: 'AdsService');
            } else {
              dev.log('Consent form completed or not required', name: 'AdsService');
            }
            if (!completer.isCompleted) completer.complete();
          });
        } else {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (FormError formError) {
        dev.log('Consent form load error: ${formError.message}', name: 'AdsService');
        if (!completer.isCompleted) completer.complete();
      },
    );
  }

  Future<void> initialize({bool testMode = false}) async {
    if (_isInitialized) {
      dev.log('Ads already initialized');
      return;
    }

    try {
      await gatherConsent();
    } catch (e) {
      dev.log('Consent gathering error: $e', name: 'AdsService');
    }

    if (Get.isRegistered<RemoteConfigService>()) {
      final adsEnabled = RemoteConfigService.to.getBool('ads_enabled', defaultValue: true);
      if (!adsEnabled) {
        dev.log('Ads are disabled via Remote Config', name: 'AdsService');
        return;
      }
      testMode = testMode || RemoteConfigService.to.getBool('ads_test_mode', defaultValue: false);
    }

    Googlemodel googlemodel = Googlemodel();

    // 1. Configure Banner Waterfall

    googlemodel.addBannerPlacement('banner',
        high: bannerHigh, low: bannerLow);

    // 2. Configure Interstitial Waterfall
    googlemodel.addInterstitialPlacement('interstitial', high: [interstitialHigh]);

    // 3. Configure Standard Rewarded Waterfall
    googlemodel.addRewardedPlacement('rewarded', high: [rewardedHigh]);

    // 4. Configure Rewarded Interstitial
    googlemodel.addRewardedInterstitialPlacement('rewardedInterstitial',
        high: [rewardedInterstitialHigh]);

    // 5. Configure Free Money Placement (3-tier waterfall support in SDK)
    googlemodel.addRewardedPlacement('freemoney',
        high: [freeMoneyHigh], low: [freeMoneyLow, freeMoneyLow2]);

    googlemodel.addInterstitialPlacement('freemoneyInterstitial',
        high: [freeMoneyInterstitial]);

    // 6. Configure Spin and Win (uses Free Money units)
    googlemodel.addRewardedPlacement('spinAndWin',
        high: [spinandwin]);

    // 7. Configure Native Ads
    googlemodel.addNativePlacement('native', high: [nativeHigh]);

    // 8. Configure AppOpen Ads
    googlemodel.addAppOpenPlacement('appOpen', high: [appopenlow]);

    Unitymodel unitymodel = Unitymodel();
    unitymodel.gameId = gameid;
    unitymodel.interstitialVideoAdPlacementId = interstitialVideoAdPlacementId;
    unitymodel.rewardedVideoAdPlacementId = rewardedVideoAdPlacementId;
    unitymodel.addRewardedPlacement(
        'freemoney', rewardedVideoAdPlacementId,
      );
    unitymodel.bannerAdPlacementId = bannerAdPlacementId;

    List<String> vungleinterstatialplacement = Platform.isAndroid
    ? ["INTERSTITIAL-8403335"]
        :["DEFAULT-5743198"];
    List<String> vunglebannerplacement = Platform.isAndroid?["BANNER-0612661"]:["BANNER-3558091"];
    List<String> vunglerewardedplacement = Platform.isAndroid?["REWARDED-5418065"]:["REWARDED-7113759"];
    List<String> vungleappOpenplacement = Platform.isAndroid?["APPOPEN-0302146"] : ["APP_OPEN-7796821"];
    List<String> vungleNativeplacement = Platform.isAndroid?["NATIVE-0027388"] : ["NATIVE-3538573"];
    Vunglemodel vunglemodel = Vunglemodel();
    vunglemodel.appId = apppid;
    vunglemodel.interstitialVideoAdPlacementId = vungleinterstatialplacement;
    vunglemodel.rewardedVideoAdPlacementId = vunglerewardedplacement;
    vunglemodel.addRewardedPlacement(
        'freemoney', vunglerewardedplacement,
      );
    vunglemodel.addNativePlacement(
        'native', vungleNativeplacement,
      );
    vunglemodel.addAppOpenPlacement(
        'appOpen', vungleappOpenplacement,
      );
    vunglemodel.bannerAdPlacementId = vunglebannerplacement;

    final chartboostModel = Chartboostmodel()
      ..appId = Platform.isAndroid?"6ade5e5614f620e5b750ea1c":"6ade5cf477fbe7caa13effc7"
      ..appSignature = Platform.isAndroid?"4178d1f4d45bd45175335f101322db02bdae394a":"3e7b0d6e3e107e5e32d50d6546917b91d242f5aa"
      ..addRewardedPlacement('rewarded', ['rewarded'])
      ..addRewardedPlacement('freemoney', ['rewarded'])
      ..addInterstitialPlacement('interstitial', ['interstitial'])
      ..addBannerPlacement(['Banner']);

    final levelPlayModel = Levelplaymodel()
      ..appKey = Platform.isAndroid ? "YOUR_LEVELPLAY_APP_KEY" : "28fdfd45d"
      ..addRewardedPlacement('rewarded', [Platform.isAndroid ? 'e5jvy0s5s56wt7v8': '2x65seynidqxbkhm'])
      ..addRewardedPlacement('freemoney', [Platform.isAndroid ? 'e5jvy0s5s56wt7v8': '2x65seynidqxbkhm'])
      ..addInterstitialPlacement('interstitial', [Platform.isAndroid ? 'legd72y5b6hgf60z' : 'a2909t9gtzd1jv8h'])
      ..addBannerPlacement([Platform.isAndroid ? 'creg04p29452uars' : 'o0mavgqbnuc4hp6w']);


    try {
      await _advertPlugin.initialize(
        testmode: testMode,
        adsmodel: Adsmodel(
          unitymodel: unitymodel,
          googlemodel: googlemodel,
          vunglemodel: vunglemodel,
          chartboostmodel: chartboostModel,
          levelplaymodel: levelPlayModel,
        ),
      );
      _isInitialized = true;
      dev.log('Ads initialized successfully');

      // Dynamically apply provider enables/disables and waterfall priority from Remote Config
      applyRemoteConfigAdSettings();
    } catch (e) {
      dev.log('Error initializing ads: $e');
    }
  }

  /// Apply dynamic ad provider enables/disables and waterfall priority order from Remote Config
  void applyRemoteConfigAdSettings() {
    if (!Get.isRegistered<RemoteConfigService>()) return;

    try {
      final enabledMap = RemoteConfigService.to.getAdProviderEnabledMap();
      enabledMap.forEach((provider, isEnabled) {
        if (isEnabled) {
          _advertPlugin.adsProv.enableProvider(provider);
        } else {
          _advertPlugin.adsProv.disableProvider(provider);
        }
        dev.log('Ad provider ${provider.name} enabled: $isEnabled', name: 'AdsService');
      });

      final priorityOrder = RemoteConfigService.to.getAdProviderPriorityOrder();
      _advertPlugin.adsProv.setProviderPriorityOrder(priorityOrder);
      dev.log(
        'Ad waterfall priority order applied: ${priorityOrder.map((p) => p.name).join(', ')}',
        name: 'AdsService',
      );
    } catch (e) {
      dev.log('Error applying Remote Config ad settings: $e', name: 'AdsService');
    }
  }


  Widget showBannerAdWidget({String type = 'banner'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return const SizedBox.shrink();
    }

    try {
      dev.log('Requesting banner ad: $type');
      return _advertPlugin.adsProv.showBannerAd(type: type);
    } catch (e) {
      dev.log('Error showing banner ad: $e');
    }

    return const SizedBox.shrink();
  }
  Widget showLowBannerAdWidget({String type = 'banner'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return const SizedBox.shrink();
    }

    try {
      dev.log('Requesting banner ad: $type');
      return _advertPlugin.adsProv.showLowBannerAd(type: type);
    } catch (e) {
      dev.log('Error showing banner ad: $e');
    }

    return const SizedBox.shrink();
  }

  Widget showHighBannerAdWidget({String type = 'banner'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return const SizedBox.shrink();
    }

    try {
      dev.log('Requesting banner ad: $type');
      return _advertPlugin.adsProv.showHighBannerAd(type: type);
    } catch (e) {
      dev.log('Error showing banner ad: $e');
    }

    return const SizedBox.shrink();
  }

  Widget showNativeAdWidget(BuildContext context, {String type = 'native'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return const SizedBox.shrink();
    }

    try {
      dev.log('Requesting native ad: $type');
      return _advertPlugin.adsProv.showNativeAd(context, type: type);
    } catch (e) {
      dev.log('Error showing native ad: $e');
    }

    return const SizedBox.shrink();
  }

  Widget showHighNativeAd(BuildContext context, {String type = 'native'}) {
    // Note: The AdManager currently handles waterfall internally via showNativeAd.
    // This is provided for consistency with other ad types.
    return showNativeAdWidget(context, type: type);
  }

  Widget showLowNativeAd(BuildContext context, {String type = 'native'}) {
    return showNativeAdWidget(context, type: type);
  }

  Widget showHighBannerAd({String type = 'banner'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return const SizedBox.shrink();
    }

    try {
      dev.log('Requesting HIGH banner ad: $type');
      return _advertPlugin.adsProv.showHighBannerAd(type: type);
    } catch (e) {
      dev.log('Error showing high banner ad: $e');
    }

    return const SizedBox.shrink();
  }

  Widget showLowBannerAd({String type = 'banner'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return const SizedBox.shrink();
    }

    try {
      dev.log('Requesting LOW banner ad: $type');
      return _advertPlugin.adsProv.showLowBannerAd(type: type);
    } catch (e) {
      dev.log('Error showing low banner ad: $e');
    }

    return const SizedBox.shrink();
  }

  void showInterstitialAd({String type = 'interstitial'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return;
    }

    try {
      _advertPlugin.adsProv.showInterstitialAd(type: type);
      dev.log('Interstitial ad shown: $type');
    } catch (e) {
      dev.log('Error showing interstitial ad: $e');
    }
  }

  void showHighInterstitialAd({String type = 'interstitial'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return;
    }

    try {
      _advertPlugin.adsProv.showHighInterstitialAd(type: type);
      dev.log('Interstitial ad shown: $type');
    } catch (e) {
      dev.log('Error showing interstitial ad: $e');
    }
  }

  void showLowInterstitialAd({String type = 'interstitial'}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return;
    }

    try {
      _advertPlugin.adsProv.showLowInterstitialAd(type: type);
      dev.log('Interstitial ad shown: $type');
    } catch (e) {
      dev.log('Error showing interstitial ad: $e');
    }
  }

  Future<bool> showRewardedAd({
    String type = 'rewarded',
    Function? onRewarded,
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
          customData ?? {"username": "", "platform": "", "type": type};

      final response = await _advertPlugin.adsProv.showRewardedAd(
        type: type,
        onRewarded: (String? provider) {
          if (!completer.isCompleted) {
            completer.complete();
            if (onRewarded != null) {
              try {
                (onRewarded as dynamic)(provider);
              } catch (_) {
                try {
                  (onRewarded as dynamic)();
                } catch (e) {
                  dev.log('Error invoking onRewarded: $e');
                }
              }
            }
          }
        },
        customData: defaultCustomData,
        onAdClicked: onAdClicked,
        onAdImpression: onAdImpression,
      );

      if (response.status) {
        await completer.future;
        dev.log('Rewarded ad ($type) completed successfully');
        return true;
      } else {
        dev.log('Error: Rewarded ad ($type) failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing rewarded ad ($type): $e');
      return false;
    }
  }

  Future<bool> showHighRewardedAd({
    String type = 'rewarded',
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
          customData ?? {"username": "", "platform": "", "type": type};

      final response = await _advertPlugin.adsProv.showHighRewardedAd(
        type: type,
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
        dev.log('Rewarded ad ($type) completed successfully');
        return true;
      } else {
        dev.log('Error: Rewarded ad ($type) failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing rewarded ad ($type): $e');
      return false;
    }
  }

  Future<bool> showLowRewardedAd({
    String type = 'rewarded',
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
          customData ?? {"username": "", "platform": "", "type": type};

      final response = await _advertPlugin.adsProv.showLowRewardedAd(
        type: type,
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
        dev.log('Rewarded ad ($type) completed successfully');
        return true;
      } else {
        dev.log('Error: Rewarded ad ($type) failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing rewarded ad ($type): $e');
      return false;
    }
  }

  Future<bool> showRewardedInterstitialAd({
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
          customData ?? {"username": "", "platform": "", "type": "rewardedInterstitial"};

      final response = await _advertPlugin.adsProv.showRewardedInterstitialAd(
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
        dev.log('Rewarded Interstitial ad completed successfully');
        return true;
      } else {
        dev.log('Error: Rewarded Interstitial ad failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing rewarded interstitial ad: $e');
      return false;
    }
  }

  Future<bool> showHighRewardedInterstitialAd({
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
          customData ?? {"username": "", "platform": "", "type": "rewardedInterstitial"};

      final response = await _advertPlugin.adsProv.showHighRewardedInterstitialAd(
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
        dev.log('Rewarded Interstitial ad completed successfully');
        return true;
      } else {
        dev.log('Error: Rewarded Interstitial ad failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing rewarded interstitial ad: $e');
      return false;
    }
  }

  Future<bool> showLowRewardedInterstitialAd({
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
          customData ?? {"username": "", "platform": "", "type": "rewardedInterstitial"};

      final response = await _advertPlugin.adsProv.showLowRewardedInterstitialAd(
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
        dev.log('Rewarded Interstitial ad completed successfully');
        return true;
      } else {
        dev.log('Error: Rewarded Interstitial ad failed to show');
        return false;
      }
    } catch (e) {
      dev.log('Error showing rewarded interstitial ad: $e');
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
    showMultipleRewardedAds(
      context,
      maxAds: total,
      adType: 'spinAndWin',
      reason: "Spin and Win",
      customData: customData,
      onAdCompleted: onRewarded,
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
    );
  }

  Future<bool> showfreemoney({
    Function? onRewarded,
    Map<String, String>? customData,
    Function? onAdClicked,
    Function? onAdImpression,
  }) async {
    return showRewardedAd(
      type: 'freemoney',
      onRewarded: onRewarded,
      customData: customData,
      onAdClicked: onAdClicked,
      onAdImpression: onAdImpression,
    );
  }

  void showMultipleRewardedAds(
    BuildContext context, {
    required int maxAds,
    String adType = 'rewarded',
    Map<String, String>? customData,
    VoidCallback? onAdCompleted,
    Function(String)? onAdFailed,
    required String reason,
    Function? onAdClicked,
    Function? onAdImpression,
    Function(Advertresponse response)? onAdWatched,
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
          customData ?? {"username": "", "platform": "", "type": adType};

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
          adType: adType,
          reason: reason,
          customData: defaultCustomData,
          onComplete: () {
            sequenceCompleted = true;
            _isSequenceActive = false;
            _sequenceTimer?.cancel();
            if (onAdCompleted != null) onAdCompleted();
          },
          onAdWatched: onAdWatched,
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

  /// Enable or disable App Open ads on app resume
  void setAppOpenOnResume(bool enable) {
    _advertPlugin.adsProv.enableAppOpenOnResume = enable;
  }

  void showAppOpenAd({String type = 'appOpen', Function? onAdDismissed}) {
    if (!_isInitialized) {
      dev.log('Error: Ads not initialized');
      return;
    }

    try {
      _advertPlugin.adsProv.showAppOpenAd(type: type, onAdDismissed: onAdDismissed);
      dev.log('App Open ad shown: $type');
    } catch (e) {
      dev.log('Error showing app open ad: $e');
    }
  }

  void forceResetAdState() {
    dev.log('Force resetting ad state and cancelling sequence.');
    cancelSequence();
  }
}
