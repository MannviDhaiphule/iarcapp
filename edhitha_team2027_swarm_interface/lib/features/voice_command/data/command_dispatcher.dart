import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/command_ids.dart';

/// Sends drone commands to the swarm HTTP server via HTTP POST.
class CommandDispatcher {
  /// Creates a [CommandDispatcher] targeting [serverUrl].
  ///
  /// Supply an optional [client] for dependency injection in tests.
  /// Supply [missionLength] to override param1 for START_SEARCH (default 300.0).
  CommandDispatcher({
    required String serverUrl,
    double missionLength = 300.0,
    http.Client? client,
  })  : _serverUrl = serverUrl,
        _missionLength = missionLength,
        _client = client ?? http.Client();

  final String _serverUrl;
  final double _missionLength;
  final http.Client _client;

  /// POSTs [command] to `<serverUrl>/cmd`.
  ///
  /// Returns `true` on HTTP 200, `false` on non-200.
  /// Throws [CommandDispatchException] if the network is unreachable.
  Future<bool> dispatch(CommandId command) async {
    final uri = Uri.parse('$_serverUrl/cmd');
    final body = jsonEncode(buildPayload(command));
    try {
      debugPrint('[SwarmApp] POST $uri');
      debugPrint('[SwarmApp] BODY $body');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) return true;
      return false;
    } on SocketException catch (e) {
      throw CommandDispatchException('Network unreachable: $e');
    }
  }

  /// Builds the JSON payload map for [command].
  ///
  /// Uses [_missionLength] as param1 when command is [CommandId.cmdMission];
  /// all other commands send param1: 0.0.
  Map<String, dynamic> buildPayload(CommandId command) {
    return {
      'command': command.label,
      'drone_id': 255,
      'param1': command == CommandId.cmdMission ? _missionLength : 0.0,
      'param2': 0.0,
    };
  }
}

/// Thrown by [CommandDispatcher] when the network is unreachable.
class CommandDispatchException implements Exception {
  /// Human-readable description of the network failure.
  final String message;

  /// Creates a [CommandDispatchException] with [message].
  const CommandDispatchException(this.message);

  @override
  String toString() => 'CommandDispatchException: $message';
}
