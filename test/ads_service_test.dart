// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get/get.dart';
// import 'package:mcd/core/services/ads_service.dart';
// import 'package:mcd/core/services/connectivity_service.dart';

// // ----------------------------------------------------------------------
// // 1. MOCK DEPENDENCIES
// // ----------------------------------------------------------------------

// /// fake connectivity to control network state in tests
// class FakeConnectivityService extends ConnectivityService {
//   @override
//   final isConnected = true.obs;

//   void simulateNetworkDrop() => isConnected.value = false;
//   void simulateNetworkRestore() => isConnected.value = true;

//   @override
//   void onInit() {
//     // prevent real plugin initialization
//   }
// }

// // ----------------------------------------------------------------------
// // 2. TEST SUITE
// // ----------------------------------------------------------------------
// void main() {
//   late AdsService adsService;

//   setUp(() {
//     Get.reset();
//     adsService = AdsService();
//     adsService.resetForTesting();
//     adsService.testMode = true;
//     adsService.setInitializedForTesting(true);
//   });

//   tearDown(() {
//     adsService.cancelSequence();
//     adsService.resetForTesting();
//   });

//   testWidgets(
//     'Test 2: Timer aborts sequence and triggers onAdFailed when network drops (and ad is not showing)',
//     (WidgetTester tester) async {
//       final fakeNetwork = FakeConnectivityService();
//       Get.put<ConnectivityService>(fakeNetwork);

//       bool failedCallbackTriggered = false;
//       String? capturedError;

//       await tester.pumpWidget(GetMaterialApp(
//         home: Scaffold(body: Container()),
//       ));

//       // ad is not currently showing on screen
//       adsService.testIsShowingAds = false;

//       adsService.showMultipleRewardedAds(
//         tester.element(find.byType(Scaffold)),
//         maxAds: 2,
//         reason: 'Test',
//         onAdFailed: (err) {
//           failedCallbackTriggered = true;
//           capturedError = err;
//         },
//       );

//       // let async function proceed past initialization
//       await tester.pump();

//       // simulate network drop
//       fakeNetwork.simulateNetworkDrop();

//       // advance 500ms to trigger watchdog tick
//       await tester.pump(const Duration(milliseconds: 500));

//       expect(failedCallbackTriggered, isTrue,
//           reason: 'onAdFailed callback must be triggered');
//       expect(capturedError, contains('Network connection lost'),
//           reason: 'Error message must specify network loss');
//     },
//   );

//   testWidgets(
//     'Test 3: Watchdog forcefully dismisses stuck Plugin Dialogs on network drop',
//     (WidgetTester tester) async {
//       final fakeNetwork = FakeConnectivityService();
//       Get.put<ConnectivityService>(fakeNetwork);

//       await tester.pumpWidget(GetMaterialApp(
//         home: Scaffold(body: Container()),
//       ));

//       // simulate a stuck "Preparing Ad..." dialog
//       Get.dialog(const AlertDialog(title: Text('Preparing Ad...')));
//       await tester.pumpAndSettle();

//       expect(Get.isDialogOpen, isTrue,
//           reason: 'Plugin dialog should be open initially');

//       // ad is not currently showing on screen
//       adsService.testIsShowingAds = false;

//       adsService.showMultipleRewardedAds(
//         tester.element(find.byType(Scaffold)),
//         maxAds: 2,
//         reason: 'Test',
//         onAdFailed: (_) {},
//       );

//       // let async function proceed
//       await tester.pump();

//       // simulate network drop
//       fakeNetwork.simulateNetworkDrop();

//       // trigger watchdog
//       await tester.pump(const Duration(milliseconds: 500));
//       await tester.pumpAndSettle();

//       expect(Get.isDialogOpen, isFalse,
//           reason: 'Watchdog timer should have dismissed the stuck dialog');
//     },
//   );
// }
