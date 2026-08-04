import 'app_failure.dart';

/// Small validation helpers that can be shared by any feature.
abstract final class Validators {
  static String required(String value, {String fieldName = 'Value'}) {
    if (value.trim().isEmpty) {
      throw ValidationFailure('$fieldName is required.');
    }
    return value.trim();
  }

  static String email(String value) {
    final normalized = required(value, fieldName: 'Email');
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(normalized)) {
      throw const ValidationFailure('Enter a valid email address.');
    }
    return normalized;
  }
}
