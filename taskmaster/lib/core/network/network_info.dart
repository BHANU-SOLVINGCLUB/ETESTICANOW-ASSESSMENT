import 'package:connectivity_plus/connectivity_plus.dart';
import '../logger/app_logger.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = !results.contains(ConnectivityResult.none);
      AppLogger.debug('Network status: ${isConnected ? 'Connected' : 'Disconnected'}');
      return isConnected;
    } catch (e) {
      AppLogger.error('Error checking connectivity', e);
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final isConnected = !results.contains(ConnectivityResult.none);
      AppLogger.debug('Network status changed: ${isConnected ? 'Connected' : 'Disconnected'}');
      return isConnected;
    });
  }
}
