import 'package:app/logic/dates.dart';
import 'package:app/logic/todo_list.dart';
import 'package:app/models/todo.dart';
import 'package:app/pages/todo_page.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/boutons.dart';
import 'package:app/widgets/champ_description.dart';
import 'package:app/widgets/champs_date.dart';
import 'package:app/widgets/feuille.dart';
import 'package:app/widgets/hero_tache.dart';
import 'package:flutter/material.dart';

/// Détail d'une tâche (variante A retenue) : lecture, puis édition sur place.
class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
    required this.todo,
    required this.maintenant,
    required this.choisirImage,
    required this.onRetour,
    required this.onToggle,
    required this.onModifier,
    required this.onSupprimer,
  });

  final Todo todo;
  final DateTime maintenant;
  final ChoisirImage choisirImage;
  final VoidCallback onRetour;
  final VoidCallback onToggle;
  // Reçoit la tâche modifiée (titre, description, jour, échéance, image).
  final ValueChanged<Todo> onModifier;
  final VoidCallback onSupprimer;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _edition = false;
  bool _erreur = false;
  final TextEditingController _titre = TextEditingController();
  final TextEditingController _description = TextEditingController();
  late DateTime _jour;
  DateTime? _echeanceJour;
  TimeOfDay? _echeanceHeure;

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    super.dispose();
  }

  // Le brouillon part des valeurs actuelles de la tâche.
  void _commencerEdition() {
    final t = widget.todo;
    final e = t.echeance;
    setState(() {
      _titre.text = t.title;
      _description.text = t.description;
      _jour = t.jour;
      _echeanceJour = e == null ? null : jourDe(e.date);
      _echeanceHeure = e != null && e.avecHeure
          ? TimeOfDay.fromDateTime(e.date)
          : null;
      _erreur = false;
      _edition = true;
    });
  }

  void _enregistrer() {
    final titre = _titre.text.trim();
    if (titre.isEmpty) {
      setState(() => _erreur = true);
      return;
    }
    // Une heure sans date fixe l'échéance au jour prévu.
    final jourEcheance = _echeanceJour ?? (_echeanceHeure != null ? _jour : null);
    widget.onModifier(
      widget.todo.modifie(
        title: titre,
        description: _description.text.trim(),
        jour: _jour,
        echeance: jourEcheance == null
            ? null
            : Echeance(
                avecHeure(jourEcheance, _echeanceHeure),
                avecHeure: _echeanceHeure != null,
              ),
        retirerEcheance: jourEcheance == null,
      ),
    );
  }

  Future<void> _ajouterImage() async {
    final chemin = await widget.choisirImage();
    if (chemin != null && mounted) {
      widget.onModifier(widget.todo.modifie(imagePath: chemin));
    }
  }

  @override
  Widget build(BuildContext context) {
    final todo = widget.todo;
    return PageAvecFeuille(
      hauteurBandeau: _edition ? 130 : 272,
      bandeau: HeroTache(
        initiale: todo.initiale,
        imagePath: todo.imagePath,
        tailleLettre: _edition ? 72 : 132,
      ),
      surBandeau: [
        Positioned(
          top: hautBandeau(context),
          left: 16,
          child: BoutonVerre(
            key: const Key('detail_retour'),
            onPressed: widget.onRetour,
            largeur: 48,
            hauteur: 48,
            rayon: 24,
            tooltip: 'Retour',
            child: const Icon(Icons.arrow_back, size: 22),
          ),
        ),
        Positioned(
          top: hautBandeau(context),
          right: 16,
          child: BoutonVerre(
            key: const Key('detail_supprimer'),
            onPressed: widget.onSupprimer,
            largeur: 48,
            hauteur: 48,
            rayon: 24,
            tooltip: 'Supprimer la tâche',
            child: const Icon(Icons.delete_outline, size: 22),
          ),
        ),
      ],
      feuille: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: _edition ? _formulaire() : _lecture(),
      ),
    );
  }

  // ----- Lecture -----

  Widget _lecture() {
    final p = Palette.of(context);
    final todo = widget.todo;
    final retard = todo.enRetard(widget.maintenant);
    final aujourdhui = jourDe(widget.maintenant);
    final prevue = memeJour(todo.jour, aujourdhui)
        ? 'aujourd’hui'
        : memeJour(todo.jour, plusJours(aujourdhui, 1))
        ? 'demain'
        : 'le ${jourLong(todo.jour)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Etiquette(
              texte: todo.done ? 'Terminée' : 'À faire',
              bord: todo.done ? p.piste : p.accent,
              fond: todo.done ? p.piste : null,
              couleur: todo.done ? p.texteSecondaire : p.accent,
            ),
            if (retard)
              _Etiquette(texte: 'En retard', bord: p.erreur, couleur: p.erreur),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          todo.title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.2,
            color: p.texte,
          ),
        ),
        const SizedBox(height: 12),
        _ligneInfo(p, Icons.event, 'Prévue $prevue', p.texteSecondaire),
        const SizedBox(height: 8),
        _ligneInfo(
          p,
          Icons.schedule,
          todo.echeance == null
              ? 'Aucune échéance'
              : TodoList.echeanceLabel(todo, widget.maintenant),
          retard
              ? p.erreur
              : todo.echeance == null
              ? p.texteSecondaire
              : p.texte,
        ),
        const SizedBox(height: 12),
        Divider(height: 1, thickness: 1, color: p.piste),
        const SizedBox(height: 12),
        const SurTitre('Description'),
        const SizedBox(height: 12),
        Flexible(
          child: todo.description.isEmpty
              ? TextButton(
                  onPressed: _commencerEdition,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 44),
                    foregroundColor: p.texteSecondaire,
                  ),
                  child: const Text(
                    'Aucune description. Ajouter…',
                    style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                )
              : SingleChildScrollView(
                  child: Text(
                    todo.description,
                    style: TextStyle(fontSize: 15, height: 1.55, color: p.texte),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        // Pastille à liseré : ajouter l'image, ou la retirer s'il y en a une.
        Material(
          color: Colors.transparent,
          shape: StadiumBorder(side: BorderSide(color: p.caseVide)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: todo.imagePath == null
                ? _ajouterImage
                : () => widget.onModifier(todo.modifie(retirerImage: true)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                todo.imagePath == null ? 10 : 14,
                10,
                14,
                10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (todo.imagePath == null) ...[
                    Icon(Icons.image_outlined, size: 18, color: p.texte),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    todo.imagePath == null
                        ? 'Ajouter une image'
                        : 'Retirer l’image',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: p.texte,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            BoutonVerre(
              key: const Key('detail_modifier'),
              onPressed: _commencerEdition,
              largeur: 56,
              hauteur: 56,
              rayon: AppTheme.rayonGrand,
              tooltip: 'Modifier la tâche',
              child: const Icon(Icons.edit, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BoutonVerre(
                key: const Key('detail_basculer'),
                onPressed: widget.onToggle,
                hauteur: 56,
                rayon: AppTheme.rayonGrand,
                fond: todo.done ? p.carte : p.accent,
                avant: todo.done ? p.texte : p.surAccent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(todo.done ? Icons.undo : Icons.check, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      todo.done ? 'Marquer à faire' : 'Marquer comme terminée',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ligneInfo(Palette p, IconData icone, String texte, Color couleur) {
    return Row(
      children: [
        Icon(icone, size: 18, color: couleur),
        const SizedBox(width: 8),
        Expanded(
          child: Text(texte, style: TextStyle(fontSize: 14, color: couleur)),
        ),
      ],
    );
  }

  // ----- Édition -----

  Widget _formulaire() {
    final p = Palette.of(context);
    final bordureTitre = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.rayon),
      borderSide: BorderSide(color: _erreur ? p.erreur : p.accent, width: 1.5),
    );
    final aEcheance = _echeanceJour != null || _echeanceHeure != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const EtiquetteChamp('Titre'),
              const SizedBox(height: 6),
              TextField(
                key: const Key('edition_titre'),
                controller: _titre,
                onChanged: (_) {
                  if (_erreur) setState(() => _erreur = false);
                },
                style: TextStyle(fontSize: 16, color: p.texte),
                decoration: InputDecoration(
                  enabledBorder: bordureTitre,
                  focusedBorder: bordureTitre,
                ),
              ),
              if (_erreur) ...[const SizedBox(height: 6), const MessageErreur()],
              const SizedBox(height: 12),
              const EtiquetteChamp('Description'),
              const SizedBox(height: 6),
              ChampDescription(controller: _description, lignes: 4),
              const SizedBox(height: 12),
              const EtiquetteChamp('Jour prévu'),
              const SizedBox(height: 6),
              ChampDate(
                valeur: _jour,
                label: 'Jour prévu',
                onChanged: (d) => setState(() => _jour = d),
              ),
              const SizedBox(height: 12),
              const EtiquetteChamp('Échéance', suffixe: '(optionnel)'),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChampDate(
                      valeur: _echeanceJour,
                      label: 'Date limite',
                      onChanged: (d) => setState(() => _echeanceJour = d),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 110,
                    child: ChampHeure(
                      valeur: _echeanceHeure,
                      onChanged: (h) => setState(() => _echeanceHeure = h),
                    ),
                  ),
                ],
              ),
              if (aEcheance)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() {
                      _echeanceJour = null;
                      _echeanceHeure = null;
                    }),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: p.accent,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Retirer l’échéance'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BoutonVerre(
                onPressed: () => setState(() => _edition = false),
                hauteur: 52,
                rayon: AppTheme.rayonGrand,
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BoutonVerre(
                key: const Key('edition_enregistrer'),
                onPressed: _enregistrer,
                hauteur: 52,
                rayon: AppTheme.rayonGrand,
                accent: true,
                child: const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Pastille de statut (« À faire », « Terminée », « En retard »).
class _Etiquette extends StatelessWidget {
  const _Etiquette({
    required this.texte,
    required this.bord,
    required this.couleur,
    this.fond,
  });

  final String texte;
  final Color bord;
  final Color couleur;
  final Color? fond;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bord, width: 1.5),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          texte,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: couleur,
          ),
        ),
      ),
    );
  }
}
