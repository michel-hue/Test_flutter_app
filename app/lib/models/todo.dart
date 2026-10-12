import 'package:app/logic/dates.dart';

/// Date limite d'une tâche, avec ou sans heure.
class Echeance {
  const Echeance(this.date, {this.avecHeure = false});

  final DateTime date;
  final bool avecHeure;

  // Sans heure, la tâche est en retard seulement après la fin de la journée.
  DateTime get limite =>
      avecHeure ? date : DateTime(date.year, date.month, date.day, 23, 59);
}

/// Une tâche de la liste.
class Todo {
  Todo(
    this.title, {
    this.done = false,
    DateTime? jour,
    this.description = '',
    this.imagePath,
    DateTime? creeLe,
    this.echeance,
  }) : jour = jourDe(jour ?? DateTime.now()),
       creeLe = creeLe ?? DateTime.now();

  final String title;
  bool done;
  // Jour où la tâche est prévue (sans l'heure).
  final DateTime jour;
  final String description;
  // Chemin local de l'image choisie, ou null.
  final String? imagePath;
  final DateTime creeLe;
  final Echeance? echeance;

  /// Première lettre du titre, affichée en grand quand il n'y a pas d'image.
  String get initiale => title.isEmpty ? '?' : title[0].toUpperCase();

  bool enRetard(DateTime maintenant) =>
      !done && echeance != null && echeance!.limite.isBefore(maintenant);

  // Copie modifiée ; les booléens « retirer » remettent un champ à null.
  Todo modifie({
    String? title,
    String? description,
    DateTime? jour,
    Echeance? echeance,
    bool retirerEcheance = false,
    String? imagePath,
    bool retirerImage = false,
  }) {
    return Todo(
      title ?? this.title,
      done: done,
      jour: jour ?? this.jour,
      description: description ?? this.description,
      imagePath: retirerImage ? null : imagePath ?? this.imagePath,
      creeLe: creeLe,
      echeance: retirerEcheance ? null : echeance ?? this.echeance,
    );
  }
}
