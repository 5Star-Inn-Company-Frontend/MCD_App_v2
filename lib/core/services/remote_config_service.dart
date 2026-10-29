import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:advert/advert.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:mcd/core/services/ads_service.dart';

class RemoteConfigService extends GetxService {
  static RemoteConfigService get to => Get.find();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final RxBool isInitialized = false.obs;
  final RxInt configUpdateTick = 0.obs;

  // Default values for all application services and feature toggles
  static final Map<String, dynamic> _defaultConfig = {
    // Services status defaults
    'service_airtime': true,
    'service_data': true,
    'service_paytv': true,
    'service_electricity': true,
    'service_betting': true,
    'service_resultchecker': true,
    'service_rechargecard': true,
    'service_airtimeconverter': true,
    'service_foreign_airtime': true,
    'service_jamb': true,
    'service_nin_validation': true,
    'service_biz_verification': true,
    'service_find_bvn': true,
    'service_bvn_verification': true,
    'service_megaland': true,
    'service_foreign_data': true,
    'service_data_pin': true,
    'service_airtime_pin': true,
    'service_spinwin': true,
    'service_giveaway': true,
    'service_predictwin': true,
    'service_freemoney': true,
    'service_virtual_card': true,

    // Payment methods defaults
    'payment_paystack': true,
    'payment_rave': true,
    'payment_monnify': true,
    'payment_squad': true,
    'payment_opay': true,
    'payment_palmpay': true,
    'payment_bank_transfer': true,
    'payment_card': true,
    'payment_ussd': true,
    'payment_general_market': true,

    // System & Maintenance
    'maintenance_mode': false,
    'maintenance_message':
        'System is currently undergoing routine maintenance. Please check back shortly.',
    'min_required_app_version': '1.0.0',
    'transaction_service_url_override': '',

    // Ads & Third-party Services
    'ads_enabled': true,
    'ads_bannerlist': false,
    'ads_showrepeat': false,
    'ads_showrepeat_users': 'all',
    'ads_test_mode': false,

    // Generic Ad Providers Toggles & Waterfall
    'ads_provider_google': true,
    'ads_provider_unity': true,
    'ads_provider_vungle': true,
    'ads_provider_levelplay': true,
    'ads_provider_chartboost': true,
    'ads_waterfall_priority': 'google,unity,vungle,levelplay,chartboost',

    // Android-specific Ad Provider Toggles & Waterfall
    'ads_provider_google_android': true,
    'ads_provider_unity_android': true,
    'ads_provider_vungle_android': true,
    'ads_provider_levelplay_android': true,
    'ads_provider_chartboost_android': true,
    'ads_waterfall_priority_android': 'google,unity,vungle,levelplay,chartboost',

    // iOS-specific Ad Provider Toggles & Waterfall
    'ads_provider_google_ios': true,
    'ads_provider_unity_ios': true,
    'ads_provider_vungle_ios': true,
    'ads_provider_levelplay_ios': true,
    'ads_provider_chartboost_ios': true,
    'ads_waterfall_priority_ios': 'google,unity,vungle,levelplay,chartboost',
    'unity_game_id_android': '3717787',
    'unity_game_id_ios': '3717786',

    // Support & Features
    'support_email': 'support@5starcompany.com.ng',
    'agent_phone_number': '',
    'leaderboard_enabled': true,
    'ai_assistant_server_url': 'https://mcdai.5starcompany.com.ng',
  };

  /// Initialize Firebase Remote Config
  Future<RemoteConfigService> init() async {
    try {
      dev.log('Initializing Firebase Remote Config Service...',
          name: 'RemoteConfig');

      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await _remoteConfig.setDefaults(_defaultConfig);

      bool updated = await _remoteConfig.fetchAndActivate();
      configUpdateTick.value++;
      dev.log(
        'Remote Config initialized. Fetch and activate success: $updated',
        name: 'RemoteConfig',
      );

      _listenToRealtimeUpdates();
      isInitialized.value = true;
    } catch (e, stack) {
      dev.log(
        'Failed to initialize Remote Config: $e',
        error: e,
        stackTrace: stack,
        name: 'RemoteConfig',
      );
      // Mark initialized so app can proceed with default values
      isInitialized.value = true;
    }
    return this;
  }

  /// Listen for real-time config updates from Firebase Console
  void _listenToRealtimeUpdates() {
    try {
      _remoteConfig.onConfigUpdated.listen((event) async {
        dev.log(
          'Remote Config updated in real-time. Keys changed: ${event.updatedKeys}',
          name: 'RemoteConfig',
        );
        await _remoteConfig.activate();
        configUpdateTick.value++;
        AdsService().applyRemoteConfigAdSettings();
      }, onError: (error) {
        dev.log('Error listening to Remote Config updates: $error',
            name: 'RemoteConfig');
      });
    } catch (e) {
      dev.log('Real-time config update listener error: $e',
          name: 'RemoteConfig');
    }
  }

