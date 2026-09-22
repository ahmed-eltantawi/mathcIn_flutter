import 'package:equatable/equatable.dart';

class HomeDashboardEntity extends Equatable {
  const HomeDashboardEntity({
    required this.userName,
    required this.matchesCount,
  });

  final String userName;
  final int matchesCount;

  @override
  List<Object?> get props => [userName, matchesCount];
}
