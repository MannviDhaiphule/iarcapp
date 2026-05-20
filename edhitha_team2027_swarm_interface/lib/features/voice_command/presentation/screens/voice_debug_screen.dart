import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/asr_provider.dart';
import '../widgets/intent_display_card.dart';
import '../widgets/mic_toggle_button.dart';
import '../widgets/transcription_stream_card.dart';

/// The main Phase 1 UI screen — voice debug interface.
///
/// Shows intent display, transcription stream, and mic toggle button.
/// Handles ASR error snackbars automatically.
class VoiceDebugScreen extends ConsumerStatefulWidget {
  /// Creates a [VoiceDebugScreen].
  const VoiceDebugScreen({super.key});

  @override
  ConsumerState<VoiceDebugScreen> createState() => _VoiceDebugScreenState();
}

class _VoiceDebugScreenState extends ConsumerState<VoiceDebugScreen> {
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    // Initialise ASR on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(asrProvider.notifier).initialize();
    });
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const Gap(AppTheme.spacing8),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.transcriptBody.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.colorError,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radiusButton,
          ),
          margin: const EdgeInsets.all(AppTheme.spacing16),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // React to error state changes
    ref.listen<String?>(asrErrorProvider, (_, next) {
      if (next != null && next != _lastShownError) {
        _lastShownError = next;
        _showErrorSnackbar(next);
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.colorBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.colorBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: AppTheme.spacing16,
          title: Row(
            children: [
              Text(
                'SWARM INTERFACE',
                style: AppTextStyles.appBarTitle,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacing16),
              child: Center(
                child: Text('v1.0', style: AppTextStyles.appBarVersion),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(AppTheme.spacing16),
                // Intent display — top half
                const IntentDisplayCard(),
                const Gap(AppTheme.spacing16),
                // Transcription stream
                const Expanded(child: TranscriptionStreamCard()),
                const Gap(AppTheme.spacing24),
                // Mic toggle button centred
                const Center(child: MicToggleButton()),
                const Gap(AppTheme.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
