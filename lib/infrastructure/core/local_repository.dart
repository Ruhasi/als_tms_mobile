import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/core/i_local_repository.dart';

/// Secure-storage implementation of the shared local persistence contract.
final class LocalRepository implements ILocalRepository {
  const LocalRepository(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}
