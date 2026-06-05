import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

/// Persists and retrieves server configuration using [SharedPreferences].
class SettingsRepository {
  static const String _keyServerIp = 'server_ip';
  static const String _keyServerPort = 'server_port';

  /// Returns the saved server IP, or [AppConstants.defaultServerIp] if not set.
  Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString(_keyServerIp) ?? AppConstants.defaultServerIp;
    debugPrint('[SwarmApp] Loaded server IP: $ip');
    return ip;
  }

  /// Returns the saved server port, or [AppConstants.defaultServerPort] if not set.
  Future<int> getServerPort() async {
    final prefs = await SharedPreferences.getInstance();
    final port = prefs.getInt(_keyServerPort) ?? AppConstants.defaultServerPort;
    debugPrint('[SwarmApp] Loaded server port: $port');
    return port;
  }

  /// Saves [ip] as the server IP address.
  Future<void> setServerIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerIp, ip);
    debugPrint('[SwarmApp] Saved server IP: $ip');
    debugPrint(
        '[SwarmApp] Verified saved IP: ${prefs.getString(_keyServerIp)}');
  }

  /// Saves [port] as the server port number.
  Future<void> setServerPort(int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyServerPort, port);
    debugPrint('[SwarmApp] Saved server port: $port');
  }

  /// Returns the full base URL: `http://<ip>:<port>`.
  Future<String> getServerUrl() async {
    final ip = await getServerIp();
    final port = await getServerPort();
    return 'http://$ip:$port';
  }

  static const String _keyMapImageUrl = 'map_image_url';
  static const String _keyPathTextUrl = 'path_text_url';

  /// Returns the saved map image URL, or [AppConstants.defaultMapImageUrl] if not set.
  Future<String> getMapImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMapImageUrl) ?? AppConstants.defaultMapImageUrl;
  }

  /// Returns the saved path text URL, or [AppConstants.defaultPathTextUrl] if not set.
  Future<String> getPathTextUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPathTextUrl) ?? AppConstants.defaultPathTextUrl;
  }

  /// Saves [url] as the map image URL.
  Future<void> setMapImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMapImageUrl, url);
  }

  /// Saves [url] as the path text URL.
  Future<void> setPathTextUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPathTextUrl, url);
  }
}
