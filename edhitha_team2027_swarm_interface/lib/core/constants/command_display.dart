import 'package:flutter/material.dart';
import '../../core/constants/command_ids.dart';
import '../../core/theme/app_theme.dart';

/// Maps a [CommandId] to its display label string.
String commandLabel(CommandId id) {
  switch (id) {
    case CommandId.cmdLaunch:
      return 'CMD_LAUNCH';
    case CommandId.cmdHover:
      return 'CMD_HOVER';
    case CommandId.cmdOrbit:
      return 'CMD_ORBIT';
    case CommandId.cmdLand:
      return 'CMD_LAND';
    case CommandId.cmdDirN:
      return 'CMD_DIR_N';
    case CommandId.cmdDirL:
      return 'CMD_DIR_L';
    case CommandId.cmdDirR:
      return 'CMD_DIR_R';
    case CommandId.cmdHalt:
      return 'CMD_HALT';
    case CommandId.cmdMission:
      return 'CMD_MISSION';
    case CommandId.unknown:
      return 'AWAITING INPUT';
  }
}

/// Maps a [CommandId] to its Material icon.
IconData commandIcon(CommandId id) {
  switch (id) {
    case CommandId.cmdLaunch:
      return Icons.rocket_launch;
    case CommandId.cmdHover:
      return Icons.airline_stops;
    case CommandId.cmdOrbit:
      return Icons.rotate_right;
    case CommandId.cmdLand:
      return Icons.flight_land;
    case CommandId.cmdDirN:
      return Icons.arrow_upward;
    case CommandId.cmdDirL:
      return Icons.arrow_back;
    case CommandId.cmdDirR:
      return Icons.arrow_forward;
    case CommandId.cmdHalt:
      return Icons.pan_tool;
    case CommandId.cmdMission:
      return Icons.flag;
    case CommandId.unknown:
      return Icons.mic_none;
  }
}

/// Returns the accent color for the status chip based on [CommandId].
Color commandChipColor(CommandId id) {
  if (id == CommandId.unknown) return AppTheme.colorSurfaceElevated;
  return AppTheme.colorSuccess.withValues(alpha: 0.15);
}

/// Returns the text color for the chip label based on [CommandId].
Color commandChipTextColor(CommandId id) {
  if (id == CommandId.unknown) return AppTheme.colorTextSecondary;
  return AppTheme.colorSuccess;
}
