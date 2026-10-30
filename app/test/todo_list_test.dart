import 'package:app/logic/todo_list.dart';
import 'package:app/models/todo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('add ajoute une tâche non terminée et retourne true', () {
    // Préparer
    final list = TodoList();

    // Agir
    final result = list.add('Acheter du pain');

    // Vérifier
    expect(result, isTrue);
    expect(list.todos.length, 1);
    expect(list.todos.first.done, isFalse);
  });

  test('add refuse un titre fait seulement d\'espaces', () {
    // Préparer
    final list = TodoList();

    // Agir
    final result = list.add(' ');

    // Vérifier
    expect(result, isFalse);
    expect(list.todos, isEmpty);
  });

  test('add enregistre le titre sans les espaces autour', () {
    // Préparer
    final list = TodoList();

    // Agir
    list.add('  Lire  ');

    // Vérifier
    expect(list.todos.first.title, 'Lire');
  });

  test('toggle deux fois remet done à false', () {
    // Préparer
    final list = TodoList()..add('Lire');

    // Agir
    list.toggle(0);
    list.toggle(0);

    // Vérifier
    expect(list.todos.first.done, isFalse);
  });

  test('remove supprime la tâche', () {
    // Préparer
    final list = TodoList()..add('Lire');

    // Agir
    list.remove(0);

    // Vérifier
    expect(list.todos, isEmpty);
  });

  test('remaining compte les tâches non terminées', () {
    // Préparer
    final list = TodoList()
      ..add('Lire')
      ..add('Courir')
      ..add('Cuisiner');

    // Agir
    list.toggle(1);

    // Vérifier
    expect(list.remaining, 2);
  });

  test('counterLabel accorde le singulier et le pluriel', () {
    // Préparer
    const valeurs = [0, 1, 2];

    // Agir
    final labels = valeurs.map(TodoList.counterLabel).toList();

    // Vérifier
    expect(labels, [
      '0 tâche restante',
      '1 tâche restante',
      '2 tâches restantes',
    ]);
  });

  test('indicesDuJour et remainingDuJour filtrent par jour prévu', () {
    // Préparer
    final lundi = DateTime(2026, 10, 12);
    final mardi = DateTime(2026, 10, 13);
    final list = TodoList()
      ..add('A', jour: lundi)
      ..add('B', jour: mardi)
      ..add('C', jour: lundi);

    // Agir
    list.toggle(2);

    // Vérifier
    expect(list.indicesDuJour(lundi), [0, 2]);
    expect(list.remainingDuJour(lundi), 1);
    expect(list.aDesTachesLe(mardi), isTrue);
  });

  test('prochaineEcheance ignore les tâches terminées', () {
    // Préparer
    final list = TodoList()
      ..add('Tôt', echeance: Echeance(DateTime(2026, 10, 10)))
      ..add('Tard', echeance: Echeance(DateTime(2026, 10, 20)));

    // Agir
    list.toggle(0);

    // Vérifier
    expect(list.prochaineEcheance!.title, 'Tard');
  });

  test('echeanceLabel : à venir, court et en retard', () {
    // Préparer
    final maintenant = DateTime(2026, 10, 9, 10);
    final ce18h = Todo(
      'Slides',
      echeance: Echeance(DateTime(2026, 10, 9, 18), avecHeure: true),
    );
    final hier = Todo('Goldens', echeance: Echeance(DateTime(2026, 10, 8)));

    // Agir
    final long = TodoList.echeanceLabel(ce18h, maintenant);
    final court = TodoList.echeanceLabel(ce18h, maintenant, court: true);
    final retard = TodoList.echeanceLabel(hier, maintenant);

    // Vérifier
    expect(long, 'Avant aujourd’hui à 18:00');
    expect(court, '18:00');
    expect(retard, 'En retard · 8 oct.');
    expect(hier.enRetard(maintenant), isTrue);
  });
}
