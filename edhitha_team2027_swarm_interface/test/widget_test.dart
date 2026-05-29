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

    // pumpAndSettle drains flutter_animate timers (fadeIn/scaleXY 200 ms).
    // Timeout > longest animation so it always completes.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // AppBar title must be present.
    expect(find.text('SWARM INTERFACE'), findsOneWidget);
  });
}
