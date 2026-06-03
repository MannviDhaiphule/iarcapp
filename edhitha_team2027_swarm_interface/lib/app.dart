import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/voice_command/presentation/screens/voice_debug_screen.dart';

/// Root application widget.
///
/// Wraps the widget tree in [ProviderScope] (Riverpod) and applies [AppTheme].
class SwarmApp extends StatelessWidget {
  /// Creates a [SwarmApp].
  const SwarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swarm Interface',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (_) => const VoiceDebugScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
