import 'dart:async';
import 'dart:developer' as dev;
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/routes/app_pages.dart';

class DeepLinkService extends GetxService {
  static late DeepLinkService to;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final _box = GetStorage();

  static const String deepLinkDomain = 'mcd.5starcompany.com.ng';
  static const String claimPath = '/giveaway/claim';
  static const String _pendingIdKey = 'pending_deeplink_giveaway_id';
  static const String _pendingRouteKey = 'pending_deeplink_route';
  static const String _pendingTsKey = 'pending_deeplink_ts';

  bool _navigationReady = false;
  Uri? _initialLinkUri;

  Future<DeepLinkService> init() async {
    to = this;
    _appLinks = AppLinks();
    _setupDeepLinkListener();
    await _persistInitialLink();
    return this;
  }

  static String buildClaimLink(int giveawayId) {
    return 'https://$deepLinkDomain$claimPath?id=$giveawayId';
  }

  void markNavigationReady() {
    _navigationReady = true;
    dev.log('navigation marked ready', name: 'DeepLink');
  }

  void savePendingGiveawayId(int id, {String route = Routes.GIVEAWAY_MODULE}) {
    dev.log('saving pending link: id=$id route=$route', name: 'DeepLink');
    _box.write(_pendingIdKey, id);
    _box.write(_pendingRouteKey, route);
    _box.write(_pendingTsKey, DateTime.now().toIso8601String());
  }

  Future<void> _persistInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return;
      dev.log('initial link found: $uri', name: 'DeepLink');

      _initialLinkUri = uri;

      final id = _extractGiveawayId(uri);
      if (id != null) {
        savePendingGiveawayId(id);
        dev.log('initial link persisted: $id', name: 'DeepLink');
      }
    } catch (e) {
      dev.log('error persisting initial link: $e', name: 'DeepLink');
    }
  }

  bool _isDuplicateOfInitialLink(Uri uri) {
    if (_initialLinkUri == null) return false;
    return uri.toString() == _initialLinkUri.toString();
  }

  void _setupDeepLinkListener() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        dev.log('runtime link received: $uri', name: 'DeepLink');

        if (_isDuplicateOfInitialLink(uri)) {
          dev.log('duplicate of initial link, skipping', name: 'DeepLink');
          _initialLinkUri = null;
          return;
        }

        handleDeepLink(uri);
      },
      onError: (err) {
        dev.log('link stream error: $err', name: 'DeepLink');
      },
    );
    dev.log('deep link listener started', name: 'DeepLink');
  }

  int? _extractGiveawayId(Uri uri) {
    final bool isClaimLink = uri.path.contains(claimPath) ||
        (uri.host == 'giveaway' && uri.path.contains('/claim'));
    if (!isClaimLink) return null;

    final rawId = uri.queryParameters['id'];
    if (rawId == null) return null;
    return int.tryParse(rawId);
  }

  void handleDeepLink(Uri uri) {
    dev.log('handling deep link: $uri', name: 'DeepLink');
    final id = _extractGiveawayId(uri);
    if (id == null) return;

    if (!_navigationReady) {
      dev.log('navigation not ready, deferring: $id', name: 'DeepLink');
      savePendingGiveawayId(id);
      return;
    }

    _navigateWithAuthCheck(id);
  }

  void _navigateWithAuthCheck(int id) {
    final token = _box.read('token');
    final String currentRoute = Get.currentRoute;
    final bool isInitializing =
        currentRoute == Routes.SPLASH_SCREEN || currentRoute.isEmpty;

    if (isInitializing) {
      dev.log('navigator not ready, deferring: $id', name: 'DeepLink');
      savePendingGiveawayId(id);
      return;
    }

    if (token == null || token.toString().isEmpty) {
      dev.log('not logged in, deferring and redirecting to login', name: 'DeepLink');
      savePendingGiveawayId(id);
      Get.snackbar(
        'Login Required',
        'Please login to claim your giveaway',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed(Routes.LOGIN_SCREEN);
    } else {
      dev.log('navigating to giveaway module: $id', name: 'DeepLink');
      final args = {'id': id, 'giveaway_id': id};
      if (currentRoute == Routes.GIVEAWAY_MODULE) {
        Get.offNamed(Routes.GIVEAWAY_MODULE, arguments: args);
      } else {
        Get.toNamed(Routes.GIVEAWAY_MODULE, arguments: args);
      }
    }
  }

  bool consumePendingDeepLink() {
    final pendingId = _box.read(_pendingIdKey);
    if (pendingId == null) return false;

    final String targetRoute =
        _box.read(_pendingRouteKey) ?? Routes.GIVEAWAY_MODULE;

    final tsRaw = _box.read(_pendingTsKey);
    _box.remove(_pendingIdKey);
    _box.remove(_pendingRouteKey);
    _box.remove(_pendingTsKey);

    if (tsRaw != null) {
      final ts = DateTime.tryParse(tsRaw.toString());
      if (ts != null && DateTime.now().difference(ts).inDays > 7) {
        dev.log('pending deep link expired, discarding: $pendingId',
            name: 'DeepLink');
        return false;
      }
    }

    dev.log('consuming pending deep link: id=$pendingId route=$targetRoute',
        name: 'DeepLink');

    Get.toNamed(targetRoute, arguments: {
      'id': pendingId,
      'giveaway_id': pendingId,
    });

    return true;
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
