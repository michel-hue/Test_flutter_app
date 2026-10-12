import 'package:app/main.dart';
import 'package:app/pages/todo_page.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Écran « Mes tâches » seul, sans passer par l'accueil.
Widget _liste() => MaterialApp(
  theme: AppTheme.theme,
  home: const TodoPage(ecranInitial: Ecran.liste),
);

Future<void> _ajouter(WidgetTester tester, String titre) async {
  await tester.enterText(find.byKey(const Key('champ_titre')), titre);
  await tester.tap(find.byKey(const Key('bouton_ajouter')));
  await tester.pump();
}

void main() {
  testWidgets('Ajouter : la tâche apparaît, le compteur suit, le champ se vide', (
    tester,
  ) async {
    // Préparer
    await tester.pumpWidget(_liste());

    // Agir
    await _ajouter(tester, 'Acheter du pain');

    // Vérifier
    expect(find.text('Acheter du pain'), findsOneWidget);
    expect(find.text('1 tâche restante'), findsOneWidget);
    final champ = tester.widget<TextField>(find.byKey(const Key('champ_titre')));
    expect(champ.controller!.text, isEmpty);
  });

  testWidgets('Titre vide : « Titre requis » et rien n’est ajouté', (
    tester,
  ) async {
    // Préparer
    await tester.pumpWidget(_liste());

    // Agir
    await tester.tap(find.byKey(const Key('bouton_ajouter')));
    await tester.pump();

    // Vérifier
    expect(find.text('Titre requis'), findsOneWidget);
    expect(find.text('Aucune tâche'), findsOneWidget);
  });

  testWidgets('Cocher : le compteur baisse', (tester) async {
    // Préparer
    await tester.pumpWidget(_liste());
    await _ajouter(tester, 'Une');
    await _ajouter(tester, 'Deux');

    // Agir
    await tester.tap(find.byKey(const Key('case_0')));
    await tester.pump();

    // Vérifier
    expect(find.text('1 tâche restante'), findsOneWidget);
  });

  testWidgets('L’app s’ouvre sur l’accueil puis va à « Mes tâches »', (
    tester,
  ) async {
    // Préparer
    await tester.pumpWidget(const MyTodoApp());
    expect(find.text('MyTodoList'), findsOneWidget);

    // Agir
    await tester.tap(find.byKey(const Key('bouton_voir_taches')));
    await tester.pumpAndSettle();

    // Vérifier
    expect(find.text('Mes tâches'), findsOneWidget);
    expect(find.text('Aucune tâche'), findsOneWidget);
  });

  testWidgets('Le bouton soleil / lune passe au thème clair', (tester) async {
    // Préparer
    await tester.pumpWidget(const MyTodoApp());
    BuildContext ctx() => tester.element(find.byType(TodoPage));
    expect(Theme.of(ctx()).brightness, Brightness.dark);

    // Agir
    await tester.tap(find.byKey(const Key('bouton_theme')));
    await tester.pumpAndSettle();

    // Vérifier
    expect(Theme.of(ctx()).brightness, Brightness.light);
  });

  testWidgets('Détail : ouvrir, marquer terminée, supprimer', (tester) async {
    // Préparer
    await tester.pumpWidget(_liste());
    await _ajouter(tester, 'Préparer les slides');

    // Agir : ouvrir le détail
    await tester.tap(find.text('Préparer les slides'));
    await tester.pump();

    // Vérifier
    expect(find.text('À faire'), findsOneWidget);
    expect(find.text('Aucune échéance'), findsOneWidget);

    // Agir : marquer comme terminée
    await tester.tap(find.byKey(const Key('detail_basculer')));
    await tester.pump();

    // Vérifier
    expect(find.text('Terminée'), findsOneWidget);
    expect(find.text('Marquer à faire'), findsOneWidget);

    // Agir : supprimer
    await tester.tap(find.byKey(const Key('detail_supprimer')));
    await tester.pump();

    // Vérifier : retour à la liste, vide
    expect(find.text('Aucune tâche'), findsOneWidget);
  });

  testWidgets('Détail : modifier le titre et la description', (tester) async {
    // Préparer
    await tester.pumpWidget(_liste());
    await _ajouter(tester, 'Brouillon');
    await tester.tap(find.text('Brouillon'));
    await tester.pump();

    // Agir
    await tester.tap(find.byKey(const Key('detail_modifier')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('edition_titre')), 'Final');
    await tester.tap(find.byKey(const Key('edition_enregistrer')));
    await tester.pump();

    // Vérifier
    expect(find.text('Final'), findsOneWidget);
    expect(find.byKey(const Key('edition_titre')), findsNothing);
  });

  testWidgets('Page d’ajout : titre requis, puis création', (tester) async {
    // Préparer
    await tester.pumpWidget(_liste());
    await tester.tap(find.byKey(const Key('bouton_details')));
    await tester.pump();

    // Agir : créer sans titre
    await tester.tap(find.byKey(const Key('bouton_creer')));
    await tester.pump();

    // Vérifier
    expect(find.text('Titre requis'), findsOneWidget);

    // Agir : saisir un titre et créer
    await tester.enterText(find.byKey(const Key('ajout_titre')), 'Répéter');
    await tester.tap(find.byKey(const Key('bouton_creer')));
    await tester.pump();

    // Vérifier : retour à la liste avec la tâche
    expect(find.text('Répéter'), findsOneWidget);
    expect(find.text('1 tâche restante'), findsOneWidget);
  });

  testWidgets('Les vues grille et compacte gardent les mêmes tâches', (
    tester,
  ) async {
    // Préparer
    await tester.pumpWidget(_liste());
    await _ajouter(tester, 'Une');
    await _ajouter(tester, 'Deux');

    // Agir
    await tester.tap(find.byTooltip('Affichage en grille'));
    await tester.pump();

    // Vérifier
    expect(find.text('Une'), findsOneWidget);
    expect(find.text('Deux'), findsOneWidget);

    // Agir
    await tester.tap(find.byTooltip('Affichage compact'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('case_1')));
    await tester.pump();

    // Vérifier
    expect(find.text('1 tâche restante'), findsOneWidget);
  });
}
