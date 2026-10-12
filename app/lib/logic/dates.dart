/// Dates en français, en Dart pur (sans dépendance ni import Flutter).
library;

const _jours = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];
const _mois = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];
const _moisCourts = [
  'janv.',
  'févr.',
  'mars',
  'avr.',
  'mai',
  'juin',
  'juil.',
  'août',
  'sept.',
  'oct.',
  'nov.',
  'déc.',
];

/// La date sans l'heure : sert de clé pour regrouper les tâches par jour.
DateTime jourDe(DateTime d) => DateTime(d.year, d.month, d.day);

bool memeJour(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime plusJours(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

String majuscule(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _deux(int n) => n.toString().padLeft(2, '0');

/// « lun », « mar »… pour le bandeau de la semaine.
String jourCourt(DateTime d) => _jours[d.weekday - 1].substring(0, 3);

/// « jeudi 9 octobre ».
String jourLong(DateTime d) =>
    '${_jours[d.weekday - 1]} ${d.day} ${_mois[d.month - 1]}';

/// « 9 oct. ».
String jourMoisCourt(DateTime d) => '${d.day} ${_moisCourts[d.month - 1]}';

/// « 9 oct. 2026 ».
String dateCourte(DateTime d) => '${jourMoisCourt(d)} ${d.year}';

/// « Octobre 2026 ».
String moisAnnee(DateTime d) => majuscule('${_mois[d.month - 1]} ${d.year}');

/// « 18:00 ».
String heureMinute(DateTime d) => '${_deux(d.hour)}:${_deux(d.minute)}';

/// « Aujourd’hui », « Demain », « Hier » ou « Jeudi 9 octobre ».
String libelleJour(DateTime jour, DateTime aujourdhui) {
  if (memeJour(jour, aujourdhui)) return 'Aujourd’hui';
  if (memeJour(jour, plusJours(aujourdhui, 1))) return 'Demain';
  if (memeJour(jour, plusJours(aujourdhui, -1))) return 'Hier';
  return majuscule(jourLong(jour));
}
