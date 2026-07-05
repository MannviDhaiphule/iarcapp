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
/// - Listening: [AppTheme.colorAccentLight] background with animated waveform bars,
///   pulsing rings, and neon pink glow.
/// - Error: [AppTheme.colorError] background.
class MicToggleButton extends ConsumerStatefulWidget {
  /// Creates a [MicToggleButton].
  const MicToggleButton({super.key});

  @override
  ConsumerState<MicToggleButton> createState() => _MicToggleButtonState();
}

class _MicToggleButtonState extends ConsumerState<MicToggleButton>
    with TickerProviderStateMixin {
  static const double _size = 80.0;
  static const int _barCount = 5;

  final List<AnimationController> _barControllers = [];
  final List<Animation<double>> _barAnimations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _barCount; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      final anim = Tween<double>(begin: 8.0, end: 32.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
      _barControllers.add(ctrl);
      _barAnimations.add(anim);
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _barControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asrState = ref.watch(asrProvider);
    final bool isListening = asrState.isListening;
    final bool hasError = asrState.error != null;

    final Color bg = hasError
        ? AppTheme.colorError
        : isListening
            ? AppTheme.colorAccentLight
            : AppTheme.colorSurface;

    final Color iconColor = hasError ? Colors.white : AppTheme.colorAccent;

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
            color: isListening ? AppTheme.colorAccent : AppTheme.colorBorder,
            width: isListening ? 2.5 : 1.5,
          ),
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: AppTheme.colorAccent.withValues(alpha: 0.5),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: iconColor,
              size: 28,
            ),
            if (isListening) ...[
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: Listenable.merge(_barControllers),
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_barCount, (i) {
                      return Padding(
                        padding: EdgeInsets.only(right: i < _barCount - 1 ? 4 : 0),
                        child: Container(
                          width: 4,
                          height: _barAnimations[i].value,
                          decoration: BoxDecoration(
                            color: AppTheme.colorAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );

    // Pulsing animation when listening
    if (isListening) {
      button = Stack(
        alignment: Alignment.center,
        children: [
          // Expanding ring 1
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.colorAccent, width: 2),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scaleXY(begin: 1.0, end: 1.6, duration: 1500.ms, curve: Curves.easeOut)
              .fadeOut(duration: 1500.ms, curve: Curves.easeOut),

          // Expanding ring 2
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.colorAccent, width: 2),
            ),
          )
              .animate(delay: 750.ms, onPlay: (controller) => controller.repeat())
              .scaleXY(begin: 1.0, end: 1.6, duration: 1500.ms, curve: Curves.easeOut)
              .fadeOut(duration: 1500.ms, curve: Curves.easeOut),

          button
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                begin: 1.0,
                end: 1.08,
                duration: 700.ms,
                curve: Curves.easeInOut,
              )
              .tint(color: Colors.white, duration: 700.ms, end: 0.1),
        ],
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
