import 'package:edhitha_team2027_swarm_interface/core/constants/command_ids.dart';
import 'package:edhitha_team2027_swarm_interface/features/voice_command/data/command_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('CommandDispatcher.buildPayload', () {
    late CommandDispatcher dispatcher;

    setUp(() {
      dispatcher = CommandDispatcher(
        serverUrl: 'http://localhost',
        missionLength: 0.0,
      );
    });

    /// Verifies all four payload fields match expectations for [id].
    void expectPayload(CommandId id, String expectedCommand) {
      final Map<String, dynamic> payload = dispatcher.buildPayload(id);
      expect(payload['command'], equals(expectedCommand));
      expect(payload['drone_id'], equals(255));
      expect(payload['param1'], equals(0.0));
      expect(payload['param2'], equals(0.0));
      expect(
        payload.keys.toSet(),
        equals({'command', 'drone_id', 'param1', 'param2'}),
      );
    }

    test('cmdLaunch produces TAKEOFF', () {
      expectPayload(CommandId.cmdLaunch, 'TAKEOFF');
    });

    test('cmdHalt produces CMD_HALT', () {
      expectPayload(CommandId.cmdHalt, 'CMD_HALT');
    });

    test('cmdDirL produces CMD_DIR_L', () {
      expectPayload(CommandId.cmdDirL, 'CMD_DIR_L');
    });

    test('cmdDirR produces CMD_DIR_R', () {
      expectPayload(CommandId.cmdDirR, 'CMD_DIR_R');
    });

    test('cmdHover produces CMD_HOVER', () {
      expectPayload(CommandId.cmdHover, 'CMD_HOVER');
    });

    test('cmdOrbit produces START_ORBIT', () {
      expectPayload(CommandId.cmdOrbit, 'START_ORBIT');
    });

    test('cmdLand produces LAND', () {
      expectPayload(CommandId.cmdLand, 'LAND');
    });

    test('cmdDirN produces CMD_DIR_N', () {
      expectPayload(CommandId.cmdDirN, 'CMD_DIR_N');
    });

    test('unknown produces UNKNOWN', () {
      expectPayload(CommandId.unknown, 'UNKNOWN');
    });

    test('payload always has exactly keys: command, drone_id, param1, param2',
        () {
      const expectedKeys = {'command', 'drone_id', 'param1', 'param2'};
      for (final id in CommandId.values) {
        final payload = dispatcher.buildPayload(id);
        expect(
          payload.keys.toSet(),
          equals(expectedKeys),
          reason: 'Failed for $id',
        );
      }
    });

    test('cmdMission with missionLength 300.0 produces param1 300.0', () {
      final d = CommandDispatcher(
        serverUrl: 'http://test',
        missionLength: 300.0,
      );
      final payload = d.buildPayload(CommandId.cmdMission);
      expect(payload['command'], equals('START_SEARCH'));
      expect(payload['drone_id'], equals(255));
      expect(payload['param1'], equals(300.0));
      expect(payload['param2'], equals(0.0));
    });

    test('cmdMission with missionLength 500.0 produces param1 500.0', () {
      final d = CommandDispatcher(
        serverUrl: 'http://test',
        missionLength: 500.0,
      );
      final payload = d.buildPayload(CommandId.cmdMission);
      expect(payload['param1'], equals(500.0));
    });

    test('non-mission command with missionLength 500.0 still sends param1 0.0',
        () {
      final d = CommandDispatcher(
        serverUrl: 'http://test',
        missionLength: 500.0,
      );
      final payload = d.buildPayload(CommandId.cmdLaunch);
      expect(payload['param1'], equals(0.0));
    });
  });

  group('CommandDispatcher — custom serverUrl', () {
    test('dispatch sends POST to <serverUrl>/cmd', () async {
      Uri? capturedUri;
      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        return http.Response('', 200);
      });

      final dispatcher = CommandDispatcher(
        serverUrl: 'http://10.0.0.1:9090',
        missionLength: 300.0,
        client: mockClient,
      );

      final result = await dispatcher.dispatch(CommandId.cmdLaunch);

      expect(result, isTrue);
      expect(capturedUri, isNotNull);
      expect(capturedUri.toString(), equals('http://10.0.0.1:9090/cmd'));
    });
  });
}
