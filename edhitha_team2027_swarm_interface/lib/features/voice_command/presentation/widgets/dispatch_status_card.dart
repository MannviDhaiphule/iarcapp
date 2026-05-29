import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/dispatch_provider.dart';

/// Shows the live HTTP dispatch status for the last recognised command.
///
/// Includes a 5-second countdown progress bar, an animated cancel button,
/// and an auto-resetting CANCELLED state. Place between the Transcription
/// Stream Card and the Mic Toggle Button.
class DispatchStatusCard extends ConsumerStatefulWidget {
  /// Creates a [DispatchStatusCard].
  const DispatchStatusCard({super.key});

  @override
  ConsumerState<DispatchStatusCard> createState() =>
      _DispatchStatusCardState();
}

class _DispatchStatusCardState extends ConsumerState<DispatchStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  /// Drives the countdown animation based on [DispatchState] transitions.
  void _handleStateChange(DispatchState? prev, DispatchState next) {
    final wasP = prev?.isPending ?? false;
    if (next.isPending && !wasP) {
      _progress.value = 0.0;
      _progress.forward();
    } else if (!next.isPending && wasP) {
      _progress.stop();
      _progress.reset();
    }
  }

  /// Resolves the icon, label, and colour for the current [DispatchState].
  ({IconData icon, String label, Color color}) _resolve(DispatchState s) {
    if (s.error != null) {
      return (
        icon: Icons.wifi_off,
        label: 'NETWORK ERROR',
        color: AppTheme.colorError,
      );
    }
    if (s.isSending) {
      return (
        icon: Icons.send,
        label: 'DISPATCHING\u2026',
        color: AppTheme.colorAccent,
      );
    }
    if (s.isPending) {
      return (
        icon: Icons.schedule,
        label: 'SENDING IN 5s\u2026',
        color: AppTheme.colorWarning,
      );
    }
    if (s.cancelled) {
      return (
        icon: Icons.cancel,
        label: 'CANCELLED',
        color: AppTheme.colorTextSecondary,
      );
    }
    if (s.lastSuccess == true) {
      return (
        icon: Icons.check_circle,
        label: 'DISPATCHED',
        color: AppTheme.colorSuccess,
      );
    }
    if (s.lastSuccess == false) {
      return (
        icon: Icons.error_outline,
        label: 'SERVER REJECTED',
        color: AppTheme.colorError,
      );
    }
    return (
      icon: Icons.wifi_off,
      label: 'IDLE \u2014 NO COMMAND SENT',
      color: AppTheme.colorTextSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DispatchState>(dispatchProvider, _handleStateChange);
    final state = ref.watch(dispatchProvider);
    final display = _resolve(state);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colorSurface,
        borderRadius: AppTheme.radiusCard,
        border: Border.all(color: AppTheme.colorSurfaceDark),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DISPATCH STATUS', style: AppTextStyles.cardTitle),
          const Gap(AppTheme.spacing12),

          // Status row
          Row(
            children: [
              Icon(display.icon, color: display.color, size: 20),
              const Gap(AppTheme.spacing8),
              Expanded(
                child: Text(
                  display.label,
                  style: AppTextStyles.transcriptBody.copyWith(
                    color: display.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const Gap(AppTheme.spacing12),

          // Countdown progress bar — animates 1.0 → 0.0 over 5 s
          AnimatedBuilder(
            animation: _progress,
            builder: (context, _) => LinearProgressIndicator(
              value: state.isPending ? (1.0 - _progress.value) : 0.0,
              backgroundColor: AppTheme.colorSurfaceDark,
              color: AppTheme.colorWarning,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Cancel button — visible only while pending; fades in/out
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: state.isPending
                ? Padding(
                    key: const ValueKey('cancel-btn'),
                    padding: const EdgeInsets.only(top: AppTheme.spacing12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(dispatchProvider.notifier).cancelPending(),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('CANCEL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.colorError,
                          side: const BorderSide(color: AppTheme.colorError),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ).animate().fadeIn(duration: 150.ms),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('cancel-hidden')),
          ),
        ],
      ),
    );
  }
}
