import 'dart:io';

import 'package:recaptcha_enterprise_flutter/recaptcha_enterprise_flutter.dart';

/// Generates a fresh reCAPTCHA Enterprise token for each sign-in attempt.
///
/// Replace the placeholder keys with the Android and iOS keys from Google Cloud
/// before testing on a device.
class RecaptchaService {
  static const _androidSiteKey = '6LfkLo8tAAAAAGzRZTFoYADKtCsGklsQ8cCt3UMU';
  static const _iosSiteKey = '6LeIBI8tAAAAAOZtoNaLjSTTUq2hNa0cKj74JUcZ';

  RecaptchaClient? _client;

  Future<String> createLoginToken() async {
    _client ??= await Recaptcha.fetchClient(_siteKey);
    return _client!.execute(RecaptchaAction.custom('USER_ACTION'));
  }

  String get _siteKey {
    if (Platform.isAndroid) return _androidSiteKey;
    if (Platform.isIOS) return _iosSiteKey;
    throw UnsupportedError(
      'reCAPTCHA Enterprise supports Android and iOS only.',
    );
  }
}
