import 'dart:developer';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_state/app_state_notifier_provider.dart';
import 'auth_providers.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) {
      state = AsyncError(
        Exception('Enter your username and password.'),
        StackTrace.current,
      );
      return false;
    }

    state = const AsyncLoading();
    try {
      final recaptchaToken = await ref
          .read(recaptchaServiceProvider)
          .createLoginToken();
      final loginResult = await ref
          .read(authRepositoryProvider)
          .login(
            username: username.trim(),
            password: password,
            recaptchaToken: recaptchaToken,
          );

      return loginResult.fold(
        (failure) {
          state = AsyncError(failure, failure.stackTrace ?? StackTrace.current);
          return false;
        },
        (session) async {
          if (session.accessToken.isEmpty || session.refreshToken.isEmpty) {
            state = AsyncError(
              Exception('The server returned an incomplete session.'),
              StackTrace.current,
            );
            return false;
          }

          await ref.read(sessionStorageProvider).save(session);
          log('session: ${session.accessToken}');
          ref
              .read(appStateNotifierProvider.notifier)
              .setAccessToken(session.accessToken);
          state = const AsyncData(null);
          return true;
        },
      );
    } catch (error, stackTrace) {
      log(
        'Sign-in failed.',
        name: 'AuthController',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
