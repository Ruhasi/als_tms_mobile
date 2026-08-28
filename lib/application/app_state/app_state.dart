import '../../domain/auth/mobile_user_profile.dart';

/// The application-wide state that is independent of any feature.
///
/// Keep this limited to session and display preferences. Feature-specific
/// state belongs in its own application module.
class AppState {
  const AppState({
    this.isInitialized = false,
    this.accessToken,
    this.userProfile,
    this.localeCode = 'en',
    this.themeMode = AppThemeMode.system,
  });

  final bool isInitialized;
  final String? accessToken;
  final MobileUserProfile? userProfile;
  final String localeCode;
  final AppThemeMode themeMode;

  bool get isAuthenticated => accessToken?.isNotEmpty ?? false;

  AppState copyWith({
    bool? isInitialized,
    Object? accessToken = _unset,
    Object? userProfile = _unset,
    String? localeCode,
    AppThemeMode? themeMode,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      accessToken: identical(accessToken, _unset)
          ? this.accessToken
          : accessToken as String?,
      userProfile: identical(userProfile, _unset)
          ? this.userProfile
          : userProfile as MobileUserProfile?,
      localeCode: localeCode ?? this.localeCode,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

enum AppThemeMode { system, light, dark }

const _unset = Object();
