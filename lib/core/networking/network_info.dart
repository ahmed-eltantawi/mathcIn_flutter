import 'dart:async';
import 'dart:io';

///* abstract class to get information about the network
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

///* implementation of NetworkInfo
///* Checks several public DNS hosts concurrently and shares the result briefly
///* so repositories do not serialize multiple long DNS lookups.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({
    this.lookupTimeout = const Duration(milliseconds: 1800),
    this.cacheDuration = const Duration(seconds: 3),
  });

  final Duration lookupTimeout;
  final Duration cacheDuration;

  bool? _cachedResult;
  DateTime? _cachedAt;
  Future<bool>? _inFlight;

  @override
  Future<bool> get isConnected {
    final cachedAt = _cachedAt;
    final cachedResult = _cachedResult;
    if (cachedAt != null &&
        cachedResult != null &&
        DateTime.now().difference(cachedAt) < cacheDuration) {
      return Future.value(cachedResult);
    }
    final activeCheck = _inFlight;
    if (activeCheck != null) return activeCheck;

    final check = _probe();
    _inFlight = check;
    return check.whenComplete(() {
      if (identical(_inFlight, check)) _inFlight = null;
    });
  }

  Future<bool> _probe() async {
    const hosts = ['google.com', 'cloudflare.com', 'apple.com'];
    final completer = Completer<bool>();
    var remaining = hosts.length;

    for (final host in hosts) {
      InternetAddress.lookup(host).timeout(lookupTimeout).then((result) {
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty &&
            !completer.isCompleted) {
          completer.complete(true);
        }
      }).catchError((Object _) {}).whenComplete(() {
        remaining--;
        if (remaining == 0 && !completer.isCompleted) {
          completer.complete(false);
        }
      });
    }

    bool connected;
    try {
      connected = await completer.future.timeout(
        lookupTimeout,
        onTimeout: () => false,
      );
    } on SocketException {
      connected = false;
    } on TimeoutException {
      connected = false;
    }
    _cachedResult = connected;
    _cachedAt = DateTime.now();
    return connected;
  }
}
