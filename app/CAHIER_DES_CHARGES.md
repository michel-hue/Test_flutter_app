# MyTodoList — Cahier des charges pour Claude Code

> Ce document est la référence pour construire l'application. Lis-le en entier avant d'écrire du code.
> En cas de doute ou de contradiction, **pose la question au lieu de deviner**.

## 0. Contexte et règles de travail

- L'app sert de support à une présentation interne « Test et CI/CD pour Flutter ». Elle doit être **petite, lisible et pédagogique**. Ce n'est pas un produit.
- Le développeur travaille sous **Windows**, sans Mac. Le CI tourne sur **Linux** (GitHub Actions).
- Le dépôt Git commence au dossier parent ; le projet Flutter est dans **`app/`**.
- Le nom du package (`name:` du pubspec) est **`app`**. Ne pas le renommer. Les imports s'écrivent `package:app/...`.
- **Avance par étapes** (section 9). À la fin de chaque étape : liste les fichiers créés ou modifiés, donne la commande de vérification, puis **arrête-toi et attends la validation** avant l'étape suivante.
- Commente le code **en français** : une ligne de commentaire au-dessus de chaque bloc non évident. Pas de code mort, pas de dépendance inutile.
- Ne touche pas aux secrets ni au groupe Firebase existants. Ne modifie le pipeline que comme décrit en section 7.

## 1. Fonctionnalités (dans le périmètre)

| # | Fonctionnalité | Comportement attendu |
|---|---|---|
| F1 | Liste des tâches | Affiche les tâches dans l'ordre d'ajout. Liste vide : affiche « Aucune tâche » |
| F2 | Ajouter | Champ texte + bouton. Le titre est nettoyé (`trim`). Après un ajout réussi, le champ se vide et le message d'erreur disparaît |
| F3 | Titre obligatoire | Titre vide ou fait seulement d'espaces : affiche « Titre requis » sous le champ et n'ajoute rien |
| F4 | Cocher / décocher | Un tap sur la case inverse l'état. Une tâche terminée est barrée et prend la couleur « terminé » |
| F5 | Supprimer | Icône poubelle sur chaque tâche |
| F6 | Compteur | Nombre de tâches **non terminées** (voir textes exacts, section 3) |

**Hors périmètre :** sauvegarde des données (tout est en mémoire), connexion, serveur, build iOS, multilingue, thème sombre et clair dynamique, animations complexes.

## 2. Architecture

```
app/
  lib/
    main.dart                  runApp + MaterialApp (title: 'MyTodoList', theme: AppTheme.theme)
    theme/app_theme.dart       SEUL endroit où les couleurs, rayons et espacements sont définis
    models/todo.dart           classe Todo
    logic/todo_list.dart       logique en Dart pur (aucun import Flutter)
    widgets/todo_tile.dart     une ligne de tâche (StatelessWidget)
    pages/todo_page.dart       écran principal (StatefulWidget + setState)
  test/
    todo_list_test.dart        tests unitaires
    todo_page_test.dart        widget tests
    todo_tile_golden_test.dart golden tests (tag golden)
    goldens/                   images de référence (générées sous Linux uniquement)
  integration_test/
    parcours_test.dart         test d'intégration
  dart_test.yaml               déclare le tag golden
```

- Gestion d'état : **`setState` uniquement** (pas de bloc, provider ni riverpod).
- Supprimer l'ancien widget `MyCard` et son test `my_card_golden_test.dart` (ainsi que ses images de référence).

### 2.1 `Todo` (`models/todo.dart`)

- `final String title;`
- `bool done;` (vaut `false` par défaut)

### 2.2 `TodoList` (`logic/todo_list.dart`)

| Membre | Rôle |
|---|---|
| `List<Todo> get todos` | Liste **non modifiable** (`List.unmodifiable`) |
| `bool add(String title)` | Applique `trim`. Retourne `false` sans rien ajouter si le résultat est vide, sinon ajoute et retourne `true` |
| `void toggle(int index)` | Inverse `done` |
| `void remove(int index)` | Supprime la tâche |
| `int get remaining` | Nombre de tâches avec `done == false` |
| `static String counterLabel(int n)` | Texte du compteur (section 3) |

