import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/command_ids.dart';
import '../../domain/intent_parser.dart';
import 'asr_provider.dart';
import 'dispatch_provider.dart';

/// Derived read-only provider that parses the latest ASR transcript into a [CommandId].
///
/// Recomputes automatically whenever [asrProvider]'s transcript changes.
final intentProvider = Provider<CommandId>((ref) {
  final transcript = ref.watch(asrProvider.select((s) => s.transcript));
  return IntentParser().parse(transcript);
});

/// Bridges [intentProvider] changes into [dispatchProvider].
///
/// Must be watched from a widget to activate the subscription.
final intentDispatchBridgeProvider = Provider<void>((ref) {
  ref.listen<CommandId>(intentProvider, (_, next) {
    ref.read(dispatchProvider.notifier).onIntentChanged(next);
    // Auto mic off — stop listening the moment a valid command is recognised.
    if (next != CommandId.unknown) {
      ref.read(asrProvider.notifier).stopListeningOnCommand();
    }
  });
});

