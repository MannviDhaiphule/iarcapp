import 'package:flutter_test/flutter_test.dart';
import 'package:edhitha_team2027_swarm_interface/core/constants/command_ids.dart';
import 'package:edhitha_team2027_swarm_interface/features/voice_command/domain/intent_parser.dart';

/// Unit tests for [IntentParser] — all 18 cases from PRD §12.
void main() {
  late IntentParser parser;

  setUp(() {
    parser = IntentParser();
  });

  group('IntentParser — cmdLaunch', () {
    test('parses "Launch" → cmdLaunch', () {
      expect(parser.parse('Launch'), CommandId.cmdLaunch);
    });

    test('parses "begin launch sequence" → cmdLaunch', () {
      expect(parser.parse('begin launch sequence'), CommandId.cmdLaunch);
    });

    test('parses "Take off now" → cmdLaunch', () {
      expect(parser.parse('Take off now'), CommandId.cmdLaunch);
    });

    test('parses "LAUNCH" (all caps) → cmdLaunch', () {
      expect(parser.parse('LAUNCH'), CommandId.cmdLaunch);
    });
  });

  group('IntentParser — cmdHover', () {
    test('parses "Hover in place" → cmdHover', () {
      expect(parser.parse('Hover in place'), CommandId.cmdHover);
    });
  });

  group('IntentParser — cmdOrbit', () {
    test('parses "Circle the target" → cmdOrbit', () {
      expect(parser.parse('Circle the target'), CommandId.cmdOrbit);
    });

    test('parses "orbit" → cmdOrbit', () {
      expect(parser.parse('orbit'), CommandId.cmdOrbit);
    });
  });

  group('IntentParser — cmdLand', () {
    test('parses "Land immediately" → cmdLand', () {
      expect(parser.parse('Land immediately'), CommandId.cmdLand);
    });

    test('parses "touch down" → cmdLand', () {
      expect(parser.parse('touch down'), CommandId.cmdLand);
    });
  });

  group('IntentParser — cmdDirN', () {
    test('parses "Advance to sector 4" → cmdDirN', () {
      expect(parser.parse('Advance to sector 4'), CommandId.cmdDirN);
    });

    test('parses "Move forward 10 meters" → cmdDirN', () {
      expect(parser.parse('Move forward 10 meters'), CommandId.cmdDirN);
    });
  });

  group('IntentParser — cmdDirL', () {
    test('parses "Search Left quadrant" → cmdDirL', () {
      expect(parser.parse('Search Left quadrant'), CommandId.cmdDirL);
    });
  });

  group('IntentParser — cmdDirR', () {
    test('parses "Search Right please" → cmdDirR', () {
      expect(parser.parse('Search Right please'), CommandId.cmdDirR);
    });
  });

  group('IntentParser — cmdHalt', () {
    test('parses "Stop all drones" → cmdHalt', () {
      expect(parser.parse('Stop all drones'), CommandId.cmdHalt);
    });

    test('parses "abort abort" → cmdHalt', () {
      expect(parser.parse('abort abort'), CommandId.cmdHalt);
    });
  });

  group('IntentParser — cmdMission', () {
    test('parses "start mission" → cmdMission', () {
      expect(parser.parse('start mission'), CommandId.cmdMission);
    });

    test('parses "begin mission now" → cmdMission', () {
      expect(parser.parse('begin mission now'), CommandId.cmdMission);
    });

    test('parses "initiate mission" → cmdMission', () {
      expect(parser.parse('initiate mission'), CommandId.cmdMission);
    });

    test('parses "launch mission" → cmdMission', () {
      expect(parser.parse('launch mission'), CommandId.cmdMission);
    });

    test('parses "mission" → cmdMission', () {
      expect(parser.parse('mission'), CommandId.cmdMission);
    });

    test('parses "begin mission" → cmdMission', () {
      expect(parser.parse('begin mission'), CommandId.cmdMission);
    });

    test('parses "initiate mission" (Phase 7 new) → cmdMission', () {
      expect(parser.parse('initiate mission'), CommandId.cmdMission);
    });
  });

  group('IntentParser — unknown', () {
    test('parses "hello world" → unknown', () {
      expect(parser.parse('hello world'), CommandId.unknown);
    });

    test('parses empty string → unknown', () {
      expect(parser.parse(''), CommandId.unknown);
    });

    test('parses whitespace-only string → unknown', () {
      expect(parser.parse('   '), CommandId.unknown);
    });
  });
}
