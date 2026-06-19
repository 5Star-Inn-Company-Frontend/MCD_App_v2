import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mcd/app/modules/account_info_module/account_info_module_controller.dart';
import 'package:mcd/app/modules/home_screen_module/home_screen_controller.dart';
import 'package:mcd/app/modules/foreign_airtime_module/country_selection_controller.dart';
import 'package:mcd/app/modules/home_screen_module/model/dashboard_model.dart';
import 'package:mcd/app/modules/login_screen_module/models/user_signup_data.dart';
import 'package:mcd/app/styles/app_colors.dart';
import 'package:mcd/app/widgets/loading_dialog.dart';
import 'package:mcd/core/services/ads_service.dart';

import '../../../core/constants/fonts.dart';
import '../../../core/controllers/service_status_controller.dart';
import '../../../core/controllers/payment_config_controller.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_api_service.dart';
// import '../../../core/services/deep_link_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/validator.dart';
import '../../routes/app_pages.dart';
import '../../styles/fonts.dart';
/**
 * GetX Template Generator - fb.com/htngu.99
 * */

class LoginScreenController extends GetxService {
  final _obj = ''.obs;
  set obj(value) => _obj.value = value;
  String get obj => _obj.value;

  final storage = GetStorage();

  var formKey = GlobalKey<FormState>();

  final _isEmail = true.obs;
  set isEmail(value) {
    _isEmail.value = value;
    setFormValidState(); // Re-validate when switching modes
  }
  bool get isEmail => _isEmail.value;

  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  final PhoneNumber number = PhoneNumber(isoCode: 'NG');

  var _isPasswordVisible = true.obs;
  set isPasswordVisible(value) => _isPasswordVisible.value = value;
  RxBool get isPasswordVisible => _isPasswordVisible; // Remove .value here

  var _isFormValid = false.obs;
  set isFormValid(value) => _isFormValid.value = value;
  bool get isFormValid => _isFormValid.value;

  final _errorText = "".obs;
  set errorText(value) => _errorText.value = value;
  String get errorText => _errorText.value;

  final adsService = AdsService();

  void validateInput(String value) {
    if (CustomValidator.isValidAccountNumber(value.trim()) == false) {
      errorText = 'Please enter a valid phone';
    } else {
      errorText = "";
    }
  }

  void _setupValidationWorkers() {
    // Listen to changes in all relevant fields
    final controllers = [
      emailController,
      phoneNumberController,
      passwordController,
    ];

    for (var controller in controllers) {
      controller.addListener(setFormValidState);
    }
  }

  void setFormValidState() {
    final pass = passwordController.text.trim();
    final isPasswordValid = pass.isNotEmpty && pass.length >= 6;

    bool isValid = false;
    if (isEmail) {
      final email = emailController.text.trim();
      isValid = email.isNotEmpty && isPasswordValid;
    } else {
      final phone = phoneNumberController.text.trim();
      isValid = phone.isNotEmpty && phone.length >= 10 && isPasswordValid;
    }

    // Only update if value changed to avoid redundant rebuilds
    if (isFormValid != isValid) {
      isFormValid = isValid;
    }
  }

  final LocalAuthentication auth = LocalAuthentication();

  final _canCheckBiometrics = false.obs;
  set canCheckBiometrics(value) => _canCheckBiometrics.value = value;
  bool get canCheckBiometrics => _canCheckBiometrics.value;

  final _isBiometricSetup = false.obs;
  set isBiometricSetup(value) => _isBiometricSetup.value = value;
  bool get isBiometricSetup => _isBiometricSetup.value;

  GoogleSignInAccount? _currentUser;

  var isBiometricEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    countryController.text = "+234";
    checkBiometricSupport();
    checkBiometricSetup();

    // Setup real-time validation workers
    _setupValidationWorkers();

