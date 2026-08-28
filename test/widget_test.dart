import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:nexus_360/application/core/app_config.dart';
import 'package:nexus_360/application/core/providers.dart';
import 'package:nexus_360/presentation/core/app.dart';

void main() {
  testWidgets('renders the TMS sign-in screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(apiBaseUrl: 'https://api.example.com'),
          ),
        ],
        child: App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ALS TMS'), findsOneWidget);
  });
}
