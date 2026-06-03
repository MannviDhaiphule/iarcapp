import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/settings_repository.dart';

part 'settings_provider.g.dart';

/// Sentinel used by [SettingsState.copyWith] to distinguish unset from null.
class _Unset {
  const _Unset();
}

const _unset = _Unset();

/// Immutable state for the settings feature.
@immutable
class SettingsState {
  /// Creates a [SettingsState].
  const SettingsState({
    required this.serverIp,
    required this.serverPort,
    this.isSaving = false,
    this.savedSuccess = false,
    this.error,
  });

  /// The configured server IP address.
  final String serverIp;

  /// The configured server port number.
  final int serverPort;

  /// Whether a save operation is currently in progress.
  final bool isSaving;

  /// Briefly `true` after a successful save — resets to `false` after 2 seconds.
  final bool savedSuccess;

  /// Set when IP validation fails; `null` otherwise.
  final String? error;

  /// Full base URL derived from [serverIp] and [serverPort].
  String get serverUrl => 'http://$serverIp:$serverPort';

  /// Returns a copy with the given fields overridden.
  SettingsState copyWith({
    String? serverIp,
    int? serverPort,
    bool? isSaving,
    bool? savedSuccess,
    Object? error = _unset,
  }) {
    return SettingsState(
      serverIp: serverIp ?? this.serverIp,
      serverPort: serverPort ?? this.serverPort,
      isSaving: isSaving ?? this.isSaving,
      savedSuccess: savedSuccess ?? this.savedSuccess,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

/// Code-generated [AsyncNotifier] for the settings feature.
@riverpod
class Settings extends _$Settings {
  final SettingsRepository _repo = SettingsRepository();
  Timer? _savedSuccessTimer;

  @override
  Future<SettingsState> build() async {
    final ip = await _repo.getServerIp();
    final port = await _repo.getServerPort();
    return SettingsState(serverIp: ip, serverPort: port);
  }

  /// Validates [ip] format and saves it; sets [SettingsState.error] if invalid.
  Future<void> updateServerIp(String ip) async {
    final ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    final current = _current();

    if (!ipRegex.hasMatch(ip)) {
      state = AsyncData(current.copyWith(error: 'Invalid IP address format'));
      return;
    }

    state = AsyncData(current.copyWith(isSaving: true, error: null));
    await _repo.setServerIp(ip);
    state = AsyncData(
      current.copyWith(
        serverIp: ip,
        isSaving: false,
        savedSuccess: true,
        error: null,
      ),
    );
    _scheduleSavedReset();
  }

  /// Validates [port] is in range 1–65535 and saves it.
  Future<void> updateServerPort(int port) async {
    final current = _current();

    if (port < 1 || port > 65535) {
      state = AsyncData(current.copyWith(error: 'Port must be 1–65535'));
      return;
    }

    state = AsyncData(current.copyWith(isSaving: true, error: null));
    await _repo.setServerPort(port);
    state = AsyncData(
      current.copyWith(
        serverPort: port,
        isSaving: false,
        savedSuccess: true,
        error: null,
      ),
    );
    _scheduleSavedReset();
  }

  /// Resets both IP and port to [AppConstants] defaults and persists.
  Future<void> resetToDefaults() async {
    await _repo.setServerIp(AppConstants.defaultServerIp);
    await _repo.setServerPort(AppConstants.defaultServerPort);
    state = const AsyncData(
      SettingsState(
        serverIp: AppConstants.defaultServerIp,
        serverPort: AppConstants.defaultServerPort,
        savedSuccess: true,
      ),
    );
    _scheduleSavedReset();
  }

  SettingsState _current() =>
      state.valueOrNull ??
      const SettingsState(
        serverIp: AppConstants.defaultServerIp,
        serverPort: AppConstants.defaultServerPort,
      );

  void _scheduleSavedReset() {
    _savedSuccessTimer?.cancel();
    _savedSuccessTimer = Timer(const Duration(seconds: 2), () {
      try {
        final current = state.valueOrNull;
        if (current != null) {
          state = AsyncData(current.copyWith(savedSuccess: false));
        }
      } catch (_) {
        // Notifier disposed before timer fired — safely ignored.
      }
    });
  }
}