### 2.3 `TodoTile` (`widgets/todo_tile.dart`)

- Paramètres : `Todo todo`, `int index`, `VoidCallback onToggle`, `VoidCallback onDelete`.
- Doit pouvoir être rendu **seul** (pour le golden test), sans dépendre de `TodoPage`.

## 3. Textes exacts (les tests s'appuient dessus)

| Élément | Texte |
|---|---|
| Titre de l'écran | `Mes tâches` |
| Indication dans le champ | `Nouvelle tâche…` |
| Erreur | `Titre requis` |
| Liste vide | `Aucune tâche` |
| Compteur, n = 0 ou 1 | `{n} tâche restante` |
| Compteur, n ≥ 2 | `{n} tâches restantes` |

## 4. Keys

| Key | Élément |
|---|---|
| `Key('champ_titre')` | Champ texte |
| `Key('bouton_ajouter')` | Bouton d'ajout |
| `Key('message_erreur')` | Texte « Titre requis » |
| `Key('compteur')` | Texte du compteur |
| `Key('tache_$index')` | Ligne d'une tâche |
| `Key('case_$index')` | Case à cocher d'une tâche |
| `Key('supprimer_$index')` | Icône poubelle d'une tâche |

## 5. Design

- La maquette et les couleurs définitives seront fournies par **Claude Design**. Applique-les **uniquement** dans `theme/app_theme.dart`.
- **Interdit :** écrire une couleur en dur (`Color(0x...)`, `Colors.xxx`) en dehors de `app_theme.dart`. Les widgets lisent les couleurs via le thème ou via les constantes d'`AppTheme`.
- `AppTheme` expose au minimum : `accent`, `accentSourd` (case cochée), `fond`, `carte`, `texte`, `texteSecondaire`, `termine`, `erreur`, ainsi que `rayon` (12) et les espacements (8, 16).
- Tant que le design n'est pas fourni, utilise des valeurs provisoires neutres, signalées par un commentaire `// PROVISOIRE`.
- Style attendu : **épuré**. Grand titre, champ et bouton arrondis, cartes simples sans ombre forte, case ronde, poubelle discrète, Material 3, police par défaut (Roboto).
- Pourquoi c'est important : pendant la démo, on changera **une seule constante** (`termine` ou `accentSourd`) pour faire échouer le golden test.

## 6. Tests

### 6.1 Unitaires (`test/todo_list_test.dart`)

Chaque test suit la structure préparer / agir / vérifier, signalée par trois commentaires.

1. `add('Acheter du pain')` → retourne `true`, 1 tâche, `done == false`.
2. `add('   ')` → retourne `false`, liste toujours vide.
3. `add('  Lire  ')` → le titre enregistré est `Lire`.
4. `toggle(0)` deux fois → `done` repasse à `false`.
5. `remove(0)` → liste vide.
6. `remaining` avec 3 tâches dont 1 cochée → 2.
7. `counterLabel` : 0 → `0 tâche restante`, 1 → `1 tâche restante`, 2 → `2 tâches restantes`.

### 6.2 Widget tests (`test/todo_page_test.dart`)

1. **Ajouter :** saisir « Acheter du pain », taper sur `bouton_ajouter`, `pump` → le texte est visible, le compteur affiche `1 tâche restante`, le champ est vide.
2. **Titre vide :** taper sur `bouton_ajouter` sans saisie, `pump` → `Titre requis` est visible et `Aucune tâche` l'est toujours. *(C'est le test cassé volontairement pendant la démo.)*
3. **Cocher :** ajouter 2 tâches, taper sur `case_0`, `pump` → `1 tâche restante`.

### 6.3 Golden tests (`test/todo_tile_golden_test.dart`)

- La première ligne du fichier est `@Tags(['golden'])`.
- Deux tests : `TodoTile` non cochée → `goldens/todo_tile_non_cochee.png` ; cochée → `goldens/todo_tile_cochee.png`.
- Rendu dans un `MaterialApp` avec `AppTheme.theme`, et une taille fixe (`tester.view.physicalSize` + `devicePixelRatio = 1`, remis à zéro avec `addTearDown`).
- Pas de package externe (ni golden_toolkit ni alchemist) : uniquement `matchesGoldenFile`.
- Les références sont générées **sous Linux uniquement**, par le workflow `update-goldens.yml` (section 7). Ne jamais générer ni committer de golden depuis Windows.
- `dart_test.yaml` déclare le tag :

