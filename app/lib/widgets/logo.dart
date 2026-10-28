import 'package:flutter/material.dart';

/// Marque MyTodoList, dans la variante adaptée au fond du thème.
/// Le corail vif ne se pose jamais sur fond clair : le thème clair utilise
/// le corail profond `logo_mark_corail_1024.png`.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, required this.taille});

  final double taille;

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      sombre
          ? 'assets/branding/logo_mark_1024.png'
          : 'assets/branding/logo_mark_corail_1024.png',
      width: taille,
      height: taille,
      filterQuality: FilterQuality.high,
      excludeFromSemantics: true,
    );
  }
}
