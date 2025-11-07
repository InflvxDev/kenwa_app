import 'package:flutter/material.dart';
import 'package:kenwa_app/app/router.dart';
import 'theme/app_theme.dart';

class KenwaApp extends StatelessWidget {
  const KenwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crear el router con la ubicación inicial dinámica
    final router = createAppRouter();

    return MaterialApp.router(
      title: 'Kenwa Salud y Armonía',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
