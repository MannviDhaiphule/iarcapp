import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/asr_provider.dart';

/// An 80×80 circular button that toggles ASR listening on/off.
///
/// Visual states:
/// - Idle: [AppTheme.colorSurface] background with [AppTheme.colorAccent] mic icon.
/// - Listening: [AppTheme.colorAccentLight] background with pulsing accent border.
/// - Error: [AppTheme.colorError] background.
class MicToggleButton extends ConsumerWidget {
  /// Creates a [MicToggleButton].
  const MicToggleButton({super.key});

  static const double _size = 80.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asrState = ref.watch(asrProvider);
    final bool isListening = asrState.isListening;
    final bool hasError = asrState.error != null;

    final Color bg = hasError
        ? AppTheme.colorError
        : isListening
            ? AppTheme.colorAccentLight
            : AppTheme.colorSurface;

    final Color iconColor = hasError
        ? Colors.white
        : AppTheme.colorAccent;

    final String label = isListening ? 'LISTENING...' : 'TAP TO SPEAK';

    Widget button = GestureDetector(
      onTap: () => ref.read(asrProvider.notifier).toggleListening(),
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: isListening ? AppTheme.colorAccent : AppTheme.colorSurfaceDark,
            width: isListening ? 2.5 : 1.5,
          ),
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: AppTheme.colorAccent.withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: iconColor,
          size: 32,
        ),
      ),
    );

    // Pulsing animation when listening
    if (isListening) {
      button = button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.08,
            duration: 700.ms,
            curve: Curves.easeInOut,
          )
          .shimmer(
            duration: 1200.ms,
            color: AppTheme.colorAccent.withValues(alpha: 0.2),
          );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: AppTheme.spacing8),
        Text(label, style: AppTextStyles.micLabel),
      ],
    );
  }
}
