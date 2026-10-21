import 'package:MatchIn/features/roadmap/domain/entities/generate_roadmap_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenerateRoadmapParams', () {
    test('serializes the full supported request', () {
      const params = GenerateRoadmapParams(
        targetRole: 'Backend Engineer',
        notes: 'Focus on distributed systems',
      );

      expect(params.toJson(), {
        'target_type': 'role',
        'target_role': 'Backend Engineer',
        'notes': 'Focus on distributed systems',
      });
    });

    test('omits unset optional values', () {
      const params = GenerateRoadmapParams(targetRole: 'Backend Engineer');

      expect(params.toJson(), {
        'target_type': 'role',
        'target_role': 'Backend Engineer',
      });
    });

    test('pins target_type to the only confirmed value', () {
      expect(GenerateRoadmapParams.targetType, 'role');
    });

    test('serializes the logged role request verbatim', () {
      const params = GenerateRoadmapParams(
        targetRole: 'Flutter',
        notes: 'I need to study kotiln too',
      );

      expect(params.toJson(), {
        'target_type': 'role',
        'target_role': 'Flutter',
        'notes': 'I need to study kotiln too',
      });
    });
  });
}
