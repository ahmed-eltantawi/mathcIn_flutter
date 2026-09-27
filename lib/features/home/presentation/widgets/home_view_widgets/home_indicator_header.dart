import 'package:flutter/material.dart';

class HomeInicatorHeader extends StatelessWidget {
  const HomeInicatorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // مؤقتًا Loading بسيط، ممكن نستبدلها بـ AppShimmer بتاعك لاحقًا
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