    // plugin = FacebookLogin(debug: true);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      if (_currentUser != null) {
        _handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
  }

  String _contactText = '';
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    dev.log('user');
    dev.log(user.toString());
    _contactText = 'Loading contact info...';
    final response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    dev.log('response');
    dev.log(response.toString());
    if (response.statusCode != 200) {
      _contactText = 'People API gave a ${response.statusCode} '
          'response. Check logs for details.';
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    if (namedContact != null) {
      _contactText = 'I see you know $namedContact!';
    } else {
      _contactText = 'No contacts to display.';
    }
    dev.log('_contactText');
    dev.log(_contactText);
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  @override
  void onReady() {
    super.onReady();
    // Re-check biometric setup status when screen is ready
    checkBiometricSetup();
  }

  /// check if biometric is fully setup (enabled and has saved credentials)
  void checkBiometricSetup() {
    isBiometricEnabled.value = box.read('biometric_enabled') ?? true;
    final savedUsername = box.read('biometric_username');
    isBiometricSetup = (isBiometricEnabled.value == true &&
        savedUsername != null &&
        savedUsername.toString().isNotEmpty);
    dev.log(
        "Biometric setup status: $isBiometricSetup (enabled: ${isBiometricEnabled.value}, username saved: ${savedUsername != null}");
  }

  var apiService = DioApiService();

  final box = GetStorage();

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final secureStorage = const FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  final _isLoading = false.obs;
  set isLoading(value) => _isLoading.value = value;
  bool get isLoading => _isLoading.value;

  final _errorMessage = RxnString();
  set errorMessage(value) => _errorMessage.value = value;
  String? get errorMessage => _errorMessage.value;

  UserSignupData? pendingSignupData;
  final RxBool _isOtpSent = false.obs;
  set isOtpSent(value) => _isOtpSent.value = value;
  bool get isOtpSent => _isOtpSent.value;


  Future<void> login(
      BuildContext context, String username, String password) async {
    try {
      showLoadingDialog(context: context);
      isLoading = true;
      errorMessage = null;
      dev.log("Login attempt for user: $username");

      final result = await apiService.postrequest(
          "${ApiConstants.authUrlV2}/login",
          {"user_name": username, "password": password});

      Get.back();
      isLoading = false;

      result.fold(
        (failure) {
          errorMessage = failure.message;
          dev.log("Login failed: ${failure.message}");
          Get.snackbar("Error", errorMessage!,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        },
        (data) async {
          //--- trigger Password Save
          TextInput.finishAutofillContext();
          dev.log("Login response received: ${data.toString()}");
          final success = data['success'];
          if (success == 1 && data['token'] != null) {
            final token = data['token'];
            final transactionUrl = data['transaction_service'];
            final utilityUrl = data['ultility_service'];

            await box.write('token', token);
            await box.write('transaction_service_url', transactionUrl);
            await box.write('utility_service_url', utilityUrl);

            // save credentials for biometric login, the username is either phone number or email
            await saveBiometricCredentials(username, password);

            // refresh biometric setup status
            checkBiometricSetup();

            dev.log("Token saved, navigating to home...");

            await handleLoginSuccess();
          } else if (success == 2 && data['pin'] == true) {
            dev.log("PIN verification required");
            Get.toNamed(Routes.PIN_VERIFY, arguments: {"username": username});
          } else if (success == 2 ||
              data['message']?.toString().toLowerCase().contains("device") ==
                  true) {
            // new device verification required
            dev.log("New device verification required");
            Get.snackbar(
              "Verification Required",
              "Please check your email for the verification code",
              backgroundColor: AppColors.successBgColor,
              colorText: AppColors.textSnackbarColor,
            );
            Get.toNamed(Routes.NEW_DEVICE_VERIFY, arguments: {
              "username": username,
              "password": password,
            });
          } else {
            dev.log('Login error: ${data['message']}');
            Get.snackbar("Error", data['message'] ?? "Login failed",
                backgroundColor: AppColors.errorBgColor,
                colorText: AppColors.textSnackbarColor);
          }
        },
      );
    } catch (e) {
      Get.back();
      errorMessage = "Unexpected error: $e";
      dev.log('Login exception: $errorMessage');
      Get.snackbar("Error", errorMessage!,
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
    } finally {
      isLoading = false;
    }
  }

  Future<bool> fetchDashboard({bool force = false}) async {
    dev.log("LoginController fetchDashboard called, force: $force");

    isLoading = true;
    errorMessage = null;
    dev.log("Fetching dashboard from LoginController...");

    final result =
        await apiService.getrequest("${ApiConstants.authUrlV2}/dashboard");

    bool isSuccess = false;
    result.fold(
      (failure) {
        errorMessage = failure.message;
        dev.log("LoginController dashboard fetch failed: ${failure.message}");
        Get.snackbar("Error", failure.message,
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
      },
      (data) {
        StorageService.to.setDashboardData(data);
        if (force) {
          // Get.snackbar("Updated", "Dashboard refreshed", backgroundColor: AppColors.successBgColor, colorText: AppColors.textSnackbarColor);
        }
        isSuccess = true;
      },
    );

    isLoading = false;
    return isSuccess;
  }

  /// check if device supports biometrics
  Future<void> checkBiometricSupport() async {
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      dev.log("Biometric support available: $canCheckBiometrics");
    } catch (e) {
      dev.log("Error checking biometric support: $e");
      canCheckBiometrics = false;
    }
  }

  /// biometric login
  Future<void> biometricLogin(BuildContext context) async {
    try {
      if (!canCheckBiometrics) {
        Get.snackbar("Error", "Biometric authentication not available",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      // check if user has saved credentials for biometric
      final savedUsername = box.read('biometric_username');

      if (isBiometricEnabled.value != true) {
        Get.snackbar("Error",
            "Biometric login is disabled. Please enable it in Settings.",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      if (savedUsername == null || savedUsername.toString().isEmpty) {
        Get.snackbar("Error",
            "No saved biometric credentials. Please login normally first.",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      dev.log("Starting biometric authentication...");

      final bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to login',
        // options: const AuthenticationOptions(
        //   stickyAuth: true,
        //   biometricOnly: true,
        // ),
        // biometricOnly: true,
      );

      if (!authenticated) {
        dev.log("Biometric authentication failed");
        Get.snackbar("Error", "Authentication failed",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      dev.log(
          "Biometric authentication successful, logging in with saved credentials...");

      // Get saved password from secure storage
      final savedPassword = await secureStorage.read(key: 'biometric_password');

      if (savedPassword == null || savedPassword.isEmpty) {
        Get.snackbar("Error", "No saved password. Please login normally first.",
            backgroundColor: AppColors.errorBgColor,
            colorText: AppColors.textSnackbarColor);
        return;
      }

      // Use normal login method with saved credentials
      dev.log("Calling normal login with saved credentials...");
      await login(context, savedUsername.toString(), savedPassword);

      /* API-based biometric login (commented out)
      final result = await apiService.getrequest(
        "${ApiConstants.authUrlV2}/biometriclogin"
      );

      Get.back(); // close loader

      result.fold(
        (failure) {
          errorMessage = failure.message;
          dev.log("Biometric login failed: ${failure.message}");
          
          // If it's an unauthorized error, clear biometric data and ask user to login normally
          if (failure.message.contains("Unauthorized")) {
            box.remove('biometric_username');
            Get.snackbar(
              "Biometric Login Expired", 
              "Please log in again with your credentials to re-enable biometric login",
              backgroundColor: AppColors.errorBgColor, 
              colorText: AppColors.textSnackbarColor,
              duration: const Duration(seconds: 4),
            );
          } else {
            Get.snackbar("Error", errorMessage!, backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
          }
        },
        (data) async {
          dev.log("Biometric login response: ${data.toString()}");
          final success = data['success'];
          
          if (success == 1 && data['token'] != null) {
            final token = data['token'];
            final transactionUrl = data['transaction_service'];
            final utilityUrl = data['ultility_service'];

            await box.write('token', token);
            await box.write('transaction_service_url', transactionUrl);
            await box.write('utility_service_url', utilityUrl);
            dev.log("Biometric login successful, navigating to home...");
            
            await handleLoginSuccess();
          } else {
            errorMessage = data['message'] ?? "Biometric login failed";
            dev.log("Biometric login error: $errorMessage");
            Get.snackbar("Error", errorMessage!, backgroundColor: AppColors.errorBgColor, colorText: AppColors.textSnackbarColor);
          }
        },
      );
      */
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      errorMessage = "Biometric login error: $e";
      dev.log("Biometric login exception: $errorMessage");
      Get.snackbar("Error", "Authentication failed. Please try again.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
    } finally {
      isLoading = false;
    }
  }

  /// save username and password for biometric login after successful login
  Future<void> saveBiometricCredentials(
      String username, String password) async {
    try {
      // only save credentials if biometric is enabled in settings
      if (isBiometricEnabled.value == true) {
        // this is the username use for login e.g phone number or email
        await box.write('biometric_username', username);
        await secureStorage.write(key: 'biometric_password', value: password);
        dev.log("Biometric credentials saved for: $username");
      }
    } catch (e) {
      dev.log("Error saving biometric credentials: $e");
    }
  }

  /// navigate to home after successful login
  Future<void> handleLoginSuccess() async {
    // parallel fetch all post-auth data
    try {
      await Future.wait([
        ServiceStatusController.to.fetchServiceStatus(),
        fetchPaymentMethods(),
        fetchDashboard(force: true),
      ]);
    } catch (e) {
      dev.log('Error in post-login data fetch: $e', name: 'Login');
    }

    // non-blocking prefetches
    _prefetchCountries();
    _prefetchBanks();

    // flag to show news dialog on first home screen load
    await box.write('show_news_dialog', true);

    Get.offAllNamed(Routes.HOME_SCREEN);

    // try {
    //   final deepLinkService = Get.find<DeepLinkService>();
    //   deepLinkService.consumePendingDeepLink();
    // } catch (e) {
    //   dev.log('Error consuming pending deep link: $e', name: 'Login');
    // }
  }

  void _prefetchCountries() {
    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) return;

      // standalone fetch — write directly to storage without a controller
      _fetchAndCacheCountries(transactionUrl);
    } catch (e) {
      dev.log('Countries prefetch error: $e', name: 'Login');
    }
  }

  Future<void> _fetchAndCacheCountries(String transactionUrl) async {
    const cacheKey = 'cached_countries';
    const cacheTsKey = 'cached_countries_ts';
    const ttlHours = 24;

    // skip if still fresh
    final tsRaw = box.read(cacheTsKey);
    if (tsRaw != null) {
      final ts = DateTime.tryParse(tsRaw as String);
      if (ts != null &&
          DateTime.now().difference(ts).inHours < ttlHours &&
          box.read(cacheKey) != null) {
        dev.log('Countries cache still valid, skipping prefetch',
            name: 'Login');
        return;
      }
    }

    try {
      dev.log('Pre-fetching countries after login...', name: 'Login');
      final result =
          await apiService.getrequest('${transactionUrl}airtime/countries');

      result.fold(
        (failure) {
          dev.log('Countries prefetch failed: ${failure.message}',
              name: 'Login');
        },
        (data) {
          if (data['success'] == 1 && data['data'] is List) {
            final List<dynamic> raw = data['data'];
            // store minimal fields needed for ISO lookup
            final encoded = jsonEncode(raw
                .map((e) => {
                      'code': e['isoName'] ?? '',
                      'name': e['name'] ?? '',
                      'flag': e['flag'] ?? '',
                      'currency': e['currencyCode'] ?? '',
                      'callingCodes': e['callingCodes'] ?? [],
                    })
                .toList());
            box.write(cacheKey, encoded);
            box.write(cacheTsKey, DateTime.now().toIso8601String());
            dev.log('Countries cached after login (${raw.length} entries)',
                name: 'Login');
          }
        },
      );
    } catch (e) {
      dev.log('Countries prefetch exception: $e', name: 'Login');
    }
  }

  void _prefetchBanks() {
    try {
      final transactionUrl = box.read('transaction_service_url');
      if (transactionUrl == null || transactionUrl.isEmpty) return;
      _fetchAndCacheBanks(transactionUrl);
    } catch (e) {
      dev.log('Banks prefetch error: $e', name: 'Login');
    }
  }

  Future<void> _fetchAndCacheBanks(String transactionUrl) async {
    const cacheKey = 'cached_banks';
    const cacheTsKey = 'cached_banks_ts';
    const ttlHours = 24;

    // skip if still fresh
    final tsRaw = box.read(cacheTsKey);
    if (tsRaw != null) {
      final ts = DateTime.tryParse(tsRaw as String);
      if (ts != null &&
          DateTime.now().difference(ts).inHours < ttlHours &&
          box.read(cacheKey) != null) {
        dev.log('Banks cache still valid, skipping prefetch', name: 'Login');
        return;
      }
    }

    try {
      dev.log('Pre-fetching banks after login...', name: 'Login');
      final result = await apiService.getrequest('${transactionUrl}banklist');

      result.fold(
        (failure) {
          dev.log('Banks prefetch failed: ${failure.message}', name: 'Login');
        },
        (data) {
          // handle both response formats
          List<dynamic>? bankList;
          if (data['success'] == 1 && data['data'] != null) {
            bankList = data['data'];
          } else if (data['requestSuccessful'] == true &&
              data['responseBody'] != null) {
            bankList = data['responseBody'];
          }

          if (bankList != null) {
            final encoded = jsonEncode(bankList
                .map((e) => {
                      'name': e['name'] ?? '',
                      'code': e['code'] ?? '',
                      'ussdTemplate': e['ussdTemplate'],
                      'baseUssdCode': e['baseUssdCode'],
                    })
                .toList());
            box.write(cacheKey, encoded);
            box.write(cacheTsKey, DateTime.now().toIso8601String());
            dev.log('Banks cached after login (${bankList.length} entries)',
                name: 'Login');
          }
        },
      );
    } catch (e) {
      dev.log('Banks prefetch exception: $e', name: 'Login');
    }
  }

  Future<void> handleSignIn(BuildContext context) async {
    try {
      dev.log("Starting Google Sign-In...");
      final result = await _googleSignIn.signIn();
      dev.log("Google Sign-In successful: ${result?.displayName}");
      if (result != null) {
        socialLogin(context, result.email, result.displayName ?? "",
            result.photoUrl ?? "", result.id ?? "", "google");
      }
    } catch (error) {
      dev.log("Google Sign-In error: ${error.toString()}");
      if (error is PlatformException) {
        dev.log("PlatformException details: ${error.code} - ${error.message}");
      }
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<bool> fetchPaymentMethods() async {
    // only show loader if we have no cached data

    dev.log('Fetching payment methods configuration', name: 'PaymentConfig');

    final transactionUrl = storage.read('transaction_service_url');
    if (transactionUrl == null) {
      dev.log('Transaction URL not found, will retry when available', name: 'PaymentConfig');
      return false;
    }

    final result = await apiService.getrequest('${transactionUrl}payment-methods');

    bool isSuccess = false;

    result.fold(
          (failure) {
        dev.log('Failed to fetch payment methods', name: 'PaymentConfig', error: failure.message);

      },
          (data) {
        if (data['success'] == 1 && data['data'] != null) {
          dev.log('Payment methods fetched successfully', name: 'PaymentConfig');


          // Store payment method details (keys, etc.)
          if (data['data']['details'] != null) {
            final details = data['data']['details'] as Map<String, dynamic>;
            // Store Paystack public key
            if (details['paystack_public'] != null) {
              storage.write('paystack_public_key', details['paystack_public']);
              dev.log('Paystack public key found', name: 'PaymentConfig');
            }

            // Store other payment gateway keys if needed
            if (details['rave_public'] != null) {
              storage.write('rave_public_key', details['rave_public']);
            }
            if (details['rave_enckey'] != null) {
              storage.write('rave_encryption_key', details['rave_enckey']);
            }
            if (details['monnify_apikey'] != null) {
              storage.write('monnify_api_key', details['monnify_apikey']);
            }
            if (details['monnify_contractcode'] != null) {
              storage.write('monnify_contract_code', details['monnify_contractcode']);
            }

            dev.log('Payment gateway keys stored successfully', name: 'PaymentConfig');
          }

          // Cache the entire response
          storage.write('cached_payment_methods', data);
          isSuccess = true;
        } else {
          dev.log('Payment methods fetch failed', name: 'PaymentConfig', error: data['message']);
        }
      },
    );

    return isSuccess;
  }


  /// social login (facebook/google)
  Future<void> socialLogin(BuildContext context, String email, String name,
      String avatar, String accessToken, String source,
      {String? firebaseIdToken}) async {
    try {
      showLoadingDialog(context: context);
      isLoading = true;
      errorMessage = null;
      dev.log("Social login attempt for: $email from $source");

      final body = {
        "email": email,
        "name": name,
        "avatar": avatar,
        "access_token": accessToken,
        "source": source,
      };

      if (firebaseIdToken != null) {
        body["firebase_id_token"] = firebaseIdToken;
      }

      dev.log("Social Login Request Body: $body");

      final result = await apiService.postrequest(
        "${ApiConstants.authUrlV2}/sociallogin",
        body,
      );

      Get.back(); // close loader

      result.fold(
        (failure) {
          errorMessage = failure.message;
          dev.log("Social login failed: ${failure.message}");
          Get.snackbar("Error", errorMessage!,
              backgroundColor: AppColors.errorBgColor,
              colorText: AppColors.textSnackbarColor);
        },
        (data) async {
          dev.log("Social Login Success Response: $data");
          final success = data['success'];

          if (success == 1 && data['token'] != null) {
            final token = data['token'];
            final transactionUrl = data['transaction_service'];
            final utilityUrl = data['ultility_service'];

            await box.write('token', token);
            await box.write('transaction_service_url', transactionUrl);
            await box.write('utility_service_url', utilityUrl);

            dev.log("Social login successful, navigating to home...");
            await handleLoginSuccess();
          } else {
            errorMessage = data['message'] ?? "Social login failed";
            dev.log("Social login error: $errorMessage");
            Get.snackbar("Error", errorMessage!,
                backgroundColor: AppColors.errorBgColor,
                colorText: AppColors.textSnackbarColor);
          }
        },
      );
    } catch (e) {
      Get.back();
      errorMessage = "Social login error: $e";
      dev.log("Social login exception: $errorMessage");
      Get.snackbar("Error", "Authentication failed. Please try again.",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor);
    } finally {
      isLoading = false;
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      dev.log("Starting Google Sign In...");
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        dev.log("Google Sign In cancelled by user");
        Get.snackbar(
          "Cancelled",
          "Google Sign In cancelled",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
        return;
      }

      showLoadingDialog(context: context);
      isLoading = true;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      dev.log(
          "Google Auth tokens obtained. AccessToken: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}, IdToken: ${googleAuth.idToken != null ? 'Present' : 'Missing'}");
      dev.log("Google Auth successful, signing in to Firebase...");

      // Sign in to Firebase with the Google [UserCredential]
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      final String? firebaseIdToken = await user?.getIdToken();

      if (user != null) {
        dev.log(
            "Firebase Sign In successful. User Email: ${user.email}, UID: ${user.uid}");
        dev.log(
            "Firebase ID Token: ${firebaseIdToken != null ? 'Present' : 'Missing'}");
        Get.back(); // Close initial loader if needed (socialLogin opens another)

        await socialLogin(
          context,
          user.email ?? '',
          user.displayName ?? '',
          user.photoURL ?? '',
          googleAuth.accessToken ?? '',
          'google',
          firebaseIdToken: firebaseIdToken,
        );
      } else {
        Get.back();
        Get.snackbar(
          "Error",
          "Failed to retrieve user details from Google",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      isLoading = false;
      dev.log("Google Sign In Error: $e");
      Get.snackbar(
        "Error",
        "Google Sign In failed: $e",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

  Future<void> handleFacebookLogin(BuildContext context) async {
    try {
      dev.log("Starting Facebook Login...");
      final LoginResult fbResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (fbResult.status == LoginStatus.success) {
        dev.log(
            "Facebook Login Success. AccessToken: ${fbResult.accessToken!.tokenString}");
        showLoadingDialog(context: context);
        isLoading = true;

        final userData = await FacebookAuth.instance.getUserData();
        dev.log("Facebook User Data: $userData");

        final email = userData['email'] ?? '';
        final name = userData['name'] ?? '';
        final avatar = userData['picture']?['data']?['url'] ?? '';
        final accessToken = fbResult.accessToken!.tokenString;

        dev.log("Facebook Auth successful, signing in to Firebase...");

        // Sign in to Firebase with the Facebook credential to keep auth in sync
        final credential = FacebookAuthProvider.credential(accessToken);
        final firebaseUser =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final firebaseIdToken = await firebaseUser.user?.getIdToken();
        const source = 'facebook';

        if (firebaseUser.user != null) {
          dev.log(
              "Firebase Sign In successful. User Email: ${firebaseUser.user!.email}, UID: ${firebaseUser.user!.uid}");
          dev.log(
              "Firebase ID Token: ${firebaseIdToken != null ? 'Present' : 'Missing'}");
        }

        Get.back(); // close loader from showLoadingDialog

        await socialLogin(
          context,
          email,
          name,
          avatar,
          accessToken,
          source,
          firebaseIdToken: firebaseIdToken,
        );
        dev.log('Facebook login flow completed');
      } else if (fbResult.status == LoginStatus.cancelled) {
        dev.log("Facebook login cancelled by user");
        Get.snackbar(
          "Login Cancelled",
          "Facebook login was cancelled",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      } else {
        dev.log(
            "Facebook login failed with status: ${fbResult.status}, Message: ${fbResult.message}");
        Get.snackbar(
          "Error",
          "Facebook login failed: ${fbResult.message}",
          backgroundColor: AppColors.errorBgColor,
          colorText: AppColors.textSnackbarColor,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      isLoading = false;
      dev.log("Facebook Login Error: $e");
      Get.snackbar(
        "Error",
        "Facebook login error: $e",
        backgroundColor: AppColors.errorBgColor,
        colorText: AppColors.textSnackbarColor,
      );
    }
  }

}

GoogleSignIn _googleSignIn = GoogleSignIn(
  // clientId from Firebase console for this package
  clientId:
      '246642385825-khms495ln6n0tkgbdek3s155sv7vvemr.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
