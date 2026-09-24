import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class InitialsText extends StatelessWidget {
  const InitialsText({
    super.key,
    required this.companyName,
  });

  final String companyName;

  @override
  Widget build(BuildContext context) {
    return Text(
      companyInitials(companyName),
      style: context.textTheme.titleMedium,
    );
  }

  String companyInitials(String company) {
    final words = company
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return '?';

    if (words.length == 1) {
      final word = words.first;
      return word
          .substring(0, word.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }
}
