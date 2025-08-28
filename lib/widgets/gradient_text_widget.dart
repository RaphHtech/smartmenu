import 'package:flutter/material.dart';

// Petit helper pour le texte en dégradé (aucun autre fichier requis)
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;

  const GradientText(
    this.text, {
    required this.gradient,
    required this.style,
    this.textAlign,
    this.maxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSingleLine = (maxLines ?? 0) == 1;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: isSingleLine ? TextOverflow.ellipsis : TextOverflow.visible,
        softWrap: !isSingleLine,
      ),
    );
  }
}
