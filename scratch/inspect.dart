import 'dart:io';

void main() {
  final file = File('assets/riv/delete.riv');
  final bytes = file.readAsBytesSync();
  final content = String.fromCharCodes(bytes);
  final regex = RegExp(r'[a-zA-Z0-9_\-\s]{3,}');
  final matches = regex.allMatches(content).map((m) => m.group(0)!).toSet().toList()..sort();
  for (final m in matches) {
    if (!m.startsWith('uni') && !m.startsWith('vWeight') && m.length < 50 && m.length > 2) {
      print(m);
    }
  }
}
