import 'dart:async';
import 'dart:developer' as dev;
import 'package:advert/model/advertresponse.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/dio_api_service.dart';
import 'package:mcd/core/services/ads_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/strings.dart';

class SpinWinItem {
  final int id;
  final String name;
  final String type;
  final String network;
  final int amount;
  final String coded;
  final bool requiresInput;

  SpinWinItem({
    required this.id,
    required this.name,
    required this.type,
    required this.network,
    required this.amount,
    required this.coded,
    required this.requiresInput,
  });

  factory SpinWinItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] ?? 'empty';
    // airtime and data require phone number input
    final requiresInput = type == 'airtime' || type == 'data';

    // parse amount - handle both int and string
    int amount = 0;
    if (json['amount'] != null) {
      if (json['amount'] is int) {
        amount = json['amount'];
      } else if (json['amount'] is String) {
        amount = int.tryParse(json['amount']) ?? 0;
      }
    }

    return SpinWinItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: type,
      network: json['network'] ?? '',
      amount: amount,
      coded: json['coded'] ?? '',
      requiresInput: requiresInput,
    );
  }
}

class SpinWinModuleController extends GetxController {
  final apiService = DioApiService();
  final adsService = AdsService();
  final box = GetStorage();

  // observables
  final _spinItems = <SpinWinItem>[].obs;
  final _chancesRemaining = 5.obs;
  final _freeSpinsRemaining = 0.obs;
  final _maxFreeSpins = 0.obs;
  final _timesPlayed = 0.obs;
  final _isLoading = false.obs;
  final _isSpinning = false.obs;
  final _isPlayingAds = false.obs;
  final _adsWatched = 0.obs;
  final selected = 0.obs;

  // countdown timer
  final _timeUntilReset = ''.obs;
  Timer? _countdownTimer;

  // phone number controller for dialog
  final phoneNumberController = TextEditingController();

  // stream controller for fortune wheel
  final StreamController<int> _selectedController =
      StreamController<int>.broadcast();
  Stream<int> get selectedStream => _selectedController.stream;

  // getters
  List<SpinWinItem> get spinItems => _spinItems;
  int get chancesRemaining => _chancesRemaining.value;
  int get freeSpinsRemaining => _freeSpinsRemaining.value;
  int get maxFreeSpins => _maxFreeSpins.value;
  int get timesPlayed => _timesPlayed.value;
  bool get isLoading => _isLoading.value;
  bool get isSpinning => _isSpinning.value;
  bool get isPlayingAds => _isPlayingAds.value;
  int get adsWatched => _adsWatched.value;
  String get timeUntilReset => _timeUntilReset.value;

  @override
  void onInit() {
    super.onInit();
    dev.log('SpinWinModule initialized', name: 'SpinWinModule');
    _loadLocalChances();
    _startCountdownTimer();
    fetchSpinData();
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    _selectedController.close();
    _countdownTimer?.cancel();
    super.onClose();
  }

