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

  /// No recognised command.
  unknown,
}
