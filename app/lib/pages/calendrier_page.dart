import 'package:app/logic/dates.dart';
import 'package:app/logic/todo_list.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/boutons.dart';
import 'package:flutter/material.dart';

/// Calendrier du mois : choisir un jour, voir ses tâches, en ajouter.
class CalendrierPage extends StatelessWidget {
  const CalendrierPage({
    super.key,
    required this.list,
    required this.maintenant,
    required this.jourChoisi,
    required this.moisAffiche,
    required this.onChoisirJour,
    required this.onChangerMois,
    required this.onRetour,
    required this.onOuvrirDetail,
    required this.onAjouter,
    required this.onVoirListe,
  });

  final TodoList list;
  final DateTime maintenant;
  final DateTime jourChoisi;
  // Premier jour du mois affiché.
  final DateTime moisAffiche;
  final ValueChanged<DateTime> onChoisirJour;
  // -1 : mois précédent, +1 : mois suivant.
  final ValueChanged<int> onChangerMois;
  final VoidCallback onRetour;
  final ValueChanged<int> onOuvrirDetail;
  final VoidCallback onAjouter;
  final VoidCallback onVoirListe;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final aujourdhui = jourDe(maintenant);
    final indices = list.indicesDuJour(jourChoisi);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                BoutonVerre(
                  onPressed: onRetour,
                  largeur: 44,
                  tooltip: 'Retour',
                  child: const Icon(Icons.arrow_back, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Calendrier',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: p.texte,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.espacement),
            _grilleMois(p, aujourdhui),
            const SizedBox(height: AppTheme.espacement),
            Row(
              children: [
                Expanded(
                  child: Text(
                    libelleJour(jourChoisi, aujourdhui),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: p.texte,
                    ),
                  ),
                ),
                Text(
                  TodoList.counterLabel(list.remainingDuJour(jourChoisi)),
                  style: TextStyle(fontSize: 13, color: p.texteSecondaire),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.espacement),
            Expanded(
              child: indices.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Text(
                        'Rien de prévu ce jour-là.',
                        style: TextStyle(
                          fontSize: 14,
                          color: p.texteSecondaire,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: indices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, k) => _ligneTache(p, indices[k]),
                    ),
            ),
            const SizedBox(height: AppTheme.espacement),
            Row(
              children: [
                BoutonVerre(
                  onPressed: onAjouter,
                  largeur: 52,
                  hauteur: 52,
                  rayon: AppTheme.rayonGrand,
                  tooltip: 'Ajouter une tâche à ce jour',
                  child: const Icon(Icons.add, size: 26),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BoutonVerre(
                    onPressed: onVoirListe,
                    hauteur: 52,
                    rayon: AppTheme.rayonGrand,
                    accent: true,
                    child: const Text(
                      'Voir ce jour dans Mes tâches',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Carte du mois : navigation, initiales des jours, grille de 7 colonnes.
  Widget _grilleMois(Palette p, DateTime aujourdhui) {
    // Lundi = colonne 0 : nombre de cases vides avant le 1er du mois.
    final decalage = moisAffiche.weekday - 1;
    final nbJours = DateTime(moisAffiche.year, moisAffiche.month + 1, 0).day;
    final cases = <Widget>[
      for (var b = 0; b < decalage; b++) const SizedBox(height: 44),
      for (var n = 1; n <= nbJours; n++)
        _caseJour(
          p,
          DateTime(moisAffiche.year, moisAffiche.month, n),
          aujourdhui,
        ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: p.carte,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onChangerMois(-1),
                tooltip: 'Mois précédent',
                color: p.texte,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                moisAnnee(moisAffiche),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: p.texte,
                ),
              ),
              IconButton(
                onPressed: () => onChangerMois(1),
                tooltip: 'Mois suivant',
                color: p.texte,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final l in ['L', 'M', 'M', 'J', 'V', 'S', 'D'])
                Expanded(
                  child: Text(
                    l,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: p.texteSecondaire),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            mainAxisExtent: 44,
            children: cases,
          ),
        ],
      ),
    );
  }

  Widget _caseJour(Palette p, DateTime jour, DateTime aujourdhui) {
    final choisi = memeJour(jour, jourChoisi);
    final estAujourdhui = memeJour(jour, aujourdhui);
    final point = list.aDesTachesLe(jour)
        ? (choisi ? p.surBoutonAccent : p.accent)
        : Colors.transparent;
    return Semantics(
      selected: choisi,
      child: Tooltip(
        message: libelleJour(jour, aujourdhui),
        child: Material(
          color: choisi ? p.bouton : Colors.transparent,
          shape: StadiumBorder(
            side: choisi
                ? BorderSide(color: p.bordureBouton)
                : estAujourdhui
                ? BorderSide(color: p.accent, width: 1.5)
                : BorderSide.none,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onChoisirJour(jour),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${jour.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: choisi ? p.surBoutonAccent : p.texte,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: point,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Ligne simple : pastille (accent si à faire), titre, échéance courte.
  Widget _ligneTache(Palette p, int i) {
    final todo = list.todos[i];
    return Material(
      color: p.carte,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onOuvrirDetail(i),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: todo.done ? p.caseVide : p.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: todo.done ? p.termine : p.texte,
                      decoration: todo.done
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: p.termine,
                    ),
                  ),
                ),
                if (todo.echeance != null)
                  Text(
                    TodoList.echeanceLabel(todo, maintenant, court: true),
                    style: TextStyle(
                      fontSize: 12,
                      color: todo.enRetard(maintenant)
                          ? p.erreur
                          : p.texteSecondaire,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
