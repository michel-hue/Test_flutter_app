import 'package:app/pages/todo_page.dart';
import 'package:app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyTodoApp());
}

/// Racine de l'app : garde le thème choisi (sombre par défaut).
class MyTodoApp extends StatefulWidget {
  const MyTodoApp({super.key});

  @override
  State<MyTodoApp> createState() => _MyTodoAppState();
}

class _MyTodoAppState extends State<MyTodoApp> {
  bool _sombre = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTodoList',
      theme: AppTheme.themeClair,
      darkTheme: AppTheme.theme,
      themeMode: _sombre ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      // Sélecteurs de date et d'heure en français.
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: TodoPage(
        onBasculerTheme: () => setState(() => _sombre = !_sombre),
      ),
    );
  }
}
