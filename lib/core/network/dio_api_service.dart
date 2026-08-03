import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dartz/dartz.dart' hide State;
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mcd/core/import/imports.dart';
import 'package:mcd/core/network/api_constants.dart';
import 'package:mcd/core/network/errors.dart';
import 'package:mcd/core/utils/aes_helper.dart';
import 'package:mcd/core/services/device_info_service.dart';

class DioApiService {
  final Dio _dio;
  final AESHelper _aes = AESHelper(ApiConstants.encryptionKey);
  final GetStorage _storage = GetStorage();

  // Default timeout duration (30 seconds)
  static const Duration defaultTimeout = Duration(seconds: 60);

  DioApiService() : _dio = Dio() {
    dev.log('[DioApiService] Initializing API service');
    _dio.options.baseUrl = ApiConstants.authUrlV2;
    _dio.options.connectTimeout = defaultTimeout;
    _dio.options.receiveTimeout = defaultTimeout;
    _dio.options.validateStatus = (status) {
      // Allow all status codes to be handled in the success block
      return status != null;
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_isShowingSessionExpiredDialog) {
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: "Session Expired",
            ),
          );
        }

        String? tokenToCheck;
        final authHeader = options.headers["Authorization"] as String?;
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
          final extracted = authHeader.substring(7);
          if (extracted != "null" && extracted.isNotEmpty) {
            tokenToCheck = extracted;
          }
        }
        
        if (tokenToCheck == null) {
          final storedToken = _storage.read("token");
          if (storedToken != null && storedToken.toString().isNotEmpty) {
            tokenToCheck = storedToken;
          }
        }

        if (tokenToCheck != null && _isTokenExpired(tokenToCheck)) {
          _handleUnauthorized();
          return handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: "Token Expired locally",
            ),
          );
        }

        return handler.next(options);
      },
    ));

    dev.log(
        '[DioApiService] ONINIT CALLED! Setting timeout to ${defaultTimeout.inSeconds} seconds.');
  }

  // sends get request and decrypts the encrypted response
  Future<Either<Failure, Map<String, dynamic>>> getrequest(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: query,
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawBody = response.data.toString();
        return decryptjson(rawBody);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized"));
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log('[DioApiService] GET request failed', error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log('[DioApiService] GET request failed', error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  // sends get request and returns plain json response
  Future<Either<Failure, Map<String, dynamic>>> getJsonRequest(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: query,
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data is String ? jsonDecode(response.data) : response.data;
        return Right(data);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized. Please log in again."));
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log("getJsonRequest failed", error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log("getJsonRequest failed", error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  // encrypts request body, sends post request, and decrypts the encrypted response
  Future<Either<Failure, Map<String, dynamic>>> postrequest(
    String url,
    dynamic body,
  ) async {
    try {
      final response = await _dio.post(
        url,
        data: encryptjson(body),
        options: Options(headers: _getHeaders()),
      );
      if (response.statusCode == 200 && response.data != null) {
        try {
          final rawBody = response.data.toString();
          return decryptjson(rawBody);
        } catch (decryptError) {
          dev.log('[DioApiService] Decryption failed', error: decryptError);
          return Left(ServerFailure(
              "Failed to process server response. Please try again."));
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized"));
      } else if (response.statusCode == 400 ||
          response.statusCode == 404 ||
          response.statusCode == 422) {
        // Handle client errors - try to extract message from response
        try {
          if (response.data != null && response.data.toString().isNotEmpty) {
            final rawBody = response.data.toString();
            final decrypted = decryptjson(rawBody);
            return decrypted.fold(
              (failure) => Left(failure),
              (data) {
                final message = data['message'] ??
                    data['error'] ??
                    'Invalid request. Please check your input.';
                return Left(ServerFailure(message));
              },
            );
          } else {
            return Left(ServerFailure(
                "Invalid phone number or request data. Please verify and try again."));
          }
        } catch (e) {
          return Left(ServerFailure(
              "Invalid phone number or request data. Please verify and try again."));
        }
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log('[DioApiService] POST request failed', error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log('[DioApiService] POST request failed', error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  // sends post request with plain json body and returns plain json response
  Future<Either<Failure, Map<String, dynamic>>> postJsonRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        url,
        data: jsonEncode(body),
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data is String ? jsonDecode(response.data) : response.data;
        dev.log('postJsonRequest response data: $data', name: 'DioApiService');
        return Right(data);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized. Please log in again."));
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log("postJsonRequest failed", error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log("postJsonRequest failed", error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  // encrypts request body, sends put request, and decrypts the encrypted response
  Future<Either<Failure, Map<String, dynamic>>> putrequest(
    String url,
    dynamic body,
  ) async {
    try {
      final response = await _dio.put(
        url,
        data: encryptjson(body),
        options: Options(headers: _getHeaders()),
      );
      if (response.statusCode == 200 && response.data != null) {
        final rawBody = response.data.toString();
        return decryptjson(rawBody);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized"));
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log('[DioApiService] PUT request failed', error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log('[DioApiService] PUT request failed', error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  // sends put request with plain json body and returns plain json response
  Future<Either<Failure, Map<String, dynamic>>> putJsonRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put(
        url,
        data: jsonEncode(body),
        options: Options(headers: _getHeaders()),
      );
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data is String ? jsonDecode(response.data) : response.data;
        return Right(data);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized. Please log in again."));
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log("putJsonRequest failed", error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log("putJsonRequest failed", error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> patchrequest(
    String url,
    dynamic body,
  ) async {
    try {
      final response = await _dio.patch(
        url,
        data: encryptjson(body),
        options: Options(headers: _getHeaders()),
      );
      if (response.statusCode == 200 && response.data != null) {
        final rawBody = response.data.toString();
        return decryptjson(rawBody);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized"));
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log('[DioApiService] PATCH request failed', error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log('[DioApiService] PATCH request failed', error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> deleterequest(
      String url) async {
    try {
      final response = await _dio.delete(
        url,
        options: Options(headers: _getHeaders()),
      );
      if (response.statusCode == 200 && response.data != null) {
        final rawBody = response.data.toString();
        return decryptjson(rawBody);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
        return Left(ServerFailure("Unauthorized"));
      } else {
        return Left(ServerFailure("Request failed: ${response.statusMessage}"));
      }
    } on DioError catch (e) {
      dev.log('[DioApiService] DELETE request failed', error: e);
      return Left(ServerFailure(_handleDioError(e)));
    } catch (e) {
      dev.log('[DioApiService] DELETE request failed', error: e);
      return Left(ServerFailure("An unexpected error occurred: $e"));
    }
  }

  // returns headers with authorization token for api requests
  Map<String, String> _getHeaders() {
    final deviceInfoService = DeviceInfoService();
    return {
      "Content-Type": "application/json",
      "device": deviceInfoService.deviceString,
      "version": deviceInfoService.version,
      "Authorization": "Bearer ${_storage.read("token")}",
    };
  }

  // flag to prevent multiple dialogs
  static bool _isShowingSessionExpiredDialog = false;

  // clears token and redirects to login screen on unauthorized response
  void _handleUnauthorized() {
    if (_isShowingSessionExpiredDialog) return;

    _isShowingSessionExpiredDialog = true;
    _storage.remove("token");

    if (Get.currentRoute != Routes.LOGIN_SCREEN) {
      _showSessionExpiredCountdown();
    } else {
      _isShowingSessionExpiredDialog = false;
    }
  }

  // decodes JWT token to check if it's expired
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String resp = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = jsonDecode(resp);
      
      if (payloadMap.containsKey('exp')) {
        // JWT exp is in seconds, DateTime.now().millisecondsSinceEpoch is in ms
        final expValue = payloadMap['exp'];
        int expInSeconds = 0;
        
        if (expValue is int) {
          expInSeconds = expValue;
        } else if (expValue is double) {
          expInSeconds = expValue.toInt();
        } else if (expValue is String) {
          expInSeconds = int.tryParse(expValue) ?? 0;
        }

        if (expInSeconds > 0) {
          final exp = expInSeconds * 1000;
          // adding a 5-second buffer to prevent edge cases
          if (DateTime.now().millisecondsSinceEpoch >= exp - 5000) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      dev.log('[DioApiService] Error parsing JWT token', error: e);
      return false;
    }
  }

  // shows session expired dialog with countdown
  void _showSessionExpiredCountdown() {
    final countdown = 5.obs;
    Timer? timer;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      countdown.value--;
      if (countdown.value <= 0) {
        t.cancel();
        Get.back(); // close dialog
        _isShowingSessionExpiredDialog = false;
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      }
    });

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_off_outlined,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Session Expired',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.manRope,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your session has expired. You will be logged out and redirected to login.',
                style: TextStyle(fontSize: 14, color: Colors.black54, fontFamily: AppFonts.manRope),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    'Redirecting in ${countdown.value}s...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                      fontFamily: AppFonts.manRope,
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                timer?.cancel();
                Get.back();
                _isShowingSessionExpiredDialog = false;
                Get.offAllNamed(Routes.LOGIN_SCREEN);
              },
              child:TextSemiBold('Login Now'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  // converts dio errors into user-friendly error messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet connection and try again.";
      case DioExceptionType.connectionError:
        return "No internet connection. Please check your network settings.";
      case DioExceptionType.badResponse:
        if (e.response != null) {
          return "Request failed: ${e.response?.statusCode} ${e.response?.statusMessage}";
        }
        return "Bad response from server.";
      case DioExceptionType.cancel:
        return "Request was cancelled.";
      case DioExceptionType.unknown:
        if (e.message != null && e.message!.contains('SocketException')) {
          return "No internet connection. Please check your network settings.";
        }
        return "An unexpected error occurred. Please try again.";
      default:
        return "Request failed: ${e.message}";
    }
  }

  // encrypts json data with aes encryption and returns base64 encoded string
  String encryptjson(dynamic toencrypt) {
    final payload = jsonEncode(toencrypt);
    final length = payload.length;
    final phpSerialized = 's:$length:"$payload";';

    final iv = IV.fromSecureRandom(12);
    final encrypted = _aes.encryptText(phpSerialized, iv);

    final encryptedBytes = encrypted.bytes;
    final cipherText = encryptedBytes.sublist(0, encryptedBytes.length - 16);
    final tag = encryptedBytes.sublist(encryptedBytes.length - 16);

    final body = {
      "iv": base64Encode(iv.bytes),
      "value": base64Encode(cipherText),
      "mac": "",
      "tag": base64Encode(tag),
    };

    final bodyBase64 = base64Encode(utf8.encode(jsonEncode(body)));
    return bodyBase64;
  }

  // decrypts base64 encoded encrypted response and returns json data
  Right<Failure, Map<String, dynamic>> decryptjson(String rawBody) {
    // dev.log("Raw login body: $rawBody");

    // Step 1: Decode from base64
    final decodedJson = utf8.decode(base64Decode(rawBody));
    // dev.log("After base64 decode: $decodedJson");

    // Step 2: Parse JSON with iv, value, tag
    final Map<String, dynamic> encryptedMap = jsonDecode(decodedJson);

    // Step 3: Rebuild Encrypted object
    final cipherText = base64Decode(encryptedMap["value"]);
    final tag = base64Decode(encryptedMap["tag"]);
    final combined = Uint8List.fromList([...cipherText, ...tag]);

    final iv = IV.fromBase64(encryptedMap["iv"]);
    final encrypted = Encrypted(combined);

    // Step 4: Decrypt using AESHelper
    final decryptedString = _aes.decryptText(encrypted, iv);
    // dev.log("Decrypted response: $decryptedString");

    // Step 5: Strip PHP serialization
    final cleanJson = _stripPhpSerialized(decryptedString);
    // dev.log("Clean JSON: $cleanJson");

    // Step 6: Parse actual API response
    final Map<String, dynamic> data = jsonDecode(cleanJson);
    return Right(data);
  }

  // removes php serialization wrapper from decrypted string
  String _stripPhpSerialized(String decrypted) {
    final regex = RegExp(r's:\d+:"(.*)";$', dotAll: true);
    final match = regex.firstMatch(decrypted);
    if (match != null) {
      return match.group(1)!; // inner JSON string
    }
    throw FormatException("Invalid serialized format");
  }
}
