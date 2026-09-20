import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class OnboardingActionButton extends StatelessWidget {
  const OnboardingActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
  });

  final String text;
  final VoidCallback onPressed;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CustomButton(text: text, onPressed: onPressed);
  }
}
