import 'package:app/logic/dates.dart';
import 'package:app/logic/todo_list.dart';
import 'package:app/models/todo.dart';
import 'package:app/pages/accueil_page.dart';
import 'package:app/pages/ajout_page.dart';
import 'package:app/pages/calendrier_page.dart';
import 'package:app/pages/detail_page.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/boutons.dart';
import 'package:app/widgets/hero_tache.dart';
import 'package:app/widgets/todo_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Écrans de l'app, comme dans le prototype Claude Design.
enum Ecran { accueil, liste, calendrier, ajout, detail }

/// Façons d'afficher les tâches du jour.
enum Affichage { liste, grille, compacte }

/// Choix d'une image ; renvoie le chemin du fichier ou null si annulé.
typedef ChoisirImage = Future<String?> Function();

/// Écran principal. Il garde tout l'état de l'app (setState uniquement)
/// et affiche l'écran courant : accueil, liste, calendrier, ajout ou détail.
class TodoPage extends StatefulWidget {
  const TodoPage({
    super.key,
    this.ecranInitial = Ecran.accueil,
    this.onBasculerTheme,
    this.choisirImage,
  });

  final Ecran ecranInitial;
  // Absent (tests) : le bouton soleil / lune n'est pas affiché.
  final VoidCallback? onBasculerTheme;
  // Remplaçable dans les tests ; par défaut, la galerie du téléphone.
  final ChoisirImage? choisirImage;

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoList _list = TodoList();
  final TextEditingController _controller = TextEditingController();
  bool _erreur = false;

  late Ecran _ecran = widget.ecranInitial;
  DateTime _jourChoisi = jourDe(DateTime.now());
  late DateTime _moisAffiche = DateTime(_jourChoisi.year, _jourChoisi.month);
  Affichage _affichage = Affichage.liste;
  // Tâche ouverte dans le détail, et écrans où revenir.
  int _selection = -1;
  Ecran _retourDetail = Ecran.liste;
  Ecran _retourAjout = Ecran.liste;
  Ecran _retourCalendrier = Ecran.liste;
  String _titreAjout = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aller(Ecran ecran) => setState(() {
    _ecran = ecran;
    _erreur = false;
  });

  // Ajout rapide : on vide le champ et on efface l'erreur ; sinon on l'affiche.
  void _ajouter() {
    setState(() {
      if (_list.add(_controller.text, jour: _jourChoisi)) {
        _controller.clear();
        _erreur = false;
      } else {
        _erreur = true;
      }
    });
  }

  void _choisirJour(DateTime jour) => setState(() {
    _jourChoisi = jourDe(jour);
    _moisAffiche = DateTime(jour.year, jour.month);
    _erreur = false;
  });

  void _ouvrirDetail(int index) => setState(() {
    _retourDetail = _ecran == Ecran.calendrier ? Ecran.calendrier : Ecran.liste;
    _selection = index;
    _ecran = Ecran.detail;
  });

  void _fermerDetail() => setState(() {
    _ecran = _retourDetail;
    _selection = -1;
  });

  void _ouvrirAjout() => setState(() {
    _retourAjout = _ecran;
    _titreAjout = _controller.text;
    _controller.clear();
    _erreur = false;
    _ecran = Ecran.ajout;
  });

  void _ouvrirCalendrier() => setState(() {
    _retourCalendrier = _ecran == Ecran.accueil ? Ecran.accueil : Ecran.liste;
    _ecran = Ecran.calendrier;
  });

  // Bouton retour d'Android : même chemin que les flèches de l'app.
  void _retour() {
    switch (_ecran) {
      case Ecran.accueil:
        break;
      case Ecran.liste:
        _aller(Ecran.accueil);
      case Ecran.calendrier:
        _aller(_retourCalendrier);
      case Ecran.ajout:
        _aller(_retourAjout);
      case Ecran.detail:
        _fermerDetail();
    }
  }