  /// Check if a specific service or feature flag is enabled via Remote Config
  bool isServiceEnabled(String serviceKey, {bool? defaultValue}) {
    final normalizedKey = _normalizeServiceKey(serviceKey);
    bool fallback = defaultValue ?? true;
    if (_defaultConfig.containsKey(normalizedKey)) {
      final def = _defaultConfig[normalizedKey];
      if (def is bool) fallback = def;
    }
    return getBool(normalizedKey, defaultValue: fallback);
  }

  /// Check if repeat ads are enabled for a specific username/user
  bool isShowRepeatEnabledForUser(String username) {
    if (!isServiceEnabled('ads_showrepeat')) return false;

    final allowedUsers = getString('ads_showrepeat_users', defaultValue: 'all');
    if (allowedUsers == 'all' || allowedUsers.trim().isEmpty) {
      return true;
    }

    final userList = allowedUsers
        .split(',')
        .map((u) => u.trim().toLowerCase())
        .toList();

    return userList.contains(username.trim().toLowerCase());
  }

  /// Check if banner list ads are enabled for a specific username/user
  bool isBannerListEnabledForUser(String username) {
    if (!isServiceEnabled('ads_bannerlist')) return false;

    final allowedUsers = getString('ads_showrepeat_users', defaultValue: 'all');
    if (allowedUsers == 'all' || allowedUsers.trim().isEmpty) {
      return true;
    }

    final userList = allowedUsers
        .split(',')
        .map((u) => u.trim().toLowerCase())
        .toList();

    return userList.contains(username.trim().toLowerCase());
  }

  /// Map string name to AdProviderType
  AdProviderType? _parseAdProviderType(String name) {
    switch (name.trim().toLowerCase()) {
      case 'google':
      case 'admob':
        return AdProviderType.google;
      case 'unity':
      case 'unityads':
        return AdProviderType.unity;
      case 'vungle':
      case 'liftoff':
        return AdProviderType.vungle;
      case 'levelplay':
      case 'ironsource':
        return AdProviderType.levelplay;
      case 'chartboost':
        return AdProviderType.chartboost;
      default:
        return null;
    }
  }

  /// Get enabled map for all ad providers (platform-aware)
  Map<AdProviderType, bool> getAdProviderEnabledMap() {
    final platformSuffix = Platform.isAndroid ? '_android' : (Platform.isIOS ? '_ios' : '');

    bool checkProvider(String providerName) {
      final platformKey = 'ads_provider_$providerName$platformSuffix';
      final genericKey = 'ads_provider_$providerName';

      if (_remoteConfig.getAll().containsKey(platformKey)) {
        return _remoteConfig.getBool(platformKey);
      }
      if (_remoteConfig.getAll().containsKey(genericKey)) {
        return _remoteConfig.getBool(genericKey);
      }
      return getBool(platformKey, defaultValue: true);
    }

    return {
      AdProviderType.google: checkProvider('google'),
      AdProviderType.unity: checkProvider('unity'),
      AdProviderType.vungle: checkProvider('vungle'),
      AdProviderType.levelplay: checkProvider('levelplay'),
      AdProviderType.chartboost: checkProvider('chartboost'),
    };
  }

  /// Get priority order list for ad waterfall (platform-aware)
  List<AdProviderType> getAdProviderPriorityOrder() {
    final defaultOrder = [
      AdProviderType.google,
      AdProviderType.unity,
      AdProviderType.vungle,
      AdProviderType.levelplay,
      AdProviderType.chartboost,
    ];

    final platformSuffix = Platform.isAndroid ? '_android' : (Platform.isIOS ? '_ios' : '');
    final platformKey = 'ads_waterfall_priority$platformSuffix';
    final genericKey = 'ads_waterfall_priority';

    String rawOrderString = '';
    if (_remoteConfig.getAll().containsKey(platformKey)) {
      rawOrderString = _remoteConfig.getString(platformKey);
    } else if (_remoteConfig.getAll().containsKey(genericKey)) {
      rawOrderString = _remoteConfig.getString(genericKey);
    } else {
      rawOrderString = getString(platformKey, defaultValue: 'google,unity,vungle,levelplay,chartboost');
    }

    if (rawOrderString.isEmpty) return defaultOrder;
    final parsedOrder = <AdProviderType>[];
    final parts = rawOrderString.split(',');

    for (final part in parts) {
      final type = _parseAdProviderType(part);
      if (type != null && !parsedOrder.contains(type)) {
        parsedOrder.add(type);
      }
    }

    for (final type in defaultOrder) {
      if (!parsedOrder.contains(type)) {
        parsedOrder.add(type);
      }
    }

    return parsedOrder;
  }

  /// Check if a specific payment method is enabled via Remote Config
  bool isPaymentMethodEnabled(String method) {
    final normalizedKey = _normalizePaymentKey(method);
    bool fallback = true;
    if (_defaultConfig.containsKey(normalizedKey)) {
      final def = _defaultConfig[normalizedKey];
      if (def is bool) fallback = def;
    }
    return getBool(normalizedKey, defaultValue: fallback);
  }

