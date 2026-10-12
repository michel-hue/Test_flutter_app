import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Mise en page des pages détail et ajout : un bandeau en haut, des boutons
/// posés dessus, et une feuille arrondie qui remonte de 28 px sur le bandeau.
class PageAvecFeuille extends StatelessWidget {
  const PageAvecFeuille({
    super.key,
    required this.hauteurBandeau,
    required this.bandeau,
    required this.surBandeau,
    required this.feuille,
  });

  final double hauteurBandeau;
  final Widget bandeau;
  // Boutons et textes posés sur le bandeau (dans un Stack).
  final List<Widget> surBandeau;
  final Widget feuille;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    // Le bandeau passe sous la barre d'état : on le rallonge d'autant.
    final haut = MediaQuery.paddingOf(context).top;
    final hauteur = hauteurBandeau + haut;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: hauteur,
          child: bandeau,
        ),
        ...surBandeau,
        Positioned.fill(
          top: hauteur - AppTheme.rayonFeuille,
          child: Container(
            decoration: BoxDecoration(
              color: p.fond,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.rayonFeuille),
              ),
            ),
            child: SafeArea(top: false, child: feuille),
          ),
        ),
      ],
    );
  }
}

/// Position d'un bouton rond en haut du bandeau, sous la barre d'état.
double hautBandeau(BuildContext context) =>
    MediaQuery.paddingOf(context).top + 8;
