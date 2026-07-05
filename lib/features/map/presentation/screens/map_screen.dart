import 'dart:async';
import 'dart:typed_data';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/tactical_grid.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

/// Displays a live auto-refreshing PNG map image and scrollable path text,
/// both fetched from configurable URLs that refresh every 5 seconds.
class MapScreen extends ConsumerStatefulWidget {
  /// Creates a [MapScreen].
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Timer? _mapTimer;
  Timer? _pathTimer;

  Uint8List? _mapBytes;
  String? _pathText;
  String? _mapError;
  String? _pathError;
  DateTime? _mapLastUpdated;
  DateTime? _pathLastUpdated;
  bool _mapLoading = true;
  bool _pathLoading = true;
  bool _refreshSpinning = false;

  @override
  void initState() {
    super.initState();
    // Kick off first fetch on next frame (after ref is available).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMap();
      _fetchPath();
      _mapTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _fetchMap(),
      );
      _pathTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _fetchPath(),
      );
    });
  }

  @override
  void dispose() {
    _mapTimer?.cancel();
    _pathTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMap() async {
    final url = ref.read(settingsProvider).valueOrNull?.mapImageUrl ?? '';
    if (url.isEmpty) return;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      debugPrint('[SwarmApp] Map fetch status: ${response.statusCode}');
      debugPrint('[SwarmApp] Map fetch bytes: ${response.bodyBytes.length}');
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _mapBytes = response.bodyBytes;
          _mapError = null;
          _mapLastUpdated = DateTime.now();
          _mapLoading = false;
        });
      } else {
        setState(() {
          _mapError = 'HTTP ${response.statusCode}';
          _mapLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('[SwarmApp] Map fetch error: $e');
      setState(() {
        _mapError = 'Could not load map';
        _mapLoading = false;
      });
    }
  }

  Future<void> _fetchPath() async {
    final url = ref.read(settingsProvider).valueOrNull?.pathTextUrl ?? '';
    if (url.isEmpty) return;
    try {
      final response = await http.get(Uri.parse(url));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _pathText = response.body;
          _pathError = null;
          _pathLastUpdated = DateTime.now();
          _pathLoading = false;
        });
      } else {
        setState(() {
          _pathError = 'HTTP ${response.statusCode}';
          _pathLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pathError = 'Could not load path data';
        _pathLoading = false;
      });
    }
  }

  Future<void> _manualRefresh() async {
    setState(() => _refreshSpinning = true);
    await _fetchMap();
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _refreshSpinning = false);
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('MAP', style: AppTextStyles.appBarTitle),
      ),
      body: Stack(
        children: [
          const TacticalGrid(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Live Map card ──────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.colorGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.colorBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.colorAccentGlow.withValues(alpha: 0.12),
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
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card header row: title + LIVE indicator + refresh
                              Row(
                                children: [
                                  Text('LIVE MAP', style: AppTextStyles.cardTitle),
                                  const Spacer(),
                                  // LIVE blinking dot
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.colorSuccess,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                      .animate(
                                          onPlay: (c) => c.repeat(reverse: true))
                                      .fade(
                                          begin: 1.0,
                                          end: 0.2,
                                          duration: 800.ms,
                                          curve: Curves.easeInOut),
                                  const Gap(AppTheme.spacing4),
                                  Text(
                                    'LIVE',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 11,
                                      color: AppTheme.colorSuccess,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Gap(AppTheme.spacing8),
                                  Text(
                                    _formatTime(_mapLastUpdated),
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 11,
                                      color: AppTheme.colorTextSecondary,
                                    ),
                                  ),
                                  // Manual refresh button
                                  GestureDetector(
                                    onTap: _manualRefresh,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: AnimatedRotation(
                                        turns: _refreshSpinning ? 1 : 0,
                                        duration: const Duration(milliseconds: 400),
                                        child: const Icon(
                                          Icons.refresh,
                                          color: AppTheme.colorAccent,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(AppTheme.spacing12),
                              if (_mapLoading)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppTheme.spacing32),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (_mapError != null)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppTheme.spacing32),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.broken_image,
                                          size: 48,
                                          color: AppTheme.colorError,
                                        ),
                                        const Gap(AppTheme.spacing8),
                                        Text(
                                          _mapError!,
                                          style: AppTextStyles.transcriptBody.copyWith(
                                            color: AppTheme.colorError,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else if (_mapBytes != null)
                                Builder(
                                  builder: (context) {
                                    try {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          _mapBytes!,
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            debugPrint('[SwarmApp] Map decode error: $error');
                                            return Column(
                                              children: [
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: AppTheme.colorError,
                                                ),
                                                const Gap(AppTheme.spacing8),
                                                Text(
                                                  'Image decode failed',
                                                  style: AppTextStyles.transcriptBody.copyWith(
                                                    color: AppTheme.colorError,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint('[SwarmApp] Map decode error: $e');
                                      return Column(
                                        children: [
                                          const Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: AppTheme.colorError,
                                          ),
                                          const Gap(AppTheme.spacing8),
                                          Text(
                                            'Image decode failed',
                                            style: AppTextStyles.transcriptBody.copyWith(
                                              color: AppTheme.colorError,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppTheme.spacing16),

                  // ── Path text card ─────────────────────────────────────────
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: AppTheme.colorGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.colorBorder, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.colorAccentGlow.withValues(alpha: 0.12),
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
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PATH', style: AppTextStyles.cardTitle),
                              const Gap(AppTheme.spacing12),
                              if (_pathLoading)
                                const Center(child: CircularProgressIndicator())
                              else if (_pathError != null)
                                Text(
                                  _pathError!,
                                  style: AppTextStyles.transcriptBody.copyWith(
                                    color: AppTheme.colorError,
                                  ),
                                )
                              else
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _pathText ?? '',
                                      style: AppTextStyles.transcriptBody,
                                    ),
                                  ),
                                ),
                              const Gap(AppTheme.spacing8),
                              Text(
                                'Last updated: ${_formatTime(_pathLastUpdated)}',
                                style: AppTextStyles.timestamp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
