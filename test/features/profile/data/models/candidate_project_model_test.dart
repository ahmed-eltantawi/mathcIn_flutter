import 'package:MatchIn/features/profile/data/models/candidate_project_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CandidateProjectModel.tryParseMutation', () {
    test('returns the record for a complete mutation response', () {
      final model = CandidateProjectModel.tryParseMutation({
        'id': 5,
        'name': 'Order Engine',
        'description': 'Queue processing.',
        'technologies': ['Dart'],
        'source': 'manual',
      });

      expect(model, isNotNull);
      expect(model!.id, 5);
      expect(model.name, 'Order Engine');
      expect(model.technologies, ['Dart']);
    });

    test('returns null when id is missing or invalid', () {
      expect(
        CandidateProjectModel.tryParseMutation({'name': 'Order Engine'}),
        isNull,
      );
      expect(
        CandidateProjectModel.tryParseMutation({'id': 0, 'name': 'X'}),
        isNull,
      );
    });

    test('returns null when name is missing or blank', () {
      expect(CandidateProjectModel.tryParseMutation({'id': 5}), isNull);
      expect(
        CandidateProjectModel.tryParseMutation({'id': 5, 'name': '   '}),
        isNull,
      );
    });
  });

  group('CandidateProjectModel.fromJson', () {
    test('stays tolerant for GET list payloads', () {
      final model = CandidateProjectModel.fromJson(const {
        'id': 9,
        'name': 'Health Tracker',
      });

      expect(model.id, 9);
      expect(model.name, 'Health Tracker');
      expect(model.technologies, isEmpty);
      expect(model.source, 'manual');
    });
  });
}