  Future<String?> _choisirImage() async {
    if (widget.choisirImage != null) return widget.choisirImage!();
    final fichier = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    return fichier?.path;
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;

    // Pas d'AppBar : icônes de la barre d'état assorties au thème.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: sombre ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: _ecran == Ecran.accueil,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _retour();
        },
        child: Scaffold(body: _ecranCourant()),
      ),
    );
  }

  Widget _ecranCourant() {
    final maintenant = DateTime.now();
    switch (_ecran) {
      case Ecran.accueil:
        return AccueilPage(
          list: _list,
          maintenant: maintenant,
          onOuvrirListe: () => _aller(Ecran.liste),
          onOuvrirCalendrier: _ouvrirCalendrier,
          onBasculerTheme: widget.onBasculerTheme,
        );
      case Ecran.calendrier:
        return CalendrierPage(
          list: _list,
          maintenant: maintenant,
          jourChoisi: _jourChoisi,
          moisAffiche: _moisAffiche,
          onChoisirJour: _choisirJour,
          onChangerMois: (delta) => setState(
            () => _moisAffiche = DateTime(
              _moisAffiche.year,
              _moisAffiche.month + delta,
            ),
          ),
          onRetour: () => _aller(_retourCalendrier),
          onOuvrirDetail: _ouvrirDetail,
          onAjouter: _ouvrirAjout,
          onVoirListe: () => _aller(Ecran.liste),
        );
      case Ecran.ajout:
        return AjoutPage(
          titreInitial: _titreAjout,
          jourInitial: _jourChoisi,
          aujourdhui: jourDe(maintenant),
          choisirImage: _choisirImage,
          onFermer: () => _aller(_retourAjout),
          onCreer: (titre, {required jour, description = '', imagePath, echeance}) {
            final ok = _list.add(
              titre,
              jour: jour,
              description: description,
              imagePath: imagePath,
              echeance: echeance,
            );
            if (ok) {
              _choisirJour(jour);
              _aller(
                _retourAjout == Ecran.calendrier
                    ? Ecran.calendrier
                    : Ecran.liste,
              );
            }
            return ok;
          },
        );
      case Ecran.detail:
        if (_selection < 0 || _selection >= _list.todos.length) {
          return _ecranListe(maintenant);
        }
        final index = _selection;
        return DetailPage(
          // Nouvelle clé par tâche : l'édition repart de zéro.
          key: ValueKey(_list.todos[index]),
          todo: _list.todos[index],
          maintenant: maintenant,
          choisirImage: _choisirImage,
          onRetour: _fermerDetail,
          onToggle: () => setState(() => _list.toggle(index)),
          onModifier: (todo) => setState(() => _list.replace(index, todo)),
          onSupprimer: () => setState(() {
            _list.remove(index);
            _ecran = _retourDetail;
            _selection = -1;
          }),
        );
      case Ecran.liste:
        return _ecranListe(maintenant);
    }
  }

  // ----- Écran « Mes tâches » -----

  Widget _ecranListe(DateTime maintenant) {
    final p = Palette.of(context);
    final aujourdhui = jourDe(maintenant);
    final indices = _list.indicesDuJour(_jourChoisi);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _entete(p),
            const SizedBox(height: 14),
            _semaine(p, aujourdhui),
            const SizedBox(height: 14),
            _champAjout(p, aujourdhui),
            if (_erreur) ...[
              const SizedBox(height: 6),
              const MessageErreur(),
            ],
            const SizedBox(height: 14),
            _barreJour(p, aujourdhui),
            const SizedBox(height: 14),
            Expanded(
              child: indices.isEmpty
                  ? const _ListeVide()
                  : switch (_affichage) {
                      Affichage.liste => _vueListe(indices, maintenant),
                      Affichage.grille => _vueGrille(p, indices, maintenant),
                      Affichage.compacte => _vueCompacte(p, indices, maintenant),
                    },
            ),
          ],
        ),
      ),
    );
  }

  // Retour, « Mes tâches » + compteur, calendrier, thème.
  Widget _entete(Palette p) {
    return Row(
      children: [
        BoutonVerre(
          onPressed: () => _aller(Ecran.accueil),
          largeur: 44,
          tooltip: 'Retour à l’accueil',
          child: const Icon(Icons.arrow_back, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes tâches',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: p.texte,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                TodoList.counterLabel(_list.remainingDuJour(_jourChoisi)),
                key: const Key('compteur'),
                style: TextStyle(fontSize: 13, color: p.texteSecondaire),
              ),
            ],
          ),
        ),
        BoutonVerre(
          key: const Key('bouton_calendrier'),
          onPressed: _ouvrirCalendrier,
          largeur: 44,
          tooltip: 'Ouvrir le calendrier',
          child: const Icon(Icons.calendar_today, size: 20),
        ),
        if (widget.onBasculerTheme != null) ...[
          const SizedBox(width: 8),
          BoutonTheme(onPressed: widget.onBasculerTheme!),
        ],
      ],
    );
  }

  // Les 7 prochains jours ; un point sous ceux qui ont des tâches à faire.
  Widget _semaine(Palette p, DateTime aujourdhui) {
    return Row(
      children: [
        for (var k = 0; k < 7; k++) ...[
          if (k > 0) const SizedBox(width: 6),
          Expanded(child: _jourSemaine(p, plusJours(aujourdhui, k), aujourdhui)),
        ],
      ],
    );
  }

  Widget _jourSemaine(Palette p, DateTime jour, DateTime aujourdhui) {
    final choisi = memeJour(jour, _jourChoisi);
    final couleur = choisi ? p.surBoutonAccent : p.texte;
    final point = _list.aDesTachesLe(jour)
        ? (choisi ? p.surBoutonAccent : p.accent)
        : Colors.transparent;
    return Semantics(
      selected: choisi,
      child: BoutonVerre(
        onPressed: () => _choisirJour(jour),
        hauteur: 64,
        rayon: 14,
        accent: choisi,
        tooltip: libelleJour(jour, aujourdhui),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              jourCourt(jour).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w400,
                color: couleur,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${jour.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: couleur,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(shape: BoxShape.circle, color: point),
            ),
          ],
        ),
      ),
    );
  }

  // Champ arrondi + bouton « + » + bouton « nouvelle tâche avec détails ».
  Widget _champAjout(Palette p, DateTime aujourdhui) {
    final indication = memeJour(_jourChoisi, aujourdhui)
        ? 'Nouvelle tâche…'
        : 'Nouvelle tâche · ${libelleJour(_jourChoisi, aujourdhui).toLowerCase()}';
    final bordureErreur = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.rayon),
      borderSide: BorderSide(color: p.erreur, width: 1.5),
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('champ_titre'),
            controller: _controller,
            onSubmitted: (_) => _ajouter(),
            onChanged: (_) {
              if (_erreur) setState(() => _erreur = false);
            },
            textInputAction: TextInputAction.done,
            style: TextStyle(fontSize: 15, color: p.texte),
            decoration: InputDecoration(
              hintText: indication,
              enabledBorder: _erreur ? bordureErreur : null,
              focusedBorder: _erreur ? bordureErreur : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        BoutonVerre(
          key: const Key('bouton_ajouter'),
          onPressed: _ajouter,
          largeur: 50,
          hauteur: 50,
          rayon: AppTheme.rayon,
          accent: true,
          tooltip: 'Ajouter',
          child: const Icon(Icons.add, size: 26),
        ),
        const SizedBox(width: 10),
        BoutonVerre(
          key: const Key('bouton_details'),
          onPressed: _ouvrirAjout,
          largeur: 50,
          hauteur: 50,
          rayon: AppTheme.rayon,
          tooltip: 'Nouvelle tâche avec détails',
          child: const Icon(Icons.playlist_add, size: 24),
        ),
      ],
    );
  }

  // « Aujourd’hui » à gauche, choix liste / grille / compacte à droite.
  Widget _barreJour(Palette p, DateTime aujourdhui) {
    Widget choix(Affichage a, IconData icone, String label) {
      final actif = _affichage == a;
      return Semantics(
        selected: actif,
        child: Tooltip(
          message: label,
          child: Material(
            color: actif ? p.bouton : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => setState(() => _affichage = a),
              child: SizedBox(
                width: 40,
                height: 34,
                child: Icon(
                  icone,
                  size: 20,
                  color: actif ? p.surBoutonAccent : p.texteSecondaire,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            libelleJour(_jourChoisi, aujourdhui),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: p.texte,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: p.carte,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              choix(Affichage.liste, Icons.view_list, 'Affichage en liste'),
              const SizedBox(width: 2),
              choix(Affichage.grille, Icons.grid_view, 'Affichage en grille'),
              const SizedBox(width: 2),
              choix(Affichage.compacte, Icons.reorder, 'Affichage compact'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vueListe(List<int> indices, DateTime maintenant) {
    return ListView.separated(
      itemCount: indices.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, position) {
        final i = indices[position];
        return TodoTile(
          todo: _list.todos[i],
          index: position,
          maintenant: maintenant,
          onToggle: () => setState(() => _list.toggle(i)),
          onDelete: () => setState(() => _list.remove(i)),
          onOpen: () => _ouvrirDetail(i),
        );
      },
    );
  }

  // Deux colonnes de cartes avec bandeau (image ou initiale).
  Widget _vueGrille(Palette p, List<int> indices, DateTime maintenant) {
    final lignes = <Widget>[];
    for (var r = 0; r < indices.length; r += 2) {
      lignes.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _carteGrille(p, indices, r, maintenant)),
              const SizedBox(width: 10),
              Expanded(
                child: r + 1 < indices.length
                    ? _carteGrille(p, indices, r + 1, maintenant)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: lignes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, r) => lignes[r],
    );
  }

  Widget _carteGrille(
    Palette p,
    List<int> indices,
    int position,
    DateTime maintenant,
  ) {
    final i = indices[position];
    final todo = _list.todos[i];
    return Material(
      key: Key('tache_$position'),
      color: p.carte,
      borderRadius: BorderRadius.circular(AppTheme.rayonGrand),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => _ouvrirDetail(i),
            child: SizedBox(
              height: 76,
              child: HeroTache(
                initiale: todo.initiale,
                imagePath: todo.imagePath,
                tailleLettre: 38,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitreTache(todo: todo, taille: 14, graisse: FontWeight.w500),
                  if (todo.echeance != null) ...[
                    const SizedBox(height: 4),
                    LigneEcheance(todo: todo, maintenant: maintenant),
                  ],
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Transform.translate(
                        offset: const Offset(-8, 0),
                        child: IconButton(
                          key: Key('case_$position'),
                          onPressed: () => setState(() => _list.toggle(i)),
                          tooltip:
                              '${todo.done ? 'Décocher' : 'Cocher'} ${todo.title}',
                          icon: CaseRonde(cochee: todo.done),
                        ),
                      ),
                      IconButton(
                        key: Key('supprimer_$position'),
                        onPressed: () => setState(() => _list.remove(i)),
                        tooltip: 'Supprimer ${todo.title}',
                        color: p.texteSecondaire,
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Une seule carte, une ligne fine par tâche.
  Widget _vueCompacte(Palette p, List<int> indices, DateTime maintenant) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: p.carte,
          borderRadius: BorderRadius.circular(AppTheme.rayon),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: indices.length,
          itemBuilder: (_, position) {
            final i = indices[position];
            final todo = _list.todos[i];
            return Container(
              key: Key('tache_$position'),
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                border: position < indices.length - 1
                    ? Border(bottom: BorderSide(color: p.piste))
                    : null,
              ),
              child: Row(
                children: [
                  IconButton(
                    key: Key('case_$position'),
                    onPressed: () => setState(() => _list.toggle(i)),
                    tooltip:
                        '${todo.done ? 'Décocher' : 'Cocher'} ${todo.title}',
                    icon: CaseRonde(cochee: todo.done, taille: 18),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _ouvrirDetail(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 13,
                        ),
                        child: TitreTache(
                          todo: todo,
                          taille: 14,
                          uneLigne: true,
                        ),
                      ),
                    ),
                  ),
                  if (todo.echeance != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        TodoList.echeanceLabel(todo, maintenant, court: true),
                        style: TextStyle(
                          fontSize: 12,
                          color: todo.enRetard(maintenant)
                              ? p.erreur
                              : p.texteSecondaire,
                        ),
                      ),
                    ),
                  IconButton(
                    key: Key('supprimer_$position'),
                    onPressed: () => setState(() => _list.remove(i)),
                    tooltip: 'Supprimer ${todo.title}',
                    color: p.texteSecondaire,
                    icon: const Icon(Icons.delete_outline, size: 18),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// État vide : cercle discret et « Aucune tâche ».
class _ListeVide extends StatelessWidget {
  const _ListeVide();

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: p.caseVide, width: 2),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Aucune tâche',
            style: TextStyle(fontSize: 16, color: p.texteSecondaire),
          ),
        ],
      ),
    );
  }
}

/// Signature de la création d'une tâche depuis la page d'ajout.
typedef CreerTache =
    bool Function(
      String titre, {
      required DateTime jour,
      String description,
      String? imagePath,
      Echeance? echeance,
    });
