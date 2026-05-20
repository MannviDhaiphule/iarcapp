import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/command_ids.dart';
import '../../../../core/constants/command_display.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/intent_provider.dart';

/// Displays the currently recognised [CommandId] with label, icon, and status chip.
///
/// Animates colour changes with a 200 ms fade+scale transition via [flutter_animate].
class IntentDisplayCard extends ConsumerWidget {
  /// Creates an [IntentDisplayCard].
  const IntentDisplayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CommandId intent = ref.watch(intentProvider);
    final bool isKnown = intent != CommandId.unknown;

    final Color chipBg = commandChipColor(intent);
    final Color chipText = commandChipTextColor(intent);
    final String label = commandLabel(intent);
    final IconData icon = commandIcon(intent);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.colorSurface,
        borderRadius: AppTheme.radiusCard,
        border: Border.all(
          color: isKnown ? AppTheme.colorSuccess.withOpacity(0.4) : AppTheme.colorSurfaceDark,
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INTENT DISPLAY', style: AppTextStyles.cardTitle),
          const Gap(AppTheme.spacing16),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.cmdLabel.copyWith(
                    color: isKnown
                        ? AppTheme.colorTextPrimary
                        : AppTheme.colorTextSecondary,
                  ),
                ),
              ),
              const Gap(AppTheme.spacing16),
              Icon(
                icon,
                size: 36,
                color: isKnown ? AppTheme.colorAccent : AppTheme.colorTextSecondary,
              ),
            ],
          ),
          const Gap(AppTheme.spacing16),
          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing4,
            ),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              isKnown ? 'RECOGNIZED' : 'AWAITING INPUT',
              style: AppTextStyles.chipLabel.copyWith(color: chipText),
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey(intent))
        .fadeIn(duration: 200.ms)
        .scaleXY(begin: 0.97, end: 1.0, duration: 200.ms, curve: Curves.easeOut);
  }
}
