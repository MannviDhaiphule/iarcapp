import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';

/// Screen that allows the user to configure server and map URLs.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _mapUrlController = TextEditingController();
  final TextEditingController _pathUrlController = TextEditingController();
  final TextEditingController _missionLengthController = TextEditingController();
  String? _missionLengthError;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ipController.addListener(() => setState(() {}));
    _portController.addListener(() => setState(() {}));
    _mapUrlController.addListener(() => setState(() {}));
    _pathUrlController.addListener(() => setState(() {}));
    _missionLengthController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _mapUrlController.dispose();
    _pathUrlController.dispose();
    _missionLengthController.dispose();
    super.dispose();
  }

  /// Live preview URL derived from the current text-field values.
  String get _previewUrl {
    final ip = _ipController.text.trim().isEmpty
        ? AppConstants.defaultServerIp
        : _ipController.text.trim();
    final port = int.tryParse(_portController.text.trim()) ??
        AppConstants.defaultServerPort;
    return 'http://$ip:$port';
  }

  void _saveServer() {
    final port = int.tryParse(_portController.text.trim());
    if (port == null) return;

    final missionLenText = _missionLengthController.text.trim();
    final missionLen = double.tryParse(missionLenText);
    if (missionLen == null || missionLen <= 0) {
      setState(() {
        _missionLengthError = 'Must be a positive number';
      });
      return;
    }
    setState(() => _missionLengthError = null);

    ref
        .read(settingsProvider.notifier)
        .updateServerIp(_ipController.text.trim());
    ref.read(settingsProvider.notifier).updateServerPort(port);
    ref.read(settingsProvider.notifier).updateMissionLength(missionLen);

    final ip = _ipController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server URL updated: http://$ip:$port')),
    );
  }

  void _resetServer() {
    ref.read(settingsProvider.notifier).resetToDefaults();
    _ipController.text = AppConstants.defaultServerIp;
    _portController.text = AppConstants.defaultServerPort.toString();
    _mapUrlController.text = AppConstants.defaultMapImageUrl;
    _pathUrlController.text = AppConstants.defaultPathTextUrl;
    _missionLengthController.text = AppConstants.defaultMissionLength.toString();
    setState(() => _missionLengthError = null);
  }

  void _saveMap() {
    ref
        .read(settingsProvider.notifier)
        .updateMapImageUrl(_mapUrlController.text.trim());
    ref
        .read(settingsProvider.notifier)
        .updatePathTextUrl(_pathUrlController.text.trim());
  }

  void _resetMap() {
    ref
        .read(settingsProvider.notifier)
        .updateMapImageUrl(AppConstants.defaultMapImageUrl);
    ref
        .read(settingsProvider.notifier)
        .updatePathTextUrl(AppConstants.defaultPathTextUrl);
    _mapUrlController.text = AppConstants.defaultMapImageUrl;
    _pathUrlController.text = AppConstants.defaultPathTextUrl;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    // Pre-fill controllers once settings have loaded.
    settingsAsync.whenData((s) {
      if (!_initialized) {
        _initialized = true;
        _ipController.text = s.serverIp;
        _portController.text = s.serverPort.toString();
        _mapUrlController.text = s.mapImageUrl;
        _pathUrlController.text = s.pathTextUrl;
        _missionLengthController.text = s.missionLength.toString();
      }
    });

    final settings = settingsAsync.valueOrNull;
    final isSaving = settings?.isSaving ?? false;
    final savedSuccess = settings?.savedSuccess ?? false;
    final error = settings?.error;

    return Scaffold(
      backgroundColor: AppTheme.colorBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('SETTINGS', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(AppTheme.spacing16),

              // ── Server configuration card ─────────────────────────────
              _buildCard(
                title: 'SERVER CONFIGURATION',
                children: [
                  _buildLabel('Server IP Address'),
                  const Gap(AppTheme.spacing8),
                  TextField(
                    controller: _ipController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.transcriptBody,
                    decoration: InputDecoration(
                      hintText: AppConstants.defaultServerIp,
                      filled: true,
                      fillColor: AppTheme.colorSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorAccent),
                      ),
                      errorText: error,
                      errorStyle: const TextStyle(color: AppTheme.colorError),
                    ),
                  ),
                  const Gap(AppTheme.spacing12),
                  _buildLabel('Port'),
                  const Gap(AppTheme.spacing8),
                  TextField(
                    controller: _portController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.transcriptBody,
                    decoration: InputDecoration(
                      hintText: AppConstants.defaultServerPort.toString(),
                      filled: true,
                      fillColor: AppTheme.colorSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorAccent),
                      ),
                    ),
                  ),
                  const Gap(AppTheme.spacing12),
                  _buildLabel('Mission Length (param1)'),
                  const Gap(AppTheme.spacing8),
                  TextField(
                    controller: _missionLengthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.transcriptBody,
                    decoration: InputDecoration(
                      hintText: AppConstants.defaultMissionLength.toString(),
                      filled: true,
                      fillColor: AppTheme.colorSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorAccent),
                      ),
                      errorText: _missionLengthError,
                      errorStyle: const TextStyle(color: AppTheme.colorError),
                    ),
                  ),
                  const Gap(AppTheme.spacing16),
                  _buildButtons(
                      onSave: isSaving ? null : _saveServer,
                      onReset: _resetServer),
                  if (savedSuccess) ...[
                    const Gap(AppTheme.spacing8),
                    Text(
                      '✓ Saved!',
                      style: AppTextStyles.transcriptBody.copyWith(
                        color: AppTheme.colorSuccess,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(duration: 200.ms),
                  ],
                ],
              ),
              const Gap(AppTheme.spacing16),

              // ── Live URL preview card ─────────────────────────────────
              _buildCard(
                title: 'CURRENT SERVER URL',
                children: [
                  Text(
                    _previewUrl,
                    style: AppTextStyles.transcriptBody.copyWith(
                      color: AppTheme.colorAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Gap(AppTheme.spacing16),

              // ── Map configuration card ────────────────────────────────
              _buildCard(
                title: 'MAP CONFIGURATION',
                children: [
                  _buildLabel('Map Image URL'),
                  const Gap(AppTheme.spacing8),
                  TextField(
                    controller: _mapUrlController,
                    keyboardType: TextInputType.url,
                    style: AppTextStyles.transcriptBody,
                    decoration: InputDecoration(
                      hintText: AppConstants.defaultMapImageUrl,
                      filled: true,
                      fillColor: AppTheme.colorSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorAccent),
                      ),
                    ),
                  ),
                  const Gap(AppTheme.spacing12),
                  _buildLabel('Path Text URL'),
                  const Gap(AppTheme.spacing8),
                  TextField(
                    controller: _pathUrlController,
                    keyboardType: TextInputType.url,
                    style: AppTextStyles.transcriptBody,
                    decoration: InputDecoration(
                      hintText: AppConstants.defaultPathTextUrl,
                      filled: true,
                      fillColor: AppTheme.colorSurfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.colorAccent),
                      ),
                    ),
                  ),
                  const Gap(AppTheme.spacing16),
                  _buildButtons(
                      onSave: isSaving ? null : _saveMap, onReset: _resetMap),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a standard card container with [title] header.
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
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
                Text(title, style: AppTextStyles.cardTitle),
                const Gap(AppTheme.spacing16),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a bold field label.
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.transcriptBody.copyWith(fontWeight: FontWeight.w600),
    );
  }

  /// Builds the SAVE / RESET TO DEFAULT button row.
  Widget _buildButtons({VoidCallback? onSave, required VoidCallback onReset}) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.colorAccent,
              disabledBackgroundColor: AppTheme.colorSurfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('SAVE'),
          ),
        ),
        const Gap(AppTheme.spacing12),
        Expanded(
          child: OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.colorAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('RESET TO DEFAULT'),
          ),
        ),
      ],
    );
  }
}