  // paste phone number from clipboard
  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null && clipboardData.text != null) {
        String phone = clipboardData.text!.replaceAll(RegExp(r'[^0-9]'), '');

        // normalize nigerian numbers
        if (phone.startsWith('234')) {
          phone = '0${phone.substring(3)}';
        } else if (phone.startsWith('+234')) {
          phone = '0${phone.substring(4)}';
        } else if (!phone.startsWith('0') && phone.length == 10) {
          phone = '0$phone';
        }

        if (phone.length == 11) {
          phoneNumberController.text = phone;
          dev.log('Pasted phone: $phone', name: 'SpinWinModule');
        } else {
          Get.snackbar(
            'Invalid Number',
            'Clipboard does not contain a valid Nigerian phone number',
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        }
      } else {
        Get.snackbar(
          'Empty Clipboard',
          'No text found in clipboard',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      dev.log('Paste error: $e', name: 'SpinWinModule');
    }
  }

  // pick contact for phone number dialog
  Future<void> _pickContactForDialog() async {
    try {
      final permissionStatus = await Permission.contacts.request();

      if (permissionStatus.isGranted) {
        String? number = await contactpicked();

        if (number != null && number.length == 11) {
              phoneNumberController.text = number;
              dev.log('Selected contact: $number', name: 'SpinWinModule');
            } else {
              Get.snackbar(
                'Invalid Number',
                'Selected contact does not have a valid Nigerian phone number',
                backgroundColor: AppColors.errorBgColor,
                colorText: AppColors.textSnackbarColor,
              );
            }
      } else if (permissionStatus.isPermanentlyDenied) {
        Get.snackbar(
          'Permission Denied',
          'Please enable contacts permission in settings',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        await openAppSettings();
      } else {
        Get.snackbar(
          'Permission Required',
          'Contacts permission is required',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      dev.log('Contact picker error: $e', name: 'SpinWinModule');
      Get.snackbar(
        'Error',
        'Failed to pick contact',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  // load chances from local storage
  void _loadLocalChances() {
    final savedChances = box.read('spin_chances_remaining');
    final lastResetTime = box.read('spin_last_reset_time');

    if (savedChances != null && lastResetTime != null) {
      final lastReset = DateTime.parse(lastResetTime);
      final now = DateTime.now();
      final hoursSinceReset = now.difference(lastReset).inHours;

      // reset if 5 hours have passed
      if (hoursSinceReset >= 5) {
        _chancesRemaining.value = 5;
        box.write('spin_chances_remaining', 5);
        box.write('spin_last_reset_time', now.toIso8601String());
        dev.log('Chances reset after 5 hours', name: 'SpinWinModule');
      } else {
        _chancesRemaining.value = savedChances;
        dev.log('Loaded saved chances: $savedChances', name: 'SpinWinModule');
      }
    } else {
      // first time - initialize
      _chancesRemaining.value = 5;
      box.write('spin_chances_remaining', 5);
      box.write('spin_last_reset_time', DateTime.now().toIso8601String());
    }
  }

  // start countdown timer for reset
  void _startCountdownTimer() {
    _updateTimeUntilReset();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeUntilReset();
    });
  }

  // update time until reset string
  void _updateTimeUntilReset() {
    final lastResetTime = box.read('spin_last_reset_time');
    if (lastResetTime == null) return;

    final lastReset = DateTime.parse(lastResetTime);
    final resetTime = lastReset.add(const Duration(hours: 5));
    final now = DateTime.now();

    if (now.isAfter(resetTime)) {
      // time to reset
      if (_chancesRemaining.value == 0) {
        _chancesRemaining.value = 5;
        box.write('spin_chances_remaining', 5);
        box.write('spin_last_reset_time', now.toIso8601String());
      }
      _timeUntilReset.value = '';
    } else {
      final remaining = resetTime.difference(now);
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      final seconds = remaining.inSeconds % 60;
      _timeUntilReset.value =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // save chances to local storage
  void _saveChances() {
    box.write('spin_chances_remaining', _chancesRemaining.value);
    dev.log('Saved chances: ${_chancesRemaining.value}', name: 'SpinWinModule');
  }

  // fetch spin data from API
  Future<void> fetchSpinData() async {
    try {
      _isLoading.value = true;
      dev.log('Fetching spin data...', name: 'SpinWinModule');

      final utilityUrl = box.read('utility_service_url');
      if (utilityUrl == null || utilityUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Service URL not found. Please log in again.',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      final url = '${utilityUrl}spinwin-fetch';
      dev.log('Fetching from: $url', name: 'SpinWinModule');

      final result = await apiService.getrequest(url);

      result.fold(
        (failure) {
          dev.log('Failed to fetch spin data',
              name: 'SpinWinModule', error: failure.message);
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (response) {
          dev.log('Spin data response: $response', name: 'SpinWinModule');
          print('SPIN FETCH RESPONSE: $response');

          if (response['success'] == 1) {
            // parse free_spin from response
            final freeSpin = response['free_spin'];
            if (freeSpin != null) {
              final spins = freeSpin is int
                  ? freeSpin
                  : int.tryParse(freeSpin.toString()) ?? 0;
              _freeSpinsRemaining.value = spins;
              // set max if not set (first load)
              if (_maxFreeSpins.value == 0 || spins > _maxFreeSpins.value) {
                _maxFreeSpins.value = spins;
              }
              dev.log(
                  'Free spins from server: ${_freeSpinsRemaining.value}, max: ${_maxFreeSpins.value}',
                  name: 'SpinWinModule');
            }

            // parse items
            if (response['data'] != null && response['data'] is List) {
              _spinItems.value = (response['data'] as List)
                  .map((item) =>
                      SpinWinItem.fromJson(item as Map<String, dynamic>))
                  .toList();

              dev.log('Loaded ${_spinItems.length} items',
                  name: 'SpinWinModule');
            }
          }
        },
      );
    } catch (e) {
      dev.log('Exception while fetching spin data',
          name: 'SpinWinModule', error: e);
      Get.snackbar(
        'Error',
        'Failed to fetch spin data: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Perform spin action
  Future<void> performSpin() async {
    if (_chancesRemaining.value <= 0) {
      Get.snackbar(
        'No Chances',
        'You have no spin chances remaining. Please wait 5 hours.',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    if (_spinItems.isEmpty) {
      Get.snackbar(
        'Error',
        'No spin items available',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
      return;
    }

    try {
      // check if user has free spins
      if (_freeSpinsRemaining.value > 0) {
        // free spin - no ads required
        dev.log('Using free spin (${_freeSpinsRemaining.value} remaining)',
            name: 'SpinWinModule');
        await _executeSpinWithReward();
        _freeSpinsRemaining.value--;
      } else {
        // no free spins - must watch 5 ads first
        dev.log('No free spins, playing 5 ads...', name: 'SpinWinModule');
        _playAdsBeforeSpin(
          onSuccess: () async {
            await _executeSpinWithReward();
          },
          onFailed: (){
            Get.snackbar(
              'Ads Required',
              'You must complete all 5 ads to spin. Please try again.',
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor,
            );
          }
        );

      }
    } catch (e) {
      dev.log('Exception while performing spin',
          name: 'SpinWinModule', error: e);
      Get.snackbar(
        'Error',
        'Failed to perform spin: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  // play 5 ads before allowing spin
  void _playAdsBeforeSpin({required Function onSuccess, required Function onFailed}) async {
    _isPlayingAds.value = true;

    try {
      // for (int i = 0; i < 5; i++) {
        dev.log('Playing ad ${_adsWatched.value}/5...', name: 'SpinWinModule');

        adsService.showspinAndWinAd(
          onRewarded: () {
            if (_adsWatched.value < 5) {
              _adsWatched.value += 1;
              print("multiple advert ${_adsWatched.value}");
              return  _playAdsBeforeSpin( onSuccess: onSuccess, onFailed: onFailed);
            } else {
              print("multiple advert ${_adsWatched.value} finished");
              _adsWatched.value = 0;
              onSuccess();
            }
            dev.log('Ad ${_adsWatched.value}/5 completed', name: 'SpinWinModule');
          },
          customData: {
            "username": box.read('username') ?? "",
            "platform": "mobile",
            "type": "spin_win"
          },
        );
      // }

      // dev.log('All 5 ads completed successfully', name: 'SpinWinModule');
      // return true;
    } finally {
      _isPlayingAds.value = false;
    }
  }

  // execute the actual spin and reward
  Future<void> _executeSpinWithReward() async {
    _isSpinning.value = true;
    dev.log('Performing spin...', name: 'SpinWinModule');

    try {
      // generate random index for spin result
      final randomIndex =
          DateTime.now().millisecondsSinceEpoch % _spinItems.length;
      selected.value = randomIndex;

      // trigger the wheel to spin
      _selectedController.add(randomIndex);

      // wait for animation to complete
      await Future.delayed(const Duration(seconds: 4));

      final wonItem = _spinItems[randomIndex];
      dev.log('Spin landed on: ${wonItem.name}', name: 'SpinWinModule');

      // increment times played, decrement chances
      _timesPlayed.value++;
      _chancesRemaining.value--;
      _saveChances();

      // check if item is Opps/Try Again (coded == 'empty')
      if (wonItem.coded == 'empty') {
        // show opps dialog and submit with number='0'
        _showOppsDialog(wonItem);
      } else if (wonItem.requiresInput) {
        // item requires phone number input
        _showPhoneNumberDialog(wonItem);
      } else {
        // submit without phone number
        await _submitSpinResult(wonItem, null);
      }

      // refetch spin data for next roll
      await fetchSpinData();
    } finally {
      _isSpinning.value = false;
    }
  }

  // show dialog for Opps/Try Again result
  void _showOppsDialog(SpinWinItem item) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied,
                color: AppColors.errorBgColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.manRope),
              ),
              const SizedBox(height: 8),
              Text(
                'Better luck next time!',
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryGrey,
                    fontFamily: AppFonts.manRope),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // submit with number='0' for opps items
                    _submitSpinResult(item, '0');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Try Again',
                      style: TextStyle(
                          color: Colors.white, fontFamily: AppFonts.manRope)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Show dialog for phone number input
  void _showPhoneNumberDialog(SpinWinItem item) {
    phoneNumberController.clear();

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                color: AppColors.primaryColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Congratulations!',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.manRope),
              ),
              const SizedBox(height: 8),
              Text(
                'You won: ${item.name}',
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.manRope),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Network: ${item.network}',
                style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryGrey,
                    fontFamily: AppFonts.manRope),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontFamily: AppFonts.manRope),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '08012345678',
                  labelStyle: const TextStyle(fontFamily: AppFonts.manRope),
                  hintStyle: const TextStyle(
                      fontFamily: AppFonts.manRope,
                      color: AppColors.primaryGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.paste, size: 20),
                        onPressed: () => _pasteFromClipboard(),
                        tooltip: 'Paste',
                      ),
                      IconButton(
                        icon: const Icon(Icons.contacts, size: 20),
                        onPressed: () => _pickContactForDialog(),
                        tooltip: 'Pick Contact',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        phoneNumberController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        // side: const BorderSide(color: AppColors.primaryGrey),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontFamily: AppFonts.manRope,
                              color: AppColors.errorBgColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (phoneNumberController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter phone number',
                            backgroundColor: AppColors.errorBgColor,
                            colorText: AppColors.textSnackbarColor,
                          );
                          return;
                        }
                        Get.back();
                        _submitSpinResult(item, phoneNumberController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Submit',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.manRope)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Submit spin result to API
  Future<void> _submitSpinResult(SpinWinItem item, String? phoneNumber) async {
    try {
      final utilityUrl = box.read('utility_service_url');
      if (utilityUrl == null || utilityUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Service URL not found',
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      final url = '${utilityUrl}spinwin-continue';
      dev.log('Submitting spin result to: $url', name: 'SpinWinModule');

      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final day = double.parse(DateFormat('dd').format(DateTime.now()));

      final body = {
        'id': (timestamp + (item.id * day)).toString(),
        'ids': timestamp.toString(),
        'number': phoneNumber ?? '',
        'timesPlayed': _timesPlayed.value.toString(),
      };

      dev.log('item.id: ${item.id}');
      dev.log('SPINWIN PAYLOAD: $body', name: 'SpinWinModule');

      final result = await apiService.postrequest(url, body);

      result.fold(
        (failure) {
          dev.log('SPINWIN ERROR RESPONSE: ${failure.message}',
              name: 'SpinWinModule');
          Get.snackbar(
            'Error',
            failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor,
          );
        },
        (response) {
          dev.log('SPINWIN SUCCESS RESPONSE: $response', name: 'SpinWinModule');

          Get.snackbar(
            'Success!',
            response['message'] ??
                'Your reward has been processed successfully',
            backgroundColor: AppColors.successBgColor,
            colorText: AppColors.textSnackbarColor,
            duration: const Duration(seconds: 3),
          );

          // Refresh spin data
          fetchSpinData();
        },
      );
    } catch (e) {
      dev.log('Exception while submitting spin result',
          name: 'SpinWinModule', error: e);
      Get.snackbar(
        'Error',
        'Failed to submit: $e',
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }
}
