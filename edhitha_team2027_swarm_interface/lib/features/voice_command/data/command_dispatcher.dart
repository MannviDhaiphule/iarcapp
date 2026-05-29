import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/command_ids.dart';

/// Sends drone commands to the swarm HTTP server via HTTP POST.
class CommandDispatcher {
  static const String _baseUrl = 'http://192.168.50.1:8080';

  /// POSTs [command] to the swarm server endpoint `/cmd`.
  ///
  /// Returns `true` when the server responds with HTTP 200.
  /// Returns `false` on non-200 responses (logged via the caller).
  /// Throws [CommandDispatchException] if the network is unreachable.
  Future<bool> dispatch(CommandId command) async {
    final uri = Uri.parse('$_baseUrl/cmd');
    final body = jsonEncode(buildPayload(command));
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on SocketException catch (e) {
      throw CommandDispatchException('Network unreachable: $e');
    }
  }

  /// Builds the JSON payload map for [command].
  ///
  /// Always uses `drone_id` 255 (broadcast) with zero `param1`/`param2`.
  Map<String, dynamic> buildPayload(CommandId command) {
    return {
      'command': command.label,
      'drone_id': 255,
      'param1': 0.0,
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
