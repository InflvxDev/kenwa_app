import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwa_app/features/config/data/sources/configuracion_local_source.dart';
import 'package:kenwa_app/features/config/presentation/pages/configuracion_inicial_page.dart';
import 'package:kenwa_app/features/config/presentation/pages/settings_page.dart';
import 'package:kenwa_app/features/home/presentation/pages/home_page.dart';
import 'package:kenwa_app/features/onboarding/presentation/pages/onboarding_page.dart';

/// Determina la ruta inicial basada en si existe configuración
Future<String> _determineInitialLocation() async {
  final localSource = ConfiguracionLocalSource();
  final existe = await localSource.existeConfiguracion();

  // Si existe configuración, ir a home; si no, ir a onboarding
  return existe ? '/home' : '/onboarding';
}

/// Variable global para almacenar la ubicación inicial
late String _initialLocation;

/// Inicializa la ruta inicial de la app
Future<void> initializeRouter() async {
  _initialLocation = await _determineInitialLocation();
}

/// Sistema de rutas con GoRouter
late final GoRouter appRouter;

/// Crea el router con la ubicación inicial dinámica
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: _initialLocation,
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/configuracion',
        name: 'configuracion',
        builder: (context, state) => const ConfiguracionInicialPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

/// Clase auxiliar para navegación (compatible con código existente)
class AppRouter {
  static const String onboarding = '/onboarding';
  static const String configuracion = '/configuracion';
  static const String home = '/home';
  static const String settings = '/settings';

  /// Navega al onboarding
  static void goOnboarding(BuildContext context) {
    context.goNamed('onboarding');
  }

  /// Navega a la configuración inicial
  static void goConfiguracion(BuildContext context) {
    context.goNamed('configuracion');
  }

  /// Navega a la pantalla principal
  static void goHome(BuildContext context) {
    context.goNamed('home');
  }

  /// Navega a la pantalla de configuración
  static void goSettings(BuildContext context) {
    context.goNamed('settings');
  }
}
