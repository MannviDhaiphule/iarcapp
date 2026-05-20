import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/command_ids.dart';
import '../../domain/intent_parser.dart';
import 'asr_provider.dart';

/// Derived read-only provider that parses the latest ASR transcript into a [CommandId].
///
/// Recomputes automatically whenever [asrProvider]'s transcript changes.
final intentProvider = Provider<CommandId>((ref) {
  final transcript = ref.watch(asrProvider.select((s) => s.transcript));
  return IntentParser().parse(transcript);
});
