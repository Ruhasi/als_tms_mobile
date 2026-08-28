import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../infrastructure/api_helpers/api_client.dart';
import '../../infrastructure/auth/auth_repository.dart';
import '../../infrastructure/auth/recaptcha_service.dart';
import '../../infrastructure/auth/session_storage.dart';
import '../../infrastructure/core/local_repository.dart';

final recaptchaServiceProvider = Provider<RecaptchaService>(
  (ref) => RecaptchaService(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final sessionStorageProvider = Provider<SessionStorage>(
  (ref) => SessionStorage(LocalRepository(const FlutterSecureStorage())),
);

final mobileUserProfileProvider = FutureProvider(
  (ref) => ref.read(authRepositoryProvider).currentProfile(),
);
