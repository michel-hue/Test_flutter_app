import 'package:app/logic/dates.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Champ qui affiche une date et ouvre le sélecteur de date au tap.
class ChampDate extends StatelessWidget {
  const ChampDate({
    super.key,
    required this.valeur,
    required this.onChanged,
    required this.label,
    this.hauteur = 48,
    this.rayon = AppTheme.rayon,
    this.miseEnAvant = false,
  });

  final DateTime? valeur;
  final ValueChanged<DateTime> onChanged;
  // Texte lu par le lecteur d'écran, et affiché quand il n'y a pas de date.
  final String label;
  final double hauteur;
  final double rayon;
  // Bordure accent (date choisie hors « Aujourd'hui » et « Demain »).
  final bool miseEnAvant;

  Future<void> _choisir(BuildContext context) async {
    final maintenant = DateTime.now();
    final choix = await showDatePicker(
      context: context,
      initialDate: valeur ?? maintenant,
      firstDate: DateTime(maintenant.year - 1),
      lastDate: DateTime(maintenant.year + 5),
      helpText: label,
    );
    if (choix != null) onChanged(jourDe(choix));
  }

  @override
  Widget build(BuildContext context) {
    return _ChampTap(
      onTap: () => _choisir(context),
      icone: Icons.event,
      texte: valeur == null ? label : dateCourte(valeur!),
      vide: valeur == null,
      label: label,
      hauteur: hauteur,
      rayon: rayon,
      miseEnAvant: miseEnAvant,
    );
  }
}

/// Champ qui affiche une heure (« 18:00 ») et ouvre le sélecteur d'heure.
class ChampHeure extends StatelessWidget {
  const ChampHeure({
    super.key,
    required this.valeur,
    required this.onChanged,
    this.hauteur = 48,
  });

  final TimeOfDay? valeur;
  final ValueChanged<TimeOfDay> onChanged;
  final double hauteur;

  Future<void> _choisir(BuildContext context) async {
    final choix = await showTimePicker(
      context: context,
      initialTime: valeur ?? const TimeOfDay(hour: 18, minute: 0),
      helpText: 'Heure limite',
    );
    if (choix != null) onChanged(choix);
  }

  @override
  Widget build(BuildContext context) {
    final texte = valeur == null
        ? '--:--'
        : '${valeur!.hour.toString().padLeft(2, '0')}:'
              '${valeur!.minute.toString().padLeft(2, '0')}';
    return _ChampTap(
      onTap: () => _choisir(context),
      icone: Icons.schedule,
      texte: texte,
      vide: valeur == null,
      label: 'Heure limite',
      hauteur: hauteur,
      rayon: AppTheme.rayon,
    );
  }
}

// Base commune : boîte arrondie au style d'un champ texte.
class _ChampTap extends StatelessWidget {
  const _ChampTap({
    required this.onTap,
    required this.icone,
    required this.texte,
    required this.vide,
    required this.label,
    required this.hauteur,
    required this.rayon,
    this.miseEnAvant = false,
  });

  final VoidCallback onTap;
  final IconData icone;
  final String texte;
  final bool vide;
  final String label;
  final double hauteur;
  final double rayon;
  final bool miseEnAvant;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: p.champ,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rayon),
          side: miseEnAvant
              ? BorderSide(color: p.accent, width: 1.5)
              : BorderSide(color: p.bordure),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: hauteur,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icone, size: 18, color: p.texteSecondaire),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      texte,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: vide ? p.texteSecondaire : p.texte,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convertit date + heure facultative en échéance du modèle.
DateTime avecHeure(DateTime jour, TimeOfDay? heure) => heure == null
    ? jourDe(jour)
    : DateTime(jour.year, jour.month, jour.day, heure.hour, heure.minute);
