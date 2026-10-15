// This file is used to create custom failures for the application
// Start with a generic failure class
// Then create specific failure classes for each type of failure
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});
  final String message;
}

class OfflineFailure extends Failure {
  const OfflineFailure({super.message = 'You are offline'});

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'There was a problem with the server',
    this.fieldErrors = const {},
  });

  /// Field-level validation messages keyed by field name (`errors.<field>`
  /// from the API). Empty when the failure is not a validation failure.
  /// Excluded from [props] because Dart maps compare by identity.
  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'There was a problem with the cache'});

  @override
  List<Object?> get props => [];
}

class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure({
    super.message = 'There was a problem with the cache',
  });

  @override
  List<Object?> get props => [];
}
