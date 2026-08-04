import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/app_state/app_state.dart';
import '../../application/app_state/app_state_notifier_provider.dart';
import 'routing/app_router.dart';
import 'theme/tms_theme.dart';

/// The intentionally empty application shell for new projects.
///
/// Replace [home] with the first feature route when the project starts.
class App extends HookConsumerWidget {
  App({super.key}) : _router = AppRouter();

  final AppRouter _router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateNotifierProvider);

    return ScreenUtilPlusInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, widget) {
        return MaterialApp.router(
          title: 'ALS TMS',
          debugShowCheckedModeBanner: false,
          locale: Locale(appState.localeCode),
          themeMode: switch (appState.themeMode) {
            AppThemeMode.system => ThemeMode.system,
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
          },
          theme: buildTmsTheme(),
          routerConfig: _router.config(),
        );
      }
    );
  }
}
