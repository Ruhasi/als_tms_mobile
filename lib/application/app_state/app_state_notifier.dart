import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_state.dart';

/// Mutates only the small set of values that are truly global to the app.
final class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => const AppState();

  void markInitialized() {
    state = state.copyWith(isInitialized: true);
  }

  void setAccessToken(String token) {
    state = state.copyWith(accessToken: token);
  }

  void clearSession() {
    state = state.copyWith(accessToken: null);
  }

  void setLocale(String localeCode) {
    state = state.copyWith(localeCode: localeCode);
  }

  void setThemeMode(AppThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
  }
}