```yaml
tags:
  golden:
```

### 6.4 Test d'intégration (`integration_test/parcours_test.dart`)

- Ajouter `integration_test` (sdk: flutter) en `dev_dependencies`.
- Parcours : lancer l'app → ajouter 2 tâches → cocher la première → vérifier `1 tâche restante` → supprimer la seconde → vérifier `0 tâche restante`.
- Exécuté **en local** sur émulateur Android (`flutter test integration_test`). **Pas dans le pipeline.**

## 7. Pipeline (`.github/workflows/ci.yml`) : modifications

Garder tout l'existant (déclencheurs, concurrency, job `test`, job `build`, envoi Firebase, `--build-number=${{ github.run_number }}`). Ne modifier que les points suivants :

1. **Golden tests :** retirer `--exclude-tags golden` **seulement après** que les références Linux ont été committées (étape 4).
2. **En cas d'échec d'un golden :** ajouter une étape `if: failure()` qui téléverse `app/test/failures/` en artefact (images de référence, de rendu et de différence pour les slides).
3. **Signature release avec un keystore fixe :**
   - Secrets à utiliser : `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
   - Dans le job `build`, avant le build : décoder le keystore dans `app/android/app/upload-keystore.jks` et écrire `app/android/key.properties`.
   - Dans `android/app/build.gradle` ou `build.gradle.kts` (adapter au fichier existant) : `signingConfigs.release` lit `key.properties`. Si le fichier est absent (build local), on se replie sur la signature debug.
   - Ajouter au `.gitignore` : `*.jks`, `*.keystore`, `key.properties`.
   - Fournir la commande `keytool` pour générer le keystore et la commande PowerShell pour l'encoder en base64 (le développeur est sous Windows).
4. **Nouveau workflow `.github/workflows/update-goldens.yml` :**
   - Déclencheur `workflow_dispatch` (lancé à la main), sur `ubuntu-latest`, avec la **même version de Flutter** que `ci.yml`.
   - Lance `flutter test --update-goldens --tags golden` dans `app/` et téléverse `app/test/goldens/` en artefact. Le développeur le télécharge et le committe.
5. Rappel : `defaults.run.working-directory` ne s'applique pas aux étapes `uses`, donc les chemins de ces étapes doivent être préfixés par `app/`.

## 8. Commandes de vérification

| But | Commande (dans `app/`) |
|---|---|
| Analyse | `flutter analyze` (0 problème attendu) |
| Tests en local sous Windows | `flutter test --exclude-tags golden` |
| Goldens | via le workflow `update-goldens.yml`, puis le CI |
| Intégration | `flutter test integration_test` (émulateur lancé) |
| APK | `flutter build apk --release` |

## 9. Étapes de réalisation (s'arrêter après chacune)

1. `Todo` + `TodoList` + tests unitaires → `flutter test test/todo_list_test.dart` passe.
2. `AppTheme` (provisoire) + `TodoTile` + `TodoPage` + `main.dart` ; suppression de `MyCard` → l'app tourne sur le téléphone ou l'émulateur.
3. Widget tests → `flutter test --exclude-tags golden` passe.
4. Golden tests + `dart_test.yaml` + `update-goldens.yml` → références Linux générées et committées, puis exclusion retirée dans `ci.yml` → CI vert.
5. Test d'intégration → passe en local.
6. Keystore fixe → deux builds successifs du CI s'installent l'un par-dessus l'autre sans désinstallation.
7. Application du design final de Claude Design dans `app_theme.dart` → régénérer les goldens (étape 4).

## 10. Critères d'acceptation

- [ ] F1 à F6 fonctionnent sur un téléphone Android.
- [ ] `flutter analyze` : 0 problème.
- [ ] Tous les tests passent dans le CI, goldens compris.
- [ ] Une PR avec un test rouge ne peut pas être mergée (ruleset existant, check `test`).
- [ ] Une nouvelle version s'installe par-dessus l'ancienne.
- [ ] Aucune couleur en dur en dehors de `app_theme.dart`.
- [ ] Le test d'intégration passe en local.
