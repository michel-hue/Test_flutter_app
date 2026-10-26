import 'package:app/logic/dates.dart';
import 'package:app/logic/todo_list.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/widgets/boutons.dart';
import 'package:app/widgets/logo.dart';
import 'package:flutter/material.dart';

/// Page d'accueil : logo, slogan, carte « Aujourd'hui » avec la progression.
class AccueilPage extends StatelessWidget {
  const AccueilPage({
    super.key,
    required this.list,
    required this.maintenant,
    required this.onOuvrirListe,
    required this.onOuvrirCalendrier,
    this.onBasculerTheme,
  });

  final TodoList list;
  final DateTime maintenant;
  final VoidCallback onOuvrirListe;
  final VoidCallback onOuvrirCalendrier;
  final VoidCallback? onBasculerTheme;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final aujourdhui = jourDe(maintenant);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.espacementPage,
          AppTheme.espacement,
          AppTheme.espacementPage,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: onBasculerTheme == null
                  ? const SizedBox(height: 48)
                  : BoutonTheme(onPressed: onBasculerTheme!, taille: 48),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BoutonVerre(
                    onPressed: onOuvrirListe,
                    largeur: 72,
                    hauteur: 72,
                    rayon: 22,
                    tooltip: 'Ouvrir mes tâches',
                    child: const LogoMark(key: Key('logo_accueil'), taille: 44),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MyTodoList',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: p.texte,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Note tes tâches, coche-les, avance.',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.45,
                      color: p.texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _CarteAujourdhui(
                    list: list,
                    aujourdhui: aujourdhui,
                    maintenant: maintenant,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                BoutonVerre(
                  onPressed: onOuvrirCalendrier,
                  largeur: 56,
                  hauteur: 56,
                  rayon: AppTheme.rayonGrand,
                  tooltip: 'Ouvrir le calendrier',
                  child: const Icon(Icons.calendar_today, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BoutonVerre(
                    key: const Key('bouton_voir_taches'),
                    onPressed: onOuvrirListe,
                    hauteur: 56,
                    rayon: AppTheme.rayonGrand,
                    accent: true,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Voir mes tâches'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
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
}

// Résumé du jour : tâches restantes, barre de progression, prochaine échéance.
class _CarteAujourdhui extends StatelessWidget {
  const _CarteAujourdhui({
    required this.list,
    required this.aujourdhui,
    required this.maintenant,
  });

  final TodoList list;
  final DateTime aujourdhui;
  final DateTime maintenant;

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final total = list.totalDuJour(aujourdhui);
    final restantes = list.remainingDuJour(aujourdhui);
    final faites = total - restantes;
    final prochaine = list.prochaineEcheance;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.carte,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SurTitre('Aujourd’hui'),
          const SizedBox(height: 12),
          Text(
            total == 0
                ? 'Rien de prévu aujourd’hui'
                : TodoList.counterLabel(restantes),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: p.texte,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : faites / total,
              minHeight: 8,
              backgroundColor: p.piste,
              color: p.accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$faites sur $total terminée${faites > 1 ? 's' : ''} aujourd’hui',
            style: TextStyle(fontSize: 14, color: p.texteSecondaire),
          ),
          if (prochaine != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: p.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prochaine échéance : ${prochaine.title} · '
                    '${TodoList.echeanceLabel(prochaine, maintenant, court: true)}',
                    style: TextStyle(fontSize: 14, color: p.texte),
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
