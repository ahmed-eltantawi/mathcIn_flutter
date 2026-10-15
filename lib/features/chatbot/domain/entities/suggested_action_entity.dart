import 'package:equatable/equatable.dart';

class SuggestedActionEntity extends Equatable {
  const SuggestedActionEntity({
    required this.type,
    required this.label,
  });

  final String type;
  final String label;

  @override
  List<Object?> get props => [type, label];
}
