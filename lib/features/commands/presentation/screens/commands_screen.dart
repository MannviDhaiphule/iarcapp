import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/command_ids.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tactical_grid.dart';
import '../../../voice_command/presentation/providers/dispatch_provider.dart';
import '../../../voice_command/presentation/widgets/dispatch_status_card.dart';

/// A 2-column grid of manual command buttons that trigger the same
/// 5-second debounce + cancel dispatch flow as voice commands.
class CommandsScreen extends ConsumerWidget {
  /// Creates a [CommandsScreen].
  const CommandsScreen({super.key});

  /// Ordered list of command entries shown in the grid.
  static const List<_CmdEntry> _commands = [
    _CmdEntry(CommandId.cmdLaunch, Icons.rocket_launch, 'TAKEOFF'),
    _CmdEntry(CommandId.cmdHover, Icons.airline_stops, 'HOVER'),
    _CmdEntry(CommandId.cmdOrbit, Icons.rotate_right, 'ORBIT'),
    _CmdEntry(CommandId.cmdLand, Icons.flight_land, 'LAND'),
    _CmdEntry(CommandId.cmdDirN, Icons.arrow_upward, 'FORWARD'),
    _CmdEntry(CommandId.cmdDirL, Icons.arrow_back, 'LEFT'),
    _CmdEntry(CommandId.cmdDirR, Icons.arrow_forward, 'RIGHT'),
    _CmdEntry(CommandId.cmdHalt, Icons.pan_tool, 'HALT'),
    _CmdEntry(CommandId.cmdMission, Icons.flag, 'SEARCH'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('COMMANDS', style: AppTextStyles.appBarTitle),
      ),
      body: Stack(
        children: [
          const TacticalGrid(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: _CommandsBody(commands: _commands, ref: ref),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stateful body that tracks the last-tapped command.
class _CommandsBody extends StatefulWidget {
  const _CommandsBody({required this.commands, required this.ref});

  final List<_CmdEntry> commands;
  final WidgetRef ref;

  @override
  State<_CommandsBody> createState() => _CommandsBodyState();
}

class _CommandsBodyState extends State<_CommandsBody> {
  CommandId? _lastTapped;

  void _handleTap(_CmdEntry entry) {
    HapticFeedback.mediumImpact();
    debugPrint('[SwarmApp] BUTTON PRESSED: ${entry.label}');
    widget.ref.read(dispatchProvider.notifier).onIntentChanged(entry.id);
    setState(() => _lastTapped = entry.id);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _lastTapped = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            itemCount: widget.commands.length,
            itemBuilder: (context, index) {
              final entry = widget.commands[index];
              return _CommandButton(
                entry: entry,
                isLastTapped: _lastTapped == entry.id,
                onTap: () => _handleTap(entry),
              );
            },
          ),
        ),
        const Gap(AppTheme.spacing16),
        const DispatchStatusCard(),
        const Gap(AppTheme.spacing24),
      ],
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
class _CommandButton extends StatefulWidget {
  /// Creates a [_CommandButton].
  const _CommandButton({
    required this.entry,
    required this.isLastTapped,
    required this.onTap,
  });

  /// The command entry to render.
  final _CmdEntry entry;

  /// Whether this is the last tapped button (for highlight).
  final bool isLastTapped;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  @override
  State<_CommandButton> createState() => _CommandButtonState();
}

class _CommandButtonState extends State<_CommandButton> {
  bool _isTapped = false;

  void _handleTap() {
    setState(() => _isTapped = true);
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isTapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.isLastTapped;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: highlighted ? AppTheme.colorAccentLight : AppTheme.colorGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? AppTheme.colorAccent : AppTheme.colorBorder,
            width: highlighted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colorAccentGlow.withValues(alpha: highlighted ? 0.25 : 0.12),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.entry.icon, size: 32, color: AppTheme.colorAccent),
                const Gap(AppTheme.spacing8),
                Text(
                  widget.entry.label,
                  style: AppTextStyles.cmdLabel.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.colorTextPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          .animate(target: _isTapped ? 1 : 0)
          .tint(color: AppTheme.colorAccent.withValues(alpha: 0.2), duration: 150.ms)
          .scaleXY(end: 0.95, duration: 100.ms)
          .boxShadow(
            end: BoxShadow(
              color: AppTheme.colorAccentGlow.withValues(alpha: 0.5),
              blurRadius: 20,
            ),
            duration: 150.ms,
          ),
    );
  }
}
