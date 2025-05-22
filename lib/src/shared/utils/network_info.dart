import 'package:connectivity_plus/connectivity_plus.dart';

/// A class that provides network connectivity information and status
class NetworkInfo {
  final Connectivity _connectivity;

  /// Creates a new instance of [NetworkInfo]
  ///
  /// Uses [Connectivity] for network status and [InternetConnectionChecker] for actual internet connectivity
  NetworkInfo({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  /// Checks if the device is currently connected to the internet
  ///
  /// Returns `true` if there is an active internet connection, `false` otherwise
  Future<bool> get isNotConnected async => (await _connectivity.checkConnectivity()).isEmpty;

  /// Gets the current connectivity status
  ///
  /// Returns [List<ConnectivityResult>] indicating the type of connection:

  Future<List<ConnectivityResult>> get connectionStatus async => await _connectivity.checkConnectivity();

  /// Stream of connectivity changes
  ///
  /// Emits [List<ConnectivityResult>] whenever the connection type changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  /// Gets a detailed connection status including connection type and internet availability
  Future<NetworkStatus> get detailedStatus async {
    final connectivityResult = await connectionStatus;
    final hasInternet = await isNotConnected;

    return NetworkStatus(
      connectivityResult: connectivityResult,
      hasInternetConnection: hasInternet,
    );
  }
}

/// Represents the detailed network status
class NetworkStatus {
  final List<ConnectivityResult> connectivityResult;
  final bool hasInternetConnection;

  const NetworkStatus({
    required this.connectivityResult,
    required this.hasInternetConnection,
  });

  /// Checks if there is any type of network connection
  bool get hasConnection => connectivityResult.isNotEmpty;

  /// Gets a human-readable description of the connection status
  String get statusDescription {
    if (!hasConnection) return 'No network connection';
    if (!hasInternetConnection) return 'No internet access';

    final descriptions = connectivityResult.map((result) {
      switch (result) {
        case ConnectivityResult.wifi:
          return 'Connected to WiFi';
        case ConnectivityResult.mobile:
          return 'Connected to mobile network';
        case ConnectivityResult.ethernet:
          return 'Connected to ethernet';
        case ConnectivityResult.bluetooth:
          return 'Connected via bluetooth';
        case ConnectivityResult.vpn:
          return 'Connected via VPN';
        case ConnectivityResult.other:
          return 'Connected to other network';
        default:
          return 'Unknown connection type';
      }
    });
    return descriptions.join(', ');
  }

  @override
  String toString() => statusDescription;
}
