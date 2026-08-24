import '../core/local_repository.dart';
import '../../domain/auth/login_session.dart';

class SessionStorage {
  SessionStorage(this._repository);

  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  final LocalRepository _repository;

  Future<void> save(LoginSession session) async {
    await _repository.write(accessTokenKey, session.accessToken);
    await _repository.write(refreshTokenKey, session.refreshToken);
  }

  Future<String?> readRefreshToken() => _repository.read(refreshTokenKey);

  Future<void> saveAccessToken(String accessToken) =>
      _repository.write(accessTokenKey, accessToken);

  Future<void> saveRefreshedTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _repository.write(refreshTokenKey, refreshToken);
    }
  }

  Future<void> clear() async {
    await _repository.delete(accessTokenKey);
    await _repository.delete(refreshTokenKey);
  }
}
