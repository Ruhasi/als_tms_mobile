import 'package:dio/dio.dart';

import 'session_storage.dart';

class TokenRefreshService {
  TokenRefreshService(this._dio, this._sessionStorage);

  final Dio _dio;
  final SessionStorage _sessionStorage;

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _sessionStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/mobile/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'skipAuthToken': true, 'skipAuthRefresh': true}),
    );
    final data = response.data;
    if (data == null || data['success'] != true) return null;

    final accessToken = data['accessToken'] as String? ?? '';
    if (accessToken.isEmpty) return null;

    await _sessionStorage.saveRefreshedTokens(
      accessToken: accessToken,
      refreshToken: data['refreshToken'] as String?,
    );
    return accessToken;
  }
}
