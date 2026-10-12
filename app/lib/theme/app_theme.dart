import 'package:flutter/material.dart';

/// Couleurs d'un thème, lues par les widgets via `Palette.of(context)`.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.fond,
    required this.carte,
    required this.champ,
    required this.bordure,
    required this.texte,
    required this.texteSecondaire,
    required this.accent,
    required this.surAccent,
    required this.caseVide,
    required this.accentSourd,
    required this.surAccentSourd,
    required this.termine,
    required this.erreur,
    required this.piste,
    required this.heroFond,
    required this.heroLettre,
    required this.bouton,
    required this.bordureBouton,
    required this.surBoutonAccent,
    required this.ombreBouton,
  });

  final Color fond;
  final Color carte;
  final Color champ;
  final Color bordure;
  final Color texte;
  final Color texteSecondaire;
  final Color accent;
  final Color surAccent;
  final Color caseVide;
  // Pastille d'une case cochée.
  final Color accentSourd;
  final Color surAccentSourd;
  // Titre d'une tâche terminée.
  final Color termine;
  final Color erreur;
  // Fond des barres de progression, séparateurs et puces inactives.
  final Color piste;
  // Bandeau des pages détail et ajout, avec l'initiale du titre.
  final Color heroFond;
  final Color heroLettre;
  // Boutons « verre » : fond translucide, liseré clair.
  final Color bouton;
  final Color bordureBouton;
  final Color surBoutonAccent;
  final List<BoxShadow> ombreBouton;

  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>()!;

  @override
  Palette copyWith() => this;

  // Pas d'animation entre les thèmes : on bascule directement.
  @override
  Palette lerp(Palette? other, double t) => t < 0.5 ? this : other ?? this;
}

/// Seul endroit où les couleurs, rayons et espacements sont définis.
/// Valeurs issues de la maquette Claude Design « MyTodoList »,
/// style « boutons-verre », thèmes sombre et clair.
class AppTheme {
  AppTheme._();

  static const Palette sombre = Palette(
    fond: Color(0xFF14141B),
    carte: Color(0xFF1E1E28),
    champ: Color(0xFF1E1E28),
    bordure: Color(0xFF2A2A36),
    texte: Color(0xFFECECF2),
    texteSecondaire: Color(0xFF8C8C9C),
    accent: Color(0xFFFF6B57),
    surAccent: Color(0xFF14141B),
    caseVide: Color(0xFF4A4A58),
    accentSourd: Color(0xFFC4574A),
    surAccentSourd: Color(0xFF14141B),
    termine: Color(0xFF5C5C6C),
    erreur: Color(0xFFFF5C7A),
    piste: Color(0xFF2A2A36),
    heroFond: Color(0xFF2B1D1F),
    heroLettre: Color(0xFFFF6B57),
    bouton: Color(0x14FFFFFF),
    bordureBouton: Color(0x24FFFFFF),
    surBoutonAccent: Color(0xFFFF6B57),
    ombreBouton: [],
  );

  static const Palette clair = Palette(
    fond: Color(0xFFF3F2EF),
    carte: Color(0xFFFFFFFF),
    champ: Color(0xFFFFFFFF),
    bordure: Color(0xFFE2E1DC),
    texte: Color(0xFF1B1B24),
    texteSecondaire: Color(0xFF6E6E7A),
    accent: Color(0xFFD9483B),
    surAccent: Color(0xFFFFFFFF),
    caseVide: Color(0xFF9A998F),
    accentSourd: Color(0xFF8E3B33),
    surAccentSourd: Color(0xFFFFFFFF),
    termine: Color(0xFFA5A5AE),
    erreur: Color(0xFFA3122A),
    piste: Color(0xFFE2E1DC),
    heroFond: Color(0xFFF6DCD6),
    heroLettre: Color(0xFF8E3B33),
    bouton: Color(0x80FFFFFF),
    bordureBouton: Color(0xE6FFFFFF),
    surBoutonAccent: Color(0xFFD9483B),
    ombreBouton: [
      BoxShadow(color: Color(0x0F1B1B24), offset: Offset(0, 2), blurRadius: 12),
    ],
  );

  static const double rayon = 14;
  static const double rayonGrand = 16;
  static const double rayonFeuille = 28;
  static const double espacementPetit = 8;
  static const double espacement = 16;
  static const double espacementPage = 24;

  static ThemeData get theme => _construire(sombre, Brightness.dark);
  static ThemeData get themeClair => _construire(clair, Brightness.light);

  static ThemeData _construire(Palette p, Brightness luminosite) {
    final schema = ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: luminosite,
    ).copyWith(
      primary: p.accent,
      onPrimary: p.surAccent,
      surface: p.fond,
      onSurface: p.texte,
      error: p.erreur,
      onError: p.surAccent,
    );
    OutlineInputBorder bord(Color couleur, [double largeur = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(rayon),
          borderSide: BorderSide(color: couleur, width: largeur),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: luminosite,
      colorScheme: schema,
      scaffoldBackgroundColor: p.fond,
      extensions: [p],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionHandleColor: p.accent,
      ),
      // Champ arrondi, fond « champ », bordure discrète puis accent au focus,
      // bordure rouge quand le titre est requis.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.champ,
        hintStyle: TextStyle(color: p.texteSecondaire),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: espacement,
          vertical: 15,
        ),
        enabledBorder: bord(p.bordure),
        focusedBorder: bord(p.accent, 1.5),
        errorBorder: bord(p.erreur, 1.5),
        focusedErrorBorder: bord(p.erreur, 1.5),
      ),
    );
  }
}
