import 'package:edhitha_team2027_swarm_interface/core/constants/command_ids.dart';
import 'package:edhitha_team2027_swarm_interface/features/voice_command/data/command_dispatcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommandDispatcher.buildPayload', () {
    late CommandDispatcher dispatcher;

    setUp(() {
      dispatcher = CommandDispatcher();
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

    test('cmdLaunch produces CMD_LAUNCH', () {
      expectPayload(CommandId.cmdLaunch, 'CMD_LAUNCH');
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

    test('cmdOrbit produces CMD_ORBIT', () {
      expectPayload(CommandId.cmdOrbit, 'CMD_ORBIT');
    });

    test('cmdLand produces CMD_LAND', () {
      expectPayload(CommandId.cmdLand, 'CMD_LAND');
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
  });
}
