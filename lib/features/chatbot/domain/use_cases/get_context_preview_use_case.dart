import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/chatbot/domain/repositories/chatbot_repository.dart';

class GetContextPreviewUseCase {
  const GetContextPreviewUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getContextPreview();
  }
}
