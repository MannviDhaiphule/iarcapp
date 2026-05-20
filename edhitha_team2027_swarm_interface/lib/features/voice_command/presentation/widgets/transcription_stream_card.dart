import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/asr_provider.dart';

/// A timestamped transcript entry shown in [TranscriptionStreamCard].
class _TranscriptEntry {
  /// The HH:mm:ss timestamp when this entry was captured.
  final String timestamp;

  /// The recognised partial text.
  final String text;

  /// Creates a [_TranscriptEntry].
  const _TranscriptEntry({required this.timestamp, required this.text});
}

/// Displays the last 5 partial ASR transcript lines with timestamps.
///
/// New entries slide in from the bottom using [flutter_animate].
class TranscriptionStreamCard extends ConsumerStatefulWidget {
  /// Creates a [TranscriptionStreamCard].
  const TranscriptionStreamCard({super.key});

  @override
  ConsumerState<TranscriptionStreamCard> createState() =>
      _TranscriptionStreamCardState();
}

class _TranscriptionStreamCardState
    extends ConsumerState<TranscriptionStreamCard> {
  final List<_TranscriptEntry> _entries = [];

  static const int _maxEntries = 5;

  String _nowTimestamp() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _appendEntry(String transcript) {
    if (transcript.isEmpty) return;
    setState(() {
      _entries.add(
        _TranscriptEntry(timestamp: _nowTimestamp(), text: transcript),
      );
      if (_entries.length > _maxEntries) {
        _entries.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen outside build — ref.listen is safe here in ConsumerStatefulWidget
    ref.listen<String>(
      asrProvider.select((s) => s.transcript),
      (previous, next) {
        if (next.isNotEmpty && next != previous) {
          _appendEntry(next);
        }
      },
    );

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
          Text('TRANSCRIPTION STREAM', style: AppTextStyles.cardTitle),
          const Gap(AppTheme.spacing12),
          if (_entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
              child: Text(
                'Waiting for voice input…',
                style: AppTextStyles.transcriptBody.copyWith(
                  color: AppTheme.colorTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _entries.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing6,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.timestamp, style: AppTextStyles.timestamp),
                      const Gap(AppTheme.spacing12),
                      Expanded(
                        child: Text(
                          entry.text,
                          style: AppTextStyles.transcriptBody,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 250.ms,
                      curve: Curves.easeOut,
                    )
                    .fadeIn(duration: 250.ms);
              },
            ),
        ],
      ),
    );
  }
}
