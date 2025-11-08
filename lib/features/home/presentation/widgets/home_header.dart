import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';

/// Widget que muestra el encabezado con el logo de Kenwa y botón de settings
class HomeHeader extends StatelessWidget {
  final VoidCallback onSettingsPressed;

  const HomeHeader({super.key, required this.onSettingsPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Kenwa',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          IconButton(
            onPressed: onSettingsPressed,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}
