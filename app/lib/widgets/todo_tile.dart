import 'package:app/logic/todo_list.dart';
import 'package:app/models/todo.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Une ligne de tâche : case ronde, titre (et échéance), poubelle discrète.
/// Un tap sur le titre ouvre le détail quand `onOpen` est fourni.
class TodoTile extends StatelessWidget {
  const TodoTile({
    super.key,
    required this.todo,
    required this.index,
    required this.onToggle,
    required this.onDelete,
    this.onOpen,
    this.maintenant,
  });

  final Todo todo;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;
  // Heure de référence pour « En retard » (fixée dans les tests).
  final DateTime? maintenant;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final now = maintenant ?? DateTime.now();

    return Container(
      key: Key('tache_$index'),
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: p.carte,
        borderRadius: BorderRadius.circular(AppTheme.rayon),
      ),
      child: Row(
        children: [
          IconButton(
            key: Key('case_$index'),
            onPressed: onToggle,
            tooltip: '${todo.done ? 'Décocher' : 'Cocher'} ${todo.title}',
            icon: CaseRonde(cochee: todo.done),
          ),
          Expanded(
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TitreTache(todo: todo, taille: 15),
                    if (todo.echeance != null) ...[
                      const SizedBox(height: 4),
                      LigneEcheance(todo: todo, maintenant: now),
                    ],
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            key: Key('supprimer_$index'),
            onPressed: onDelete,
            tooltip: 'Supprimer ${todo.title}',
            color: p.texteSecondaire,
            icon: const Icon(Icons.delete_outline, size: 22),
          ),
        ],
      ),
    );
  }
}

/// Titre d'une tâche, barré et à la couleur « terminé » une fois cochée.
class TitreTache extends StatelessWidget {
  const TitreTache({
    super.key,
    required this.todo,
    this.taille = 15,
    this.graisse = FontWeight.w400,
    this.uneLigne = false,
  });

  final Todo todo;
  final double taille;
  final FontWeight graisse;
  final bool uneLigne;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Text(
      todo.title,
      maxLines: uneLigne ? 1 : null,
      overflow: uneLigne ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: taille,
        fontWeight: graisse,
        height: 1.3,
        color: todo.done ? p.termine : p.texte,
        decoration: todo.done ? TextDecoration.lineThrough : null,
        decorationColor: p.termine,
      ),
    );
  }
}

/// Horloge + « Avant demain à 18:00 », en rouge si la tâche est en retard.
class LigneEcheance extends StatelessWidget {
  const LigneEcheance({
    super.key,
    required this.todo,
    required this.maintenant,
    this.taille = 12,
  });

  final Todo todo;
  final DateTime maintenant;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final couleur = todo.enRetard(maintenant) ? p.erreur : p.texteSecondaire;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: taille + 2, color: couleur),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            TodoList.echeanceLabel(todo, maintenant),
            style: TextStyle(fontSize: taille, color: couleur),
          ),
        ),
      ],
    );
  }
}

/// Case ronde : contour si non cochée, pastille pleine avec coche sinon.
class CaseRonde extends StatelessWidget {
  const CaseRonde({super.key, required this.cochee, this.taille = 22});

  final bool cochee;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cochee ? p.accentSourd : null,
        border: cochee ? null : Border.all(color: p.caseVide, width: 2),
      ),
      child: cochee
          ? Icon(Icons.check, size: taille * 0.68, color: p.surAccentSourd)
          : null,
    );
  }
}
