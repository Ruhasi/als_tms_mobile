import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'application/core/app_config.dart';
import 'application/core/providers.dart';
import 'presentation/core/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(apiBaseUrl: 'https://api.example.com'),
        ),
      ],
      child: App(),
    ),
  );
}
