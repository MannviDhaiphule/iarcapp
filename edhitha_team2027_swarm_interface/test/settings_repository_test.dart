import 'package:edhitha_team2027_swarm_interface/core/constants/app_constants.dart';
import 'package:edhitha_team2027_swarm_interface/features/settings/data/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getServerIp returns default when nothing saved', () async {
      final repo = SettingsRepository();
      expect(
        await repo.getServerIp(),
        equals(AppConstants.defaultServerIp),
      );
    });

    test('getServerPort returns default when nothing saved', () async {
      final repo = SettingsRepository();
      expect(
        await repo.getServerPort(),
        equals(AppConstants.defaultServerPort),
      );
    });

    test('setServerIp / getServerIp round-trip', () async {
      final repo = SettingsRepository();
      await repo.setServerIp('10.0.0.1');
      expect(await repo.getServerIp(), equals('10.0.0.1'));
    });

    test('setServerPort / getServerPort round-trip', () async {
      final repo = SettingsRepository();
      await repo.setServerPort(9090);
      expect(await repo.getServerPort(), equals(9090));
    });

    test('getServerUrl returns correctly formatted URL', () async {
      final repo = SettingsRepository();
      await repo.setServerIp('10.0.0.1');
      await repo.setServerPort(9090);
      expect(await repo.getServerUrl(), equals('http://10.0.0.1:9090'));
    });
  });
}
