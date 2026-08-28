import 'package:dartz/dartz.dart';

import '../../domain/auth/login_session.dart';
import '../../domain/auth/mobile_user_profile.dart';
import '../../domain/core/app_failure.dart';
import '../api_helpers/api_client.dart';

class AuthRepository {
  const AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Either<NetworkFailure, LoginSession>> login({
    required String username,
    required String password,
    required String recaptchaToken,
  }) async {
    final result = await _apiClient.request<LoginSession>(
      path: '/api/v1/mobile/login',
      method: HttpMethod.post,
      data: {
        'username': username,
        'password': password,
        'recaptchaToken': recaptchaToken,
      },

      decode: (json) {
        final response = json as Map<String, dynamic>;
        if (response['status'] != "success") {
          throw Exception('Sign in failed. Please check your credentials.');
        }
        return LoginSession.fromJson(response['data']);
      },
    );

    return switch (result) {
      ApiSuccess(data: final session) => right(session),
      ApiError(failure: final failure) => left(failure),
    };
  }

  Future<Either<NetworkFailure, MobileUserProfile>> currentProfile() async {
    final result = await _apiClient.request<MobileUserProfile>(
      path: '/api/v1/mobile/me',
      decode: (json) {
        final body = json as Map<String, dynamic>;
        return MobileUserProfile.fromJson(body['data'] as Map<String, dynamic>);
      },
    );
    return switch (result) {
      ApiSuccess(data: final profile) => right(profile),
      ApiError(failure: final failure) => left(failure),
    };
  }
}
