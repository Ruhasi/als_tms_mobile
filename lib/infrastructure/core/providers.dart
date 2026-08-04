import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/core/i_local_repository.dart';
import 'local_repository.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final localRepositoryProvider = Provider<ILocalRepository>(
  (ref) => LocalRepository(ref.watch(secureStorageProvider)),
);
