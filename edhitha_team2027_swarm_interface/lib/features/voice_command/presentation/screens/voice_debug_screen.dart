import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/asr_provider.dart';
import '../providers/intent_provider.dart';
import '../widgets/dispatch_status_card.dart';
import '../widgets/intent_display_card.dart';
import '../widgets/mic_toggle_button.dart';
import '../widgets/transcription_stream_card.dart';

/// The main voice-debug screen — entry point of the swarm interface.
///
/// Shows intent display, transcription stream, dispatch status card, and the
/// mic toggle button. A hamburger menu opens the navigation drawer.
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
    // Initialise ASR on first frame.
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
    // Activate intent → dispatch bridge (also triggers auto mic off).
    ref.watch(intentDispatchBridgeProvider);

    // React to error state changes.
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
        // ── Hamburger navigation drawer ─────────────────────────────────
        drawer: Drawer(
          backgroundColor: AppTheme.colorBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration:
                    const BoxDecoration(color: AppTheme.colorAccent),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'SWARM INTERFACE',
                      style: AppTextStyles.appBarTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const Gap(AppTheme.spacing4),
                    Text(
                      'v1.0',
                      style: AppTextStyles.appBarVersion.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: AppTheme.colorAccent,
                ),
                title: Text(
                  'Settings',
                  style: AppTextStyles.transcriptBody.copyWith(
                    color: AppTheme.colorTextPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // close drawer first
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              // Space reserved for future drawer items.
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: AppTheme.colorBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          // Hamburger button — Builder provides a context below Scaffold.
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                color: AppTheme.colorTextPrimary,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text('SWARM INTERFACE', style: AppTextStyles.appBarTitle),
          actions: [
            Padding(
              padding:
                  const EdgeInsets.only(right: AppTheme.spacing16),
              child: Center(
                child: Text('v1.0', style: AppTextStyles.appBarVersion),
              ),
            ),
          ],
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Gap(AppTheme.spacing16),
                // Intent display — top half
                IntentDisplayCard(),
                Gap(AppTheme.spacing16),
                // Transcription stream
                Expanded(child: TranscriptionStreamCard()),
                Gap(AppTheme.spacing16),
                // Dispatch status card
                DispatchStatusCard(),
                Gap(AppTheme.spacing24),
                // Mic toggle button centred
                Center(child: MicToggleButton()),
                Gap(AppTheme.spacing32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
