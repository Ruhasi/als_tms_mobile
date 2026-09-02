import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/app_state/app_state_notifier_provider.dart';
import '../../application/core/providers.dart';
import '../../domain/core/app_failure.dart';
import '../auth/session_storage.dart';
import '../auth/token_refresh_service.dart';
import '../core/local_repository.dart';

enum HttpMethod { get, post, put, patch, delete }

/// Result of an HTTP operation. Keep transport failures out of feature code.
sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data, {required this.statusCode, this.headers});

  final T data;
  final int statusCode;
  final Headers? headers;
}

final class ApiError<T> extends ApiResult<T> {
  const ApiError(this.failure);

  final NetworkFailure failure;
}

/// Reusable Dio wrapper with configuration and authentication injected by
/// Riverpod. Feature repositories provide their own request and response DTOs.
final class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResult<T>> request<T>({
    required String path,
    required T Function(Object? json) decode,
    HttpMethod method = HttpMethod.get,
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.request<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: Options(method: method.name.toUpperCase()),
      );
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        return ApiError(
          NetworkFailure(
            'Request failed with status $statusCode.',
            statusCode: statusCode,
          ),
        );
      }
      return ApiSuccess(
        decode(response.data),
        statusCode: statusCode,
        headers: response.headers,
      );
    } on DioException catch (error, stackTrace) {
      return ApiError(
        NetworkFailure(
          _messageFor(error),
          statusCode: error.response?.statusCode,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (error, stackTrace) {
      log(
        'Unable to process the server response.',
        name: 'ApiClient',
        error: error,
        stackTrace: stackTrace,
      );
      return ApiError(
        NetworkFailure(
          'Unable to process the server response.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<ApiResult<void>> download({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      final statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 300
          ? ApiSuccess(null, statusCode: statusCode, headers: response.headers)
          : ApiError(
              NetworkFailure(
                'Download failed with status $statusCode.',
                statusCode: statusCode,
              ),
            );
    } on DioException catch (error, stackTrace) {
      return ApiError(
        NetworkFailure(
          _messageFor(error),
          statusCode: error.response?.statusCode,
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  static String _messageFor(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.sendTimeout => 'Sending the request timed out.',
      DioExceptionType.receiveTimeout => 'Receiving the response timed out.',
      DioExceptionType.connectionError => 'Unable to connect to the server.',
      DioExceptionType.cancel => 'Request was cancelled.',
      _ => 'The request could not be completed.',
    };
  }
}

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final sessionStorage = SessionStorage(
    LocalRepository(const FlutterSecureStorage()),
  );
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: const {'Accept': 'application/json'},
    ),
  );
  final tokenRefreshService = TokenRefreshService(dio, sessionStorage);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.extra['skipAuthToken'] != true) {
          final token = ref.read(accessTokenProvider);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final request = error.requestOptions;
        final isLoginRequest = request.path == '/api/v1/mobile/login';
        final wasRetried = request.extra['wasRetried'] == true;
        final skipAuthRefresh = request.extra['skipAuthRefresh'] == true;
        if (error.response?.statusCode != 401 ||
            isLoginRequest ||
            wasRetried ||
            skipAuthRefresh) {
          handler.next(error);
          return;
        }

        try {
          final accessToken = await tokenRefreshService.refreshAccessToken();
          if (accessToken == null) {
            ref.read(appStateNotifierProvider.notifier).clearSession();
            handler.next(error);
            return;
          }

          ref
              .read(appStateNotifierProvider.notifier)
              .setAccessToken(accessToken);
          final response = await dio.fetch<Object?>(
            request.copyWith(
              headers: {
                ...request.headers,
                'Authorization': 'Bearer $accessToken',
              },
              extra: {...request.extra, 'wasRetried': true},
            ),
          );
          handler.resolve(response);
        } on Object catch (refreshError, refreshStackTrace) {
          log(
            'Access-token refresh failed.',
            name: 'ApiClient',
            error: refreshError,
            stackTrace: refreshStackTrace,
          );
          await sessionStorage.clear();
          ref.read(appStateNotifierProvider.notifier).clearSession();
          handler.next(error);
        }
      },
    ),
  );
  if (config.enableNetworkLogs) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});
