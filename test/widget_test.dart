import 'dart:ui';

import 'package:edhitha_team2027_swarm_interface/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SwarmApp renders SWARM INTERFACE title', (
    WidgetTester tester,
  ) async {
    // Use a tall viewport so all widgets fit without overflow.
    await tester.binding.setSurfaceSize(const Size(400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(child: SwarmApp()),
    );

    // Wait for splash to finish (3 seconds + 500ms fade) without pumpAndSettle (infinite animations)
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));

    // AppBar title must be present on VoiceDebugScreen
    expect(find.text('SWARM INTERFACE'), findsOneWidget);
  });
}
