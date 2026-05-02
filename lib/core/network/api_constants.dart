import 'package:mcd/env/env.dart';

class ApiConstants {
  static const String baseUrl = 'https://test.mcd.5starcompany.com.ng/api/v2';
  static const String authUrlV2 = 'https://auth.mcd.5starcompany.com.ng/api/v2';
  static const String temporaryTransUrl = 'https://transactiontest.mcd.5starcompany.com.ng';

  // sourced from .env via envied — obfuscated at compile time
  static String get encryptionKey => Env.aesEncryptionKey;
  static const String encryptionIv = '';

  static String get sprintCheckApiKey => Env.sprintCheckApiKey;
  static String get sprintCheckEncryptionKey => Env.sprintCheckEncryptionKey;

  static const Duration apiTimeout = Duration(seconds: 120);
}
