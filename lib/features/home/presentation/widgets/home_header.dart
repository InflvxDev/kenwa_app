import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';

/// Widget que muestra el encabezado con el logo de Kenwa y botón de settings
class HomeHeader extends StatelessWidget {
  final VoidCallback onSettingsPressed;

  const HomeHeader({super.key, required this.onSettingsPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Nombre y subtítulo centrados
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Kenwa\n',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                  children: [
                    TextSpan(
                      text: 'Salud y Armonía',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.foreground.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Botón de configuración abajo a la derecha
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            onPressed: onSettingsPressed,
            icon: const Icon(Icons.settings_outlined),
          ),
        ),
      ],
    );
  }
}
