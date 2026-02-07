import 'package:flutter/material.dart';

/// Widget that ensures emojis render correctly across all platforms
class EmojiDisplay extends StatelessWidget {
  final String emoji;
  final double fontSize;
  final TextDecoration? decoration;

  const EmojiDisplay({
    super.key,
    required this.emoji,
    this.fontSize = 24,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: null, // Use platform default
        package: null,
        decoration: decoration,
        height: 1.0,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      textScaler: TextScaler.noScaling, // Prevent text scaling
    );
  }
}
