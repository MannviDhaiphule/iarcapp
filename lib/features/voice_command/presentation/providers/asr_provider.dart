import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/asr_service.dart';

/// Immutable state object for the ASR feature.
@immutable
class AsrState {
  /// Whether the ASR engine has been initialised successfully.
  final bool isInitialized;

  /// Whether the engine is actively listening right now.
  final bool isListening;

  /// The latest partial transcript from the ASR engine.
  final String transcript;

  /// Non-null when an ASR or permission error has occurred.
  final String? error;

  /// Creates an [AsrState].
  const AsrState({
    this.isInitialized = false,
    this.isListening = false,
    this.transcript = '',
    this.error,
  });

  /// Returns a copy of this state with the given fields overridden.
  AsrState copyWith({
    bool? isInitialized,
    bool? isListening,
    String? transcript,
    String? clearError,
    String? error,
  }) {
    return AsrState(
      isInitialized: isInitialized ?? this.isInitialized,
      isListening: isListening ?? this.isListening,
      transcript: transcript ?? this.transcript,
      error: clearError != null ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsrState &&
          runtimeType == other.runtimeType &&
          isInitialized == other.isInitialized &&
          isListening == other.isListening &&
          transcript == other.transcript &&
          error == other.error;

  @override
  int get hashCode =>
      isInitialized.hashCode ^
      isListening.hashCode ^
      transcript.hashCode ^
      error.hashCode;
}

/// Notifier that owns [AsrState] and coordinates with [AsrService].
class AsrNotifier extends StateNotifier<AsrState> {
  /// Creates an [AsrNotifier] with a fresh [AsrService].
  AsrNotifier() : super(const AsrState());

  final AsrService _service = AsrService();

  /// Initialises the ASR engine; sets [AsrState.error] on failure.
  Future<void> initialize() async {
    final ok = await _service.initialize();
    if (ok) {
      state = state.copyWith(isInitialized: true, clearError: '');
    } else {
      state = state.copyWith(
        error: 'Microphone permission denied or ASR unavailable.',
      );
    }
  }

  /// Toggles listening on/off. Starts a session if idle, stops if active.
  Future<void> toggleListening() async {
    if (!state.isInitialized) {
      await initialize();
      if (!state.isInitialized) return;
    }

    if (state.isListening) {
      await _service.stopListening();
      state = state.copyWith(isListening: false);
    } else {
      state = state.copyWith(isListening: true, clearError: '');
      await _service.startListening(
        onResult: (String partial) {
          if (mounted) state = state.copyWith(transcript: partial);
        },
      );
      // Subscribe to stream errors so they surface as state errors.
      _service.transcriptStream.listen(
        null,
        onError: (Object err) {
          if (mounted) {
            state = state.copyWith(
              isListening: false,
              error: err.toString(),
            );
          }
        },
        cancelOnError: false,
      );
    }
  }

  /// Stops the microphone immediately when a valid command is recognised.
  ///
  /// No-op if the service is already idle.
  Future<void> stopListeningOnCommand() async {
    if (!state.isListening) return;
    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

/// Riverpod provider for [AsrNotifier].
///
/// Use `ref.watch(asrProvider)` to read [AsrState],
/// `ref.read(asrProvider.notifier).toggleListening()` to act.
final asrProvider = StateNotifierProvider<AsrNotifier, AsrState>(
  (ref) => AsrNotifier(),
);

/// Exposes any ASR error string as a standalone provider.
///
/// Derived from [asrProvider] — non-null means an error is active.
final asrErrorProvider = Provider<String?>(
  (ref) => ref.watch(asrProvider).error,
);
