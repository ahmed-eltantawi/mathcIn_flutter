import 'package:MatchIn/features/roadmap/data/models/roadmap_item_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:flutter_test/flutter_test.dart';

/// Local fixture (replaces the removed static mock list): ten plain nodes.
List<RoadmapNode> tenNodes() => List.generate(
  10,
  (i) => RoadmapNode(title: 'Node $i', status: RoadmapTaskStatus.active),
);

void main() {
  group('RoadmapItem.buildItems', () {
    test('inserts a treasure after every 5 nodes', () {
      final nodes = tenNodes();
      final items = RoadmapItem.buildItems(nodes);

      expect(nodes.length, 10);
      expect(items.length, 12);

      final treasures = items.where((item) => item.isTreasure).toList();
      expect(treasures.length, 2);
      expect(treasures[0].milestoneIndex, 1);
      expect(treasures[0].targetNodeIndex, 4);
      expect(treasures[1].milestoneIndex, 2);
      expect(treasures[1].targetNodeIndex, 9);
    });

    test('preserves node order and original indices', () {
      final nodes = tenNodes();
      final items = RoadmapItem.buildItems(nodes);
      final rendered = items.where((item) => !item.isTreasure).toList();

      expect(rendered.length, 10);
      for (var i = 0; i < rendered.length; i++) {
        expect(rendered[i].taskIndex, i);
      }
    });
  });
}
