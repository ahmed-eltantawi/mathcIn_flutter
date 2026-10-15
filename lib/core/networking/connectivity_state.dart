import 'package:equatable/equatable.dart';

enum ConnectivityStatus {
  online,
  offline,
  poorConnection,
  reconnected,
}

class ConnectivityState extends Equatable {
  const ConnectivityState({
    this.status = ConnectivityStatus.online,
  });

  final ConnectivityStatus status;

  bool get isOffline => status == ConnectivityStatus.offline;
  bool get isPoorConnection => status == ConnectivityStatus.poorConnection;
  bool get isReconnected => status == ConnectivityStatus.reconnected;
  bool get isOnline => status == ConnectivityStatus.online;

  bool get shouldShowBanner =>
      status == ConnectivityStatus.offline ||
      status == ConnectivityStatus.poorConnection ||
      status == ConnectivityStatus.reconnected;

  ConnectivityState copyWith({
    ConnectivityStatus? status,
  }) {
    return ConnectivityState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
