import 'dart:async';
import 'dart:developer' as dev;
import 'package:app_links/app_links.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/routes/app_pages.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final _box = GetStorage();

  static const String deepLinkDomain = 'mcd.5starcompany.com.ng';
  static const String claimPath = '/giveaway/claim';
  static const String _pendingIdKey = 'pending_deeplink_giveaway_id';
  static const String _pendingRouteKey = 'pending_deeplink_route';

  Future<DeepLinkService> init() async {
    _appLinks = AppLinks();
    _setupDeepLinkListener();

    // cold start: always persist to storage, never navigate here.
    // the navigator doesn't exist yet at this point in main().
    await _persistInitialLink();

    return this;
  }

  static String buildClaimLink(int giveawayId) {
    return 'https://$deepLinkDomain$claimPath?id=$giveawayId';
  }

  void savePendingGiveawayId(int id, {String route = Routes.GIVEAWAY_MODULE}) {
    dev.log('saving pending link: id=$id route=$route', name: 'DeepLink');
    _box.write(_pendingIdKey, id);
    _box.write(_pendingRouteKey, route);
  }

  /// on cold start, only persist — do not touch the navigator
  Future<void> _persistInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return;
      dev.log('initial link found: $uri', name: 'DeepLink');

      final id = _extractGiveawayId(uri);
      if (id != null) {
        savePendingGiveawayId(id);
        dev.log('initial link persisted: $id', name: 'DeepLink');
      }
    } catch (e) {
      dev.log('error persisting initial link: $e', name: 'DeepLink');
    }
  }

  void _setupDeepLinkListener() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        dev.log('runtime link received: $uri', name: 'DeepLink');
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

  /// called for runtime links only (app already running)
  void handleDeepLink(Uri uri) {
    dev.log('handling runtime deep link: $uri', name: 'DeepLink');
    final id = _extractGiveawayId(uri);
    if (id == null) return;
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
      Get.toNamed(Routes.GIVEAWAY_MODULE,
          arguments: {'id': id, 'giveaway_id': id});
    }
  }

  /// consume a pending deep link after navigation is fully settled.
  /// call this only from stable routes (home, login), not during transitions.
  bool consumePendingDeepLink() {
    final pendingId = _box.read(_pendingIdKey);
    if (pendingId == null) return false;

    final String targetRoute =
        _box.read(_pendingRouteKey) ?? Routes.GIVEAWAY_MODULE;

    // remove before scheduling to prevent double-consume
    _box.remove(_pendingIdKey);
    _box.remove(_pendingRouteKey);

    dev.log('scheduling consume: id=$pendingId route=$targetRoute',
        name: 'DeepLink');

    // wait for the current frame + post-frame to fully settle,
    // then wait one additional frame before pushing to avoid GlobalKey conflicts
    SchedulerBinding.instance.addPostFrameCallback((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        dev.log('executing consume navigation: $pendingId', name: 'DeepLink');
        Get.toNamed(targetRoute, arguments: {
          'id': pendingId,
          'giveaway_id': pendingId,
        });
      });
    });

    return true;
  }

  @override
  void onClose() {
    _linkSubscription?.cancel();
    super.onClose();
  }
}
