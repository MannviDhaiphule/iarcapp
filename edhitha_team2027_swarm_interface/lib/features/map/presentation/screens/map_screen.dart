import 'dart:async';
import 'dart:typed_data';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
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
      final response = await http.get(Uri.parse(url));
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
      body: SafeArea(
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
                      color: AppTheme.colorAccentGlow.withValues(alpha: 0.08),
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
                    Text('LIVE MAP', style: AppTextStyles.cardTitle),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _mapBytes!,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    const Gap(AppTheme.spacing8),
                    Text(
                      'Last updated: ${_formatTime(_mapLastUpdated)}',
                      style: AppTextStyles.timestamp,
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
                      color: AppTheme.colorAccentGlow.withValues(alpha: 0.08),
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
    );
  }
}
