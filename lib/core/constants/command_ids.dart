/// Enum representing every recognisable drone command in Phase 1.
/// Each variant maps to a set of trigger keywords in [IntentParser].
enum CommandId {
  /// Launch / take-off sequence.
  cmdLaunch,

  /// Hold current position.
  cmdHover,

  /// Orbit / circle around a target.
  cmdOrbit,

  /// Land / descend.
  cmdLand,

  /// Move North / Forward.
  cmdDirN,

  /// Search Left.
  cmdDirL,

  /// Search Right.
  cmdDirR,

  /// Stop / freeze / abort.
  cmdHalt,

  cmdMission, // Start mission — drone must be airborne

  /// No recognised command.
  unknown,
}

/// Extension that maps each [CommandId] to its canonical HTTP payload label.
extension CommandIdLabel on CommandId {
  /// Returns the canonical string label sent in the HTTP payload.
  String get label {
    switch (this) {
      case CommandId.cmdLaunch:
        return 'TAKEOFF';
      case CommandId.cmdHover:
        return 'CMD_HOVER';
      case CommandId.cmdOrbit:
        return 'START_ORBIT';
      case CommandId.cmdLand:
        return 'LAND';
      case CommandId.cmdDirN:
        return 'CMD_DIR_N';
      case CommandId.cmdDirL:
        return 'CMD_DIR_L';
      case CommandId.cmdDirR:
        return 'CMD_DIR_R';
      case CommandId.cmdHalt:
        return 'CMD_HALT';
      case CommandId.cmdMission:
        return 'START_SEARCH';
      case CommandId.unknown:
        return 'UNKNOWN';
    }
  }
}
