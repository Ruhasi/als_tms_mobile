import 'package:dio/dio.dart';

import 'session_storage.dart';

class TokenRefreshService {
  TokenRefreshService(this._dio, this._sessionStorage);

  final Dio _dio;
  final SessionStorage _sessionStorage;
  Future<String?>? _refreshInFlight;

  Future<String?> refreshAccessToken() => _refreshInFlight ??= _refresh()
      .whenComplete(() => _refreshInFlight = null);

  Future<String?> _refresh() async {
    final refreshToken = await _sessionStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/mobile/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(
        contentType: Headers.jsonContentType,
        extra: {'skipAuthToken': true, 'skipAuthRefresh': true},
      ),
    );
    final body = response.data;
    if (body == null || body['status'] != 'success') return null;
    final data = body['data'] as Map<String, dynamic>? ?? body;

    final accessToken =
        data['accessToken'] as String? ?? data['access_token'] as String? ?? '';
    if (accessToken.isEmpty) return null;

    await _sessionStorage.saveRefreshedTokens(
      accessToken: accessToken,
      refreshToken:
          data['refreshToken'] as String? ?? data['refresh_token'] as String?,
    );
    return accessToken;
  }
}
