import '../../../core/constants/command_ids.dart';

/// Maps raw ASR transcript strings to [CommandId] values.
///
/// Pure Dart — no Flutter imports. Fully unit-testable in isolation.
class IntentParser {
  /// Trigger keyword map: each entry maps a keyword phrase to a [CommandId].
  /// Order matters for tie-breaking (last match wins per PRD §6).
  static const List<(String, CommandId)> _triggerMap = [
    ('launch', CommandId.cmdLaunch),
    ('takeoff', CommandId.cmdLaunch),
    ('take off', CommandId.cmdLaunch),
    ('liftoff', CommandId.cmdLaunch),
    ('lift off', CommandId.cmdLaunch),
    ('begin launch', CommandId.cmdLaunch),
    ('hover', CommandId.cmdHover),
    ('hold position', CommandId.cmdHover),
    ('stay', CommandId.cmdHover),
    ('orbit', CommandId.cmdOrbit),
    ('circle', CommandId.cmdOrbit),
    ('rotate around', CommandId.cmdOrbit),
    ('land', CommandId.cmdLand),
    ('descend', CommandId.cmdLand),
    ('set down', CommandId.cmdLand),
    ('touch down', CommandId.cmdLand),
    ('advance', CommandId.cmdDirN),
    ('forward', CommandId.cmdDirN),
    ('move forward', CommandId.cmdDirN),
    ('go forward', CommandId.cmdDirN),
    ('proceed', CommandId.cmdDirN),
    ('search left', CommandId.cmdDirL),
    ('go left', CommandId.cmdDirL),
    ('move left', CommandId.cmdDirL),
    ('left', CommandId.cmdDirL),
    ('search right', CommandId.cmdDirR),
    ('go right', CommandId.cmdDirR),
    ('move right', CommandId.cmdDirR),
    ('right', CommandId.cmdDirR),
    ('stop', CommandId.cmdHalt),
    ('halt', CommandId.cmdHalt),
    ('hold', CommandId.cmdHalt),
    ('freeze', CommandId.cmdHalt),
    ('abort', CommandId.cmdHalt),
  ];

  /// Normalises [rawTranscript] and returns the most-recently matched [CommandId].
  ///
  /// Normalisation: lowercase + strip non-alphanumeric-non-space + trim.
  /// If multiple keywords match, the **last** match (by keyword list order) wins.
  /// Returns [CommandId.unknown] when nothing matches.
  CommandId parse(String rawTranscript) {
    final normalised = _normalise(rawTranscript);
    if (normalised.isEmpty) return CommandId.unknown;

    CommandId? result;
    for (final (keyword, cmd) in _triggerMap) {
      if (normalised.contains(keyword)) {
        result = cmd;
      }
    }
    return result ?? CommandId.unknown;
  }

  /// Lowercases, strips punctuation (keeps letters, digits, spaces), and trims.
  String _normalise(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9 ]"), ' ')
        .replaceAll(RegExp(r' +'), ' ')
        .trim();
  }
}
