import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/core/networking/connectivity_state.dart';
import 'package:MatchIn/core/networking/network_info.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({required this.networkInfo})
      : super(const ConnectivityState());

  final NetworkInfo networkInfo;

  Timer? _recoveryTimer;
  Timer? _pollingTimer;
  Timer? _debounceTimer;

  int _consecutiveTimeouts = 0;

  Future<void> checkConnectivity() async {
    final connected = await networkInfo.isConnected;

    if (!connected) {
      _setOffline();
    } else if (state.isOffline || state.isPoorConnection) {
      _setReconnected();
    }
  }

  void reportNetworkError({bool isTimeout = false}) {
    if (isTimeout) {
      _consecutiveTimeouts++;
      if (_consecutiveTimeouts >= 2) {
        _setPoorConnection();
      }
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _setOffline();
      });
    }
  }

  void reportNetworkSuccess() {
    _consecutiveTimeouts = 0;
    if (state.isOffline || state.isPoorConnection) {
      _setReconnected();
    }
  }

  void _setOffline() {
    if (state.status == ConnectivityStatus.offline) return;

    _recoveryTimer?.cancel();
    emit(state.copyWith(status: ConnectivityStatus.offline));
    _startPolling();
  }

  void _setPoorConnection() {
    if (state.status == ConnectivityStatus.poorConnection) return;

    _recoveryTimer?.cancel();
    emit(state.copyWith(status: ConnectivityStatus.poorConnection));
    _startPolling();
  }

  void _setReconnected() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _consecutiveTimeouts = 0;

    emit(state.copyWith(status: ConnectivityStatus.reconnected));

    _recoveryTimer?.cancel();
    _recoveryTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) {
        emit(state.copyWith(status: ConnectivityStatus.online));
      }
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Non-aggressive polling (every 20s) only while degraded or offline
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) async {
      final connected = await networkInfo.isConnected;
      if (connected) {
        _setReconnected();
      }
    });
  }

  @override
  Future<void> close() {
    _recoveryTimer?.cancel();
    _pollingTimer?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
