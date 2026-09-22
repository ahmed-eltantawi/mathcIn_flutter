import 'dart:io';

void main() {
  final bytes = File('assets/riv/delete.riv').readAsBytesSync();
  final content = String.fromCharCodes(bytes);
  
  // Let's search around offset 1648500
  final sub = bytes.sublist(1648500, 1649320);
  print('Sublist string representation:');
  for (int i = 0; i < sub.length; i++) {
    int b = sub[i];
    if (b >= 32 && b <= 126) {
      stdout.write(String.fromCharCode(b));
    } else {
      stdout.write(' [${b.toRadixString(16)}] ');
    }
  }
  print('');
}
