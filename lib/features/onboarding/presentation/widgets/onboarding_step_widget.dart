import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/onboarding/presentation/models/onboarding_model.dart';

/// Widget que representa una pantalla individual del onboarding
class OnboardingStepWidget extends StatelessWidget {
  final OnboardingStep step;

  const OnboardingStepWidget({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              _getIconData(step.icon),
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 40),
          // Título
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          // Descripción
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Convierte el nombre del ícono a su correspondiente IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'mind':
        return Icons.psychology;
      case 'rest':
        return Icons.favorite;
      case 'stress':
        return Icons.thermostat;
      default:
        return Icons.info;
    }
  }
}
