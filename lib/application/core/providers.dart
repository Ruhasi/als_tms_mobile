import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app_config.dart';

/// Override this at the application boundary with environment-specific values.
final appConfigProvider = Provider<AppConfig>(
  (ref) =>
      throw UnimplementedError('Override appConfigProvider in ProviderScope.'),
);