  /// Check if maintenance mode is enabled
  bool isMaintenanceMode() {
    return getBool('maintenance_mode', defaultValue: false);
  }

  /// Get maintenance message
  String getMaintenanceMessage() {
    return getString(
      'maintenance_message',
      defaultValue:
          'System is currently undergoing routine maintenance. Please check back shortly.',
    );
  }

  /// Get minimum required app version
  String getMinAppVersion() {
    return getString('min_required_app_version', defaultValue: '1.0.0');
  }

  /// Get boolean parameter value
  bool getBool(String key, {bool defaultValue = false}) {
    configUpdateTick.value; // Register GetX reactive dependency
    try {
      if (_remoteConfig.getAll().containsKey(key)) {
        return _remoteConfig.getBool(key);
      }
      if (_defaultConfig.containsKey(key)) {
        final def = _defaultConfig[key];
        if (def is bool) return def;
        if (def is String) return def.toLowerCase() == 'true' || def == '1';
      }
      return defaultValue;
    } catch (e) {
      dev.log('Error getting bool for key "$key": $e', name: 'RemoteConfig');
      return defaultValue;
    }
  }

  /// Get string parameter value
  String getString(String key, {String defaultValue = ''}) {
    configUpdateTick.value; // Register GetX reactive dependency
    try {
      if (!_remoteConfig.getAll().containsKey(key)) {
        return defaultValue;
      }
      final val = _remoteConfig.getString(key);
      return val.isEmpty ? defaultValue : val;
    } catch (e) {
      dev.log('Error getting string for key "$key": $e', name: 'RemoteConfig');
      return defaultValue;
    }
  }

  /// Get integer parameter value
  int getInt(String key, {int defaultValue = 0}) {
    configUpdateTick.value; // Register GetX reactive dependency
    try {
      if (!_remoteConfig.getAll().containsKey(key)) {
        return defaultValue;
      }
      return _remoteConfig.getInt(key);
    } catch (e) {
      dev.log('Error getting int for key "$key": $e', name: 'RemoteConfig');
      return defaultValue;
    }
  }

  /// Get double parameter value
  double getDouble(String key, {double defaultValue = 0.0}) {
    configUpdateTick.value; // Register GetX reactive dependency
    try {
      if (!_remoteConfig.getAll().containsKey(key)) {
        return defaultValue;
      }
      return _remoteConfig.getDouble(key);
    } catch (e) {
      dev.log('Error getting double for key "$key": $e', name: 'RemoteConfig');
      return defaultValue;
    }
  }

  /// Get JSON object parameter
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString.isNotEmpty) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
    } catch (e) {
      dev.log('Error decoding JSON for key "$key": $e', name: 'RemoteConfig');
    }
    return null;
  }

  /// Explicitly force refresh Remote Config from Firebase servers
  Future<bool> forceRefresh() async {
    try {
      dev.log('Force refreshing Remote Config from Firebase...', name: 'RemoteConfig');
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      bool updated = await _remoteConfig.fetchAndActivate();
      configUpdateTick.value++;
      AdsService().applyRemoteConfigAdSettings();
      dev.log('Remote Config force refresh success: $updated (Tick: ${configUpdateTick.value})', name: 'RemoteConfig');
      return updated;
    } catch (e) {
      dev.log('Force refresh failed: $e', name: 'RemoteConfig');
      return false;
    }
  }

  /// Helper to map service keys to remote config keys
  String _normalizeServiceKey(String key) {
    String cleanKey = key.toLowerCase().trim();
    // Handle aliases
    if (cleanKey == 'cable' || cleanKey == 'paytv') {
      cleanKey = 'paytv';
    } else if (cleanKey == 'epin' || cleanKey == 'rechargecard') {
      cleanKey = 'rechargecard';
    }

    // If key exists as-is in defaults or remote config, or starts with ads_, payment_, service_
    if (_defaultConfig.containsKey(cleanKey) ||
        _remoteConfig.getAll().containsKey(cleanKey) ||
        cleanKey.startsWith('ads_') ||
        cleanKey.startsWith('payment_') ||
        cleanKey.startsWith('service_')) {
      return cleanKey;
    }

    // Check if prefixed service_ key exists in defaults or remote config
    final prefixed = 'service_$cleanKey';
    if (_defaultConfig.containsKey(prefixed) ||
        _remoteConfig.getAll().containsKey(prefixed)) {
      return prefixed;
    }

    return cleanKey;
  }

  /// Helper to map payment method keys to remote config keys
  String _normalizePaymentKey(String method) {
    String cleanKey = method.toLowerCase().trim();
    if (cleanKey == 'general_market' || cleanKey == 'pay_gm') {
      cleanKey = 'general_market';
    }

    if (cleanKey.startsWith('payment_')) {
      return cleanKey;
    }
    return 'payment_$cleanKey';
  }
}
