import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/chatbot_repository.dart';

class GetContextPreviewUseCase {
  const GetContextPreviewUseCase({required this.repository});

  final ChatbotRepository repository;

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getContextPreview();
  }
}
