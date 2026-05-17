import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/app/routes/app_pages.dart';
import 'package:mcd/app/theme/lightTheme.dart';
import 'package:mcd/app/widgets/connectivity_banner.dart';
import 'package:mcd/core/services/notification_permission_service.dart';

class McdApp extends StatefulWidget {
  const McdApp({super.key});

  @override
  State<McdApp> createState() => _McdAppState();
}

class _McdAppState extends State<McdApp> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationPermissionService.ensurePermissionOnAppOpen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: 'MEGA Cheap Data',
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.SPLASH_SCREEN,
        getPages: AppPages.pages,
        theme: lightTheme,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        builder: (context, child) {
          return ConnectivityBanner(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }
}
