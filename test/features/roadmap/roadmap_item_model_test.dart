import 'package:MatchIn/features/roadmap/data/models/mockup_roadmap_node.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_item_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoadmapItem.buildItems', () {
    test('inserts a treasure after every 5 nodes', () {
      final items = RoadmapItem.buildItems(roadmapNodes);

      expect(roadmapNodes.length, 10);
      expect(items.length, 12);

      final treasures = items.where((item) => item.isTreasure).toList();
      expect(treasures.length, 2);
      expect(treasures[0].milestoneIndex, 1);
      expect(treasures[0].targetNodeIndex, 4);
      expect(treasures[1].milestoneIndex, 2);
      expect(treasures[1].targetNodeIndex, 9);
    });

    test('preserves node order and original indices', () {
      final items = RoadmapItem.buildItems(roadmapNodes);
      final nodes = items.where((item) => !item.isTreasure).toList();

      expect(nodes.length, 10);
      for (var i = 0; i < nodes.length; i++) {
        expect(nodes[i].taskIndex, i);
      }
    });
  });
}
