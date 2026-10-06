import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).changePassword)),
      body: Center(child: Text(S.of(context).changePassword)),
    );
  }
}
