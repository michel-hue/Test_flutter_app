import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Description sur plusieurs lignes, limitée à 500 caractères (« 12 / 500 »).
class ChampDescription extends StatelessWidget {
  const ChampDescription({super.key, required this.controller, this.lignes = 3});

  final TextEditingController controller;
  final int lignes;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return TextField(
      controller: controller,
      minLines: lignes,
      maxLines: lignes,
      maxLength: 500,
      style: TextStyle(fontSize: 15, height: 1.5, color: p.texte),
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => Text(
            '$currentLength / $maxLength',
            style: TextStyle(fontSize: 12, color: p.texteSecondaire),
          ),
      decoration: const InputDecoration(
        hintText: 'Ajoute des détails…',
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
