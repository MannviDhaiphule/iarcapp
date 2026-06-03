import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

/// Persists and retrieves server configuration using [SharedPreferences].
class SettingsRepository {
  static const String _keyServerIp = 'server_ip';
  static const String _keyServerPort = 'server_port';

  /// Returns the saved server IP, or [AppConstants.defaultServerIp] if not set.
  Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyServerIp) ?? AppConstants.defaultServerIp;
  }

  /// Returns the saved server port, or [AppConstants.defaultServerPort] if not set.
  Future<int> getServerPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyServerPort) ?? AppConstants.defaultServerPort;
  }

  /// Saves [ip] as the server IP address.
  Future<void> setServerIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerIp, ip);
  }

  /// Saves [port] as the server port number.
  Future<void> setServerPort(int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyServerPort, port);
  }

  /// Returns the full base URL: `http://<ip>:<port>`.
  Future<String> getServerUrl() async {
    final ip = await getServerIp();
    final port = await getServerPort();
    return 'http://$ip:$port';
  }
}
