import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwa_app/features/config/presentation/pages/configuracion_inicial_page.dart';
import 'package:kenwa_app/features/home/presentation/pages/home_page.dart';
import 'package:kenwa_app/features/onboarding/presentation/pages/onboarding_page.dart';

/// Sistema de rutas con GoRouter
final appRouter = GoRouter(
  initialLocation: '/onboarding',
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
  ],
);

/// Clase auxiliar para navegación (compatible con código existente)
class AppRouter {
  static const String onboarding = '/onboarding';
  static const String configuracion = '/configuracion';
  static const String home = '/home';

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
}
