import 'app_failure.dart';

/// Contract for secure key/value persistence.
abstract interface class ILocalRepository {
  Future<String?> read(String key);

  Future<Map<String, String>> readAll();

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<void> deleteAll();
}

/// Converts platform persistence errors into domain-safe failures.
typedef StorageErrorMapper =
    StorageFailure Function(Object error, StackTrace stackTrace);
