import 'package:app/logic/dates.dart';
import 'package:app/models/todo.dart';
import 'package:app/pages/todo_page.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/boutons.dart';
import 'package:app/widgets/champ_description.dart';
import 'package:app/widgets/champs_date.dart';
import 'package:app/widgets/feuille.dart';
import 'package:app/widgets/hero_tache.dart';
import 'package:flutter/material.dart';

/// Nouvelle tâche avec détails : titre, description, jour, échéance, image.
class AjoutPage extends StatefulWidget {
  const AjoutPage({
    super.key,
    required this.titreInitial,
    required this.jourInitial,
    required this.aujourdhui,
    required this.choisirImage,
    required this.onFermer,
    required this.onCreer,
  });

  final String titreInitial;
  final DateTime jourInitial;
  final DateTime aujourdhui;
  final ChoisirImage choisirImage;
  final VoidCallback onFermer;
  // Retourne false si le titre est vide (rien n'est créé).
  final CreerTache onCreer;

  @override
  State<AjoutPage> createState() => _AjoutPageState();
}

class _AjoutPageState extends State<AjoutPage> {
  late final TextEditingController _titre = TextEditingController(
    text: widget.titreInitial,
  );
  final TextEditingController _description = TextEditingController();
  late DateTime _jour = widget.jourInitial;
  String? _imagePath;
  bool _avecEcheance = false;
  DateTime? _echeanceJour;
  TimeOfDay? _echeanceHeure;
  bool _erreur = false;

  @override
  void dispose() {
    _titre.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _ajouterImage() async {
    final chemin = await widget.choisirImage();
    if (chemin != null && mounted) setState(() => _imagePath = chemin);
  }

  void _creer() {
    final echeance = _avecEcheance && _echeanceJour != null
        ? Echeance(
            avecHeure(_echeanceJour!, _echeanceHeure),
            avecHeure: _echeanceHeure != null,
          )
        : null;
    final ok = widget.onCreer(
      _titre.text,
      jour: _jour,
      description: _description.text,
      imagePath: _imagePath,
      echeance: echeance,
    );
    if (!ok) setState(() => _erreur = true);
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final titreNet = _titre.text.trim();
    final demain = plusJours(widget.aujourdhui, 1);

    return PageAvecFeuille(
      hauteurBandeau: 172,
      bandeau: HeroTache(
        initiale: titreNet.isEmpty ? '' : titreNet[0].toUpperCase(),
        imagePath: _imagePath,
        tailleLettre: 96,
        texteSansLettre: 'L’initiale du titre s’affichera ici',
      ),
      surBandeau: [
        Positioned(
          top: hautBandeau(context),
          left: 16,
          child: BoutonVerre(
            onPressed: widget.onFermer,
            largeur: 48,
            hauteur: 48,
            rayon: 24,
            tooltip: 'Fermer sans créer',
            child: const Icon(Icons.close, size: 22),
          ),
        ),
        Positioned(
          top: hautBandeau(context),
          left: 72,
          right: 72,
          height: 48,
          child: Center(
            child: Text(
              'Nouvelle tâche',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: p.texte,
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: MediaQuery.paddingOf(context).top + 172 - 28 - 12 - 40,
          child: BoutonVerre(
            onPressed: _imagePath == null
                ? _ajouterImage
                : () => setState(() => _imagePath = null),
            hauteur: 40,
            rayon: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _imagePath == null
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_outlined, size: 18),
                        SizedBox(width: 6),
                        Text('Ajouter une image', style: TextStyle(fontSize: 14)),
                      ],
                    )
                  : const Text('Retirer l’image', style: TextStyle(fontSize: 14)),
            ),
          ),
        ),
      ],
      feuille: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const EtiquetteChamp('Titre'),
                  const SizedBox(height: 6),
                  TextField(
                    key: const Key('ajout_titre'),
                    controller: _titre,
                    autofocus: widget.titreInitial.isEmpty,
                    onChanged: (_) => setState(() => _erreur = false),
                    style: TextStyle(fontSize: 16, color: p.texte),
                    decoration: InputDecoration(
                      hintText: 'Ex. : préparer la démo',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.rayon),
                        borderSide: BorderSide(
                          color: _erreur ? p.erreur : p.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (_erreur) ...[
                    const SizedBox(height: 6),
                    const MessageErreur(),
                  ],
                  const SizedBox(height: 14),
                  const EtiquetteChamp('Description', suffixe: '(optionnel)'),
                  const SizedBox(height: 6),
                  ChampDescription(controller: _description),
                  const SizedBox(height: 14),
                  const EtiquetteChamp('Jour prévu'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Puce(
                        texte: 'Aujourd’hui',
                        actif: memeJour(_jour, widget.aujourdhui),
                        onTap: () => setState(() => _jour = widget.aujourdhui),
                      ),
                      const SizedBox(width: 8),
                      _Puce(
                        texte: 'Demain',
                        actif: memeJour(_jour, demain),
                        onTap: () => setState(() => _jour = demain),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChampDate(
                          valeur: _jour,
                          label: 'Autre date',
                          hauteur: 44,
                          rayon: 22,
                          miseEnAvant:
                              !memeJour(_jour, widget.aujourdhui) &&
                              !memeJour(_jour, demain),
                          onChanged: (d) => setState(() => _jour = d),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _carteEcheance(p),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BoutonVerre(
              key: const Key('bouton_creer'),
              onPressed: _creer,
              hauteur: 56,
              rayon: AppTheme.rayonGrand,
              accent: true,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 22),
                  SizedBox(width: 8),
                  Text('Créer la tâche'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Interrupteur « Échéance », puis date et heure limites quand il est activé.
  Widget _carteEcheance(Palette p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: p.carte,
        borderRadius: BorderRadius.circular(AppTheme.rayon),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 20, color: p.texteSecondaire),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Échéance',
                      style: TextStyle(fontSize: 15, color: p.texte),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Optionnel · date et heure limites',
                      style: TextStyle(
                        fontSize: 12,
                        color: p.texteSecondaire,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _avecEcheance,
                onChanged: (on) => setState(() {
                  _avecEcheance = on;
                  // Par défaut, l'échéance tombe le jour prévu.
                  if (on) _echeanceJour ??= _jour;
                }),
                activeTrackColor: p.accent,
                activeThumbColor: p.surAccent,
                inactiveTrackColor: p.piste,
                inactiveThumbColor: p.texteSecondaire,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ],
          ),
          if (_avecEcheance) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChampDate(
                    valeur: _echeanceJour,
                    label: 'Date limite',
                    hauteur: 44,
                    rayon: 12,
                    onChanged: (d) => setState(() => _echeanceJour = d),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 110,
                  child: ChampHeure(
                    valeur: _echeanceHeure,
                    hauteur: 44,
                    onChanged: (h) => setState(() => _echeanceHeure = h),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Puce « Aujourd'hui » / « Demain » du choix du jour.
class _Puce extends StatelessWidget {
  const _Puce({required this.texte, required this.actif, required this.onTap});

  final String texte;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: actif,
      child: BoutonVerre(
        onPressed: onTap,
        hauteur: 44,
        rayon: 22,
        accent: actif,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(texte, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
