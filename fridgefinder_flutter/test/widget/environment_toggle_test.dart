import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgefinder_app/src/core/providers/environment_provider.dart';

void main() {
  group('Environment toggle', () {
    Widget buildTestWidget(ApiEnvironment currentEnv) {
      return ProviderScope(
        overrides: [
          environmentProvider.overrideWithValue(currentEnv),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              final env = ref.watch(environmentProvider);
              return Scaffold(
                body: Column(
                  children: [
                    _EnvOption(
                      key: const Key('env_prod'),
                      title: 'Production',
                      env: ApiEnvironment.prod,
                      isSelected: env == ApiEnvironment.prod,
                    ),
                    _EnvOption(
                      key: const Key('env_dev'),
                      title: 'Development',
                      env: ApiEnvironment.dev,
                      isSelected: env == ApiEnvironment.dev,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    testWidgets('tapping already-selected env does nothing', (tester) async {
      await tester.pumpWidget(buildTestWidget(ApiEnvironment.prod));

      await tester.tap(find.byKey(const Key('env_prod')));
      await tester.pumpAndSettle();

      expect(find.text('Restart Required'), findsNothing);
    });

    testWidgets('tapping different env shows restart dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget(ApiEnvironment.prod));

      await tester.tap(find.byKey(const Key('env_dev')));
      await tester.pumpAndSettle();

      expect(find.text('Restart Required'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
    });

    testWidgets('cancel dismisses dialog without changing env', (tester) async {
      await tester.pumpWidget(buildTestWidget(ApiEnvironment.prod));

      await tester.tap(find.byKey(const Key('env_dev')));
      await tester.pumpAndSettle();

      expect(find.text('Restart Required'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Restart Required'), findsNothing);
      // Still shows prod as selected
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}

class _EnvOption extends StatelessWidget {
  final String title;
  final ApiEnvironment env;
  final bool isSelected;

  const _EnvOption({
    super.key,
    required this.title,
    required this.env,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isSelected
          ? null
          : () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Restart Required'),
                  content: const Text(
                    'Switching Firebase environment requires an app restart. '
                    'All Firebase services (Auth, Database, Messaging) will switch.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(title),
            if (isSelected) const Icon(Icons.check_circle),
          ],
        ),
      ),
    );
  }
}
