import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/command_ids.dart';
import '../../data/command_dispatcher.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';

/// Immutable state for the HTTP dispatch feature.
@immutable
class DispatchState {
  /// The last [CommandId] successfully dispatched to the server.
  final CommandId? lastDispatched;

  /// Whether a 5-second countdown is active before firing the request.
  final bool isPending;

  /// Whether an HTTP POST is currently in-flight.
  final bool isSending;

  /// `true` on HTTP 200, `false` on non-200, `null` if never dispatched.
  final bool? lastSuccess;

  /// Set to the error message when a [CommandDispatchException] is caught.
  final String? error;

  /// `true` when the user cancelled the pending dispatch.
  final bool cancelled;

  /// Creates a [DispatchState].
  const DispatchState({
    this.lastDispatched,
    this.isPending = false,
    this.isSending = false,
    this.lastSuccess,
    this.error,
    this.cancelled = false,
  });
}

/// Notifier that owns [DispatchState] and drives HTTP command dispatch.
class DispatchNotifier extends StateNotifier<DispatchState> {
  /// Creates a [DispatchNotifier] with access to [Ref] for settings lookup.
  DispatchNotifier(this._ref) : super(const DispatchState());

  final Ref _ref;
  Timer? _debounceTimer;
  Timer? _resetTimer;

  /// Called whenever [intentProvider] emits a new [CommandId].
  ///
  /// Cancels any existing timer. If [intent] is valid, starts a 5-second
  /// debounce before firing the HTTP request.
  void onIntentChanged(CommandId intent) {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    if (intent == CommandId.unknown) {
      state = DispatchState(
        lastDispatched: state.lastDispatched,
        isPending: false,
        isSending: state.isSending,
        lastSuccess: state.lastSuccess,
        error: state.error,
        cancelled: state.cancelled,
      );
      return;
    }

    state = DispatchState(
      lastDispatched: state.lastDispatched,
      isPending: true,
      isSending: false,
      lastSuccess: state.lastSuccess,
      error: null,
      cancelled: false,
    );

    debugPrint('[SwarmApp] onIntentChanged: ${intent.label}');
    _debounceTimer = Timer(
      const Duration(seconds: 5),
      () => _fire(intent),
    );
  }

  /// Cancels the pending dispatch and shows the CANCELLED state for 3 seconds.
  void cancelPending() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    debugPrint('[SwarmApp] Dispatch cancelled by user');

    state = DispatchState(
      lastDispatched: state.lastDispatched,
      isPending: false,
      isSending: false,
      lastSuccess: state.lastSuccess,
      error: null,
      cancelled: true,
    );

    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        state = DispatchState(
          lastDispatched: state.lastDispatched,
          isPending: false,
          isSending: false,
          lastSuccess: state.lastSuccess,
          error: null,
          cancelled: false,
        );
      }
    });
  }

  /// Fires the HTTP POST after the debounce delay using the current server URL.
  Future<void> _fire(CommandId command) async {
    debugPrint('[SwarmApp] _fire called for ${command.label}');
    if (!mounted) return;

    // Read the server URL at dispatch time so changes in Settings are picked up.
    final serverUrl =
        _ref.read(settingsProvider).valueOrNull?.serverUrl ??
        AppConstants.defaultServerUrl;
    debugPrint('[SwarmApp] Server URL: $serverUrl');
    final dispatcher = CommandDispatcher(serverUrl: serverUrl);

    state = DispatchState(
      lastDispatched: state.lastDispatched,
      isPending: false,
      isSending: true,
      lastSuccess: state.lastSuccess,
      error: null,
      cancelled: false,
    );

    try {
      final success = await dispatcher.dispatch(command);
      if (!mounted) return;

      if (!success) {
        debugPrint('[SwarmApp] Server rejected command: ${command.label}');
      } else {
        debugPrint('[SwarmApp] Dispatched: ${command.label}');
      }

      state = DispatchState(
        lastDispatched: command,
        isPending: false,
        isSending: false,
        lastSuccess: success,
        error: null,
        cancelled: false,
      );
    } on CommandDispatchException catch (e) {
      if (!mounted) return;
      debugPrint('[SwarmApp] Network error for ${command.label}: $e');

      state = DispatchState(
        lastDispatched: state.lastDispatched,
        isPending: false,
        isSending: false,
        lastSuccess: false,
        error: e.message,
        cancelled: false,
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for [DispatchNotifier].
///
/// Use `ref.watch(dispatchProvider)` to read [DispatchState].
/// Use `ref.read(dispatchProvider.notifier).cancelPending()` to cancel.
final dispatchProvider =
    StateNotifierProvider<DispatchNotifier, DispatchState>(
  (ref) => DispatchNotifier(ref),
);
