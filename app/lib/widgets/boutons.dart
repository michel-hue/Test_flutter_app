import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Bouton « verre » de la maquette : fond translucide, liseré clair.
/// `accent: true` met le contenu à la couleur d'accent ; `fond` et `avant`
/// remplacent les couleurs (bouton plein « Marquer comme terminée »).
class BoutonVerre extends StatelessWidget {
  const BoutonVerre({
    super.key,
    required this.child,
    required this.onPressed,
    this.largeur,
    this.hauteur = 44,
    this.rayon = 22,
    this.accent = false,
    this.fond,
    this.avant,
    this.tooltip,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double? largeur;
  final double hauteur;
  final double rayon;
  final bool accent;
  final Color? fond;
  final Color? avant;
  // Texte lu par le lecteur d'écran pour un bouton qui n'a qu'une icône.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final couleurAvant = avant ?? (accent ? p.surBoutonAccent : p.texte);
    final forme = BorderRadius.circular(rayon);

    Widget bouton = DecoratedBox(
      decoration: BoxDecoration(borderRadius: forme, boxShadow: p.ombreBouton),
      child: Material(
        color: fond ?? p.bouton,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: forme,
          side: fond == null
              ? BorderSide(color: p.bordureBouton)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: largeur,
            height: hauteur,
            child: IconTheme.merge(
              data: IconThemeData(color: couleurAvant),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: couleurAvant,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
    if (tooltip != null) bouton = Tooltip(message: tooltip!, child: bouton);
    return bouton;
  }
}

/// Bouton soleil / lune qui bascule entre les thèmes sombre et clair.
class BoutonTheme extends StatelessWidget {
  const BoutonTheme({super.key, required this.onPressed, this.taille = 44});

  final VoidCallback onPressed;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return BoutonVerre(
      key: const Key('bouton_theme'),
      onPressed: onPressed,
      largeur: taille,
      hauteur: taille,
      rayon: taille / 2,
      tooltip: sombre ? 'Passer au thème clair' : 'Passer au thème sombre',
      child: Icon(sombre ? Icons.light_mode : Icons.dark_mode, size: 21),
    );
  }
}

/// Petit libellé au-dessus d'un champ de formulaire.
class EtiquetteChamp extends StatelessWidget {
  const EtiquetteChamp(this.texte, {super.key, this.suffixe});

  final String texte;
  final String? suffixe;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Text.rich(
      TextSpan(
        text: texte,
        children: [
          if (suffixe != null)
            TextSpan(
              text: ' $suffixe',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
        ],
      ),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: p.texteSecondaire,
      ),
    );
  }
}

/// Titre de section en petites capitales (« AUJOURD'HUI », « DESCRIPTION »).
class SurTitre extends StatelessWidget {
  const SurTitre(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(
      texte.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: Palette.of(context).texteSecondaire,
      ),
    );
  }
}

/// Message « Titre requis » sous un champ.
class MessageErreur extends StatelessWidget {
  const MessageErreur({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'Titre requis',
        key: const Key('message_erreur'),
        style: TextStyle(fontSize: 13, color: Palette.of(context).erreur),
      ),
    );
  }
}
