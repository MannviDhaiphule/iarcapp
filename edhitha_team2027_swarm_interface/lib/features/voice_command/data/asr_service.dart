import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

/// Wraps the [SpeechToText] plugin with permission handling.
///
/// Exposes a simple initialize / startListening / stopListening API and
/// a broadcast [transcriptStream] for partial result updates.
class AsrService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  final StreamController<String> _transcriptController =
      StreamController<String>.broadcast();

  bool _isAvailable = false;
  bool _isListening = false;

  /// Whether the underlying speech engine initialised successfully.
  bool get isAvailable => _isAvailable;

  /// Whether the engine is currently in a listening session.
  bool get isListening => _isListening;

  /// Emits partial transcript strings as they arrive from the ASR engine.
  Stream<String> get transcriptStream => _transcriptController.stream;

  /// Requests microphone permission then initialises [SpeechToText].
  ///
  /// Returns `true` on success, `false` if permission is denied or init fails.
  Future<bool> initialize() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint('[SwarmApp] Microphone permission denied: $status');
      return false;
    }

    _isAvailable = await _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
      debugLogging: false,
    );

    debugPrint('[SwarmApp] ASR initialised: $_isAvailable');
    return _isAvailable;
  }

  /// Begins a dictation session, streaming partial results via [onResult].
  ///
  /// Uses [SpeechListenOptions] with `onDevice: true` and `partialResults: true`
  /// to enforce fully offline processing (PRD §2).
  Future<void> startListening({
    required void Function(String partial) onResult,
  }) async {
    if (!_isAvailable || _isListening) return;
    _isListening = true;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        final words = result.recognizedWords;
        debugPrint('[SwarmApp] ASR partial: $words');
        _transcriptController.add(words);
        onResult(words);
      },
      listenOptions: stt.SpeechListenOptions(
        onDevice: true,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
    );
  }

  /// Stops the active listening session.
  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
    debugPrint('[SwarmApp] ASR stopped');
  }

  /// Disposes the broadcast stream controller. Call on widget dispose.
  void dispose() {
    _transcriptController.close();
  }

  void _onError(SpeechRecognitionError error) {
    debugPrint('[SwarmApp] ASR error: ${error.errorMsg}');
    _isListening = false;
    _transcriptController.addError(error.errorMsg);
  }

  void _onStatus(String status) {
    debugPrint('[SwarmApp] ASR status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }
}
