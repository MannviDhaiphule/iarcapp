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
}
