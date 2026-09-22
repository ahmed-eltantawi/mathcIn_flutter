import 'dart:io';
import 'dart:typed_data';

void main() {
  final bytes = File('assets/riv/delete.riv').readAsBytesSync();
  print('File length: ${bytes.length} bytes');
  
  // Rive header starts with "RIVE" or magic bytes
  final header = String.fromCharCodes(bytes.sublist(0, 4));
  print('Header: $header');

  // Let's find all length-prefixed strings or zero-terminated strings or print all printable strings with their offset
  // Rive strings are varint-length prefixed UTF-8 strings.
  final candidates = <String>[];
  int i = 0;
  while (i < bytes.length) {
    // try to read varint length
    int len = 0;
    int shift = 0;
    int j = i;
    while (j < bytes.length) {
      int b = bytes[j++];
      len |= (b & 0x7f) << shift;
      shift += 7;
      if ((b & 0x80) == 0) break;
    }
    if (len > 1 && len < 100 && j + len <= bytes.length) {
      try {
        final str = String.fromCharCodes(bytes.sublist(j, j + len));
        if (RegExp(r'^[a-zA-Z0-9_\- ]+$').hasMatch(str)) {
          if (str.length > 2 && !str.startsWith('uni') && !str.startsWith('vWeight')) {
            candidates.add('$str (at offset $i)');
          }
        }
      } catch (_) {}
    }
    i++;
  }

  print('\n=== Potential Rive Identifiers ===');
  final unique = <String>{};
  for (final c in candidates) {
    final name = c.split(' (')[0];
    if (unique.add(name)) {
      print(c);
    }
  }
}
