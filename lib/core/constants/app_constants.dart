/// Default server connection values used throughout the application.
class AppConstants {
  AppConstants._();

  /// Default drone swarm server IP address.
  static const String defaultServerIp = '192.168.50.1';

  /// Default drone swarm server port.
  static const int defaultServerPort = 8080;

  /// Full default server base URL derived from [defaultServerIp] and [defaultServerPort].
  static const String defaultServerUrl =
      'http://$defaultServerIp:$defaultServerPort';

  /// Default URL for the live PNG map image endpoint.
  static const String defaultMapImageUrl = 'http://192.168.50.1:8080/map';

  /// Default URL for the path text endpoint.
  static const String defaultPathTextUrl = 'http://192.168.50.1:8080/path';

  /// Default mission length (seconds) sent as param1 in START_SEARCH payload.
  static const double defaultMissionLength = 300.0;
}
