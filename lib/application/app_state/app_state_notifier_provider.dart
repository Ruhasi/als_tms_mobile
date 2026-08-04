import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_state.dart';
import 'app_state_notifier.dart';

/// The single source of truth for application-wide session and preferences.
final appStateNotifierProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

/// Select the token independently so API clients do not rebuild for unrelated
/// app-state changes such as locale or theme selection.
final accessTokenProvider = Provider<String?>(
  (ref) =>
      ref.watch(appStateNotifierProvider.select((state) => state.accessToken)),
);
