import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/onboarding/presentation/models/onboarding_model.dart';
import 'package:kenwa_app/features/onboarding/presentation/widgets/onboarding_button.dart';
import 'package:kenwa_app/features/onboarding/presentation/widgets/onboarding_indicator.dart';
import 'package:kenwa_app/features/onboarding/presentation/widgets/onboarding_step_widget.dart';

/// Página principal del onboarding
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  /// Lista de pasos del onboarding
  final List<OnboardingStep> onboardingSteps = [
    OnboardingStep(
      id: 1,
      title: 'Cuida tu mente mientras trabajas.',
      description:
          'Con Kenwa te ayudamos a mantener un equilibrio saludable entre tu bienestar mental y tu productividad laboral.',
      icon: 'mind',
    ),
    OnboardingStep(
      id: 2,
      title: 'Descansos guiados',
      description:
          'Te ayudamos a mantener el ritmo con pausas activas personalizadas que revitalizarán tu energía.',
      icon: 'rest',
    ),
    OnboardingStep(
      id: 3,
      title: 'Termómetro de estrés',
      description:
          'Mide tu nivel de estrés en tiempo real y mejora tu bienestar con recomendaciones personalizadas.',
      icon: 'stress',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentIndex < onboardingSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // TODO: Implementar navegación a la pantalla principal después del onboarding
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('¡Onboarding completado!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: onboardingSteps.length,
                itemBuilder: (context, index) {
                  return OnboardingStepWidget(step: onboardingSteps[index]);
                },
              ),
            ),
            // Indicador de progreso
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: OnboardingIndicator(
                currentIndex: _currentIndex,
                totalSteps: onboardingSteps.length,
              ),
            ),
            // Botón
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  OnboardingButton(
                    label: _currentIndex == onboardingSteps.length - 1
                        ? 'Comenzar'
                        : 'Siguiente',
                    onPressed: _goToNextPage,
                  ),
                  // Botón para saltar (opcional)
                  if (_currentIndex < onboardingSteps.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'Saltar',
                          style: TextStyle(color: AppColors.foreground),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
