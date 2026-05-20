import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// Application entry point.
///
/// Wraps [SwarmApp] in [ProviderScope] so all Riverpod providers are available
/// throughout the widget tree.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: SwarmApp(),
    ),
  );
}
