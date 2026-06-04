import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/command_ids.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../voice_command/presentation/providers/dispatch_provider.dart';
import '../../../voice_command/presentation/widgets/dispatch_status_card.dart';

/// A 2-column grid of manual command buttons that trigger the same
/// 5-second debounce + cancel dispatch flow as voice commands.
class CommandsScreen extends ConsumerWidget {
  /// Creates a [CommandsScreen].
  const CommandsScreen({super.key});

  /// Ordered list of command entries shown in the grid.
  static const List<_CmdEntry> _commands = [
    _CmdEntry(CommandId.cmdLaunch, Icons.rocket_launch, 'LAUNCH'),
    _CmdEntry(CommandId.cmdHover, Icons.airline_stops, 'HOVER'),
    _CmdEntry(CommandId.cmdOrbit, Icons.rotate_right, 'ORBIT'),
    _CmdEntry(CommandId.cmdLand, Icons.flight_land, 'LAND'),
    _CmdEntry(CommandId.cmdDirN, Icons.arrow_upward, 'FORWARD'),
    _CmdEntry(CommandId.cmdDirL, Icons.arrow_back, 'LEFT'),
    _CmdEntry(CommandId.cmdDirR, Icons.arrow_forward, 'RIGHT'),
    _CmdEntry(CommandId.cmdHalt, Icons.pan_tool, 'HALT'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('COMMANDS', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
          child: Column(
            children: [
              const Gap(AppTheme.spacing16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppTheme.spacing8,
                    mainAxisSpacing: AppTheme.spacing8,
                    mainAxisExtent: 100.0,
                  ),
                  itemCount: _commands.length,
                  itemBuilder: (context, index) {
                    final entry = _commands[index];
                    return _CommandButton(
                      entry: entry,
                      onTap: () {
  debugPrint('BUTTON PRESSED: ${entry.label}');
  ref
      .read(dispatchProvider.notifier)
      .onIntentChanged(entry.id);
},
                    );
                  },
                ),
              ),
              const Gap(AppTheme.spacing16),
              const DispatchStatusCard(),
              const Gap(AppTheme.spacing24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal model for a single command button entry.
class _CmdEntry {
  /// Creates a [_CmdEntry].
  const _CmdEntry(this.id, this.icon, this.label);

  /// The [CommandId] to dispatch on tap.
  final CommandId id;

  /// The icon displayed above the label.
  final IconData icon;

  /// The display label shown below the icon.
  final String label;
}

/// A single tappable command button rendered within the grid.
class _CommandButton extends StatelessWidget {
  /// Creates a [_CommandButton].
  const _CommandButton({required this.entry, required this.onTap});

  /// The command entry to render.
  final _CmdEntry entry;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.colorSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(entry.icon, size: 32, color: AppTheme.colorAccent),
            const Gap(AppTheme.spacing8),
            Text(
              entry.label,
              style: AppTextStyles.transcriptBody.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.colorTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
