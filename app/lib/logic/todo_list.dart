import 'package:app/logic/dates.dart';
import 'package:app/models/todo.dart';

/// Logique de la liste de tâches, en Dart pur (testable sans Flutter).
class TodoList {
  final List<Todo> _todos = [];

  // Copie non modifiable : l'extérieur doit passer par add, toggle et remove.
  List<Todo> get todos => List.unmodifiable(_todos);

  int get remaining => _todos.where((todo) => !todo.done).length;

  // Retourne false sans rien ajouter si le titre nettoyé est vide.
  bool add(
    String title, {
    DateTime? jour,
    String description = '',
    String? imagePath,
    Echeance? echeance,
  }) {
    final cleaned = title.trim();
    if (cleaned.isEmpty) return false;
    _todos.add(
      Todo(
        cleaned,
        jour: jour,
        description: description.trim(),
        imagePath: imagePath,
        echeance: echeance,
      ),
    );
    return true;
  }

  void toggle(int index) {
    _todos[index].done = !_todos[index].done;
  }

  void remove(int index) {
    _todos.removeAt(index);
  }

  void replace(int index, Todo todo) {
    _todos[index] = todo;
  }

  /// Indices (dans `todos`) des tâches prévues ce jour-là, dans l'ordre d'ajout.
  List<int> indicesDuJour(DateTime jour) => [
    for (var i = 0; i < _todos.length; i++)
      if (memeJour(_todos[i].jour, jour)) i,
  ];

  int remainingDuJour(DateTime jour) =>
      _todos.where((t) => !t.done && memeJour(t.jour, jour)).length;

  int totalDuJour(DateTime jour) =>
      _todos.where((t) => memeJour(t.jour, jour)).length;

  /// Vrai si ce jour a au moins une tâche non terminée (point sous le jour).
  bool aDesTachesLe(DateTime jour) =>
      _todos.any((t) => !t.done && memeJour(t.jour, jour));

  /// Tâche non terminée dont l'échéance arrive en premier, ou null.
  Todo? get prochaineEcheance {
    final avec = _todos.where((t) => !t.done && t.echeance != null).toList()
      ..sort((a, b) => a.echeance!.limite.compareTo(b.echeance!.limite));
    return avec.isEmpty ? null : avec.first;
  }

  // En français, 0 et 1 prennent le singulier.
  static String counterLabel(int n) =>
      n < 2 ? '$n tâche restante' : '$n tâches restantes';

  /// Texte de l'échéance : long sous le titre, court dans les vues serrées.
  static String echeanceLabel(
    Todo todo,
    DateTime maintenant, {
    bool court = false,
  }) {
    final e = todo.echeance;
    if (e == null) return '';
    final heure = e.avecHeure ? heureMinute(e.date) : '';
    if (todo.enRetard(maintenant)) {
      return court
          ? 'En retard'
          : 'En retard · ${jourMoisCourt(e.date)}${heure.isEmpty ? '' : ' $heure'}';
    }
    final auj = jourDe(maintenant);
    if (court) {
      return memeJour(e.date, auj) && heure.isNotEmpty
          ? heure
          : jourMoisCourt(e.date);
    }
    final jour = memeJour(e.date, auj)
        ? 'aujourd’hui'
        : memeJour(e.date, plusJours(auj, 1))
        ? 'demain'
        : 'le ${jourMoisCourt(e.date)}';
    return 'Avant $jour${heure.isEmpty ? '' : ' à $heure'}';
  }
}
