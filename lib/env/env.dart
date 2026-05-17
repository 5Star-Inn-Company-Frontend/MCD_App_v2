import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  // sprint check sdk keys
  @EnviedField(varName: 'SPRINT_CHECK_API_KEY', obfuscate: true)
  static final String sprintCheckApiKey = _Env.sprintCheckApiKey;

  @EnviedField(varName: 'SPRINT_CHECK_ENCRYPTION_KEY', obfuscate: true)
  static final String sprintCheckEncryptionKey = _Env.sprintCheckEncryptionKey;

  // aes-256 encryption key — todo: migrate to backend-provided key post-auth
  @EnviedField(varName: 'AES_ENCRYPTION_KEY', obfuscate: true)
  static final String aesEncryptionKey = _Env.aesEncryptionKey;
}
