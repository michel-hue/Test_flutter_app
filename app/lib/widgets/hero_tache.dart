import 'dart:io';

import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Bandeau coloré d'une tâche : l'image choisie, sinon l'initiale du titre.
class HeroTache extends StatelessWidget {
  const HeroTache({
    super.key,
    required this.initiale,
    required this.imagePath,
    this.tailleLettre = 132,
    this.texteSansLettre,
  });

  // Vide : on affiche `texteSansLettre` à la place (page d'ajout).
  final String initiale;
  final String? imagePath;
  final double tailleLettre;
  final String? texteSansLettre;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    Widget contenu;
    if (imagePath != null) {
      contenu = Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Fichier supprimé entre-temps : on retombe sur l'initiale.
        errorBuilder: (_, _, _) => _lettre(p),
      );
    } else if (initiale.isEmpty && texteSansLettre != null) {
      contenu = Text(
        texteSansLettre!,
        style: TextStyle(fontSize: 14, color: p.heroLettre),
      );
    } else {
      contenu = _lettre(p);
    }
    return ColoredBox(
      color: p.heroFond,
      child: Center(child: contenu),
    );
  }

  Widget _lettre(Palette p) => Text(
    initiale,
    style: TextStyle(
      fontSize: tailleLettre,
      fontWeight: FontWeight.w700,
      height: 1,
      color: p.heroLettre,
    ),
  );
}
