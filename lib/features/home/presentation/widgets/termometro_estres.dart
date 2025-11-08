import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';

/// Widget que muestra un termómetro visual del nivel de estrés con graduaciones
class TermometroEstres extends StatefulWidget {
  final int currentLevel;
  final int maxLevel;

  const TermometroEstres({
    super.key,
    required this.currentLevel,
    this.maxLevel = 10,
  });

  @override
  State<TermometroEstres> createState() => _TermometroEstresState();
}

class _TermometroEstresState extends State<TermometroEstres>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  static const double _thermometerWidth = 55;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation =
        Tween<double>(
          begin: widget.currentLevel.toDouble(),
          end: widget.currentLevel.toDouble(),
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void didUpdateWidget(TermometroEstres oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLevel != widget.currentLevel) {
      _animation =
          Tween<double>(
            begin: oldWidget.currentLevel.toDouble(),
            end: widget.currentLevel.toDouble(),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
          );

      _animationController.forward(from: 0.0);
    }
  }

  /// Obtiene el gradiente de colores basado en el nivel
  List<Color> _getGradientColors(double level) {
    if (level <= 2) {
      return [AppColors.primary, AppColors.primary];
    } else if (level <= 4) {
      return [AppColors.primary, const Color(0xFFFFA500)];
    } else if (level <= 7) {
      return [const Color(0xFFFFA500), const Color(0xFFFF6B35)];
    } else {
      return [const Color(0xFFFF6B35), const Color(0xFFE63946)];
    }
  }

  Color _getPrimaryColorForLevel(double level) {
    if (level <= 2) {
      return AppColors.primary;
    } else if (level <= 4) {
      return const Color(0xFFD4A500);
    } else if (level <= 7) {
      return const Color(0xFFFF8C42);
    } else {
      return const Color(0xFFE63946);
    }
  }

  String _getLevelLabel(double level) {
    if (level <= 1) {
      return 'Tranquilo 😌';
    } else if (level <= 2) {
      return 'Relajado 🙂';
    } else if (level <= 4) {
      return 'Normal 😐';
    } else if (level <= 7) {
      return 'Estresado 😟';
    } else {
      return 'Muy Estresado 😤';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentLevel = _animation.value;
        final percentage = (currentLevel / widget.maxLevel).clamp(0.0, 1.0);
        final gradientColors = _getGradientColors(currentLevel);
        final primaryColor = _getPrimaryColorForLevel(currentLevel);

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Contenedor con termómetro (expandible)
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final height = constraints.maxHeight;

                    return Container(
                      width: _thermometerWidth,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.foreground.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Fondo completo
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.foreground.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                            ),

                            // Base inferior siempre verde (primary)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: height * 0.15,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Relleno con gradiente (encima de la base)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: height * percentage,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: gradientColors,
                                  ),
                                ),
                              ),
                            ),

                            // Graduaciones
                            ...List.generate(10, (index) {
                              final level = 10 - index;
                              final positionFromBottom = (index * height) / 9;

                              return Positioned(
                                bottom: positionFromBottom,
                                right: 2,
                                child: Container(
                                  width: level % 2 == 0 ? 6 : 4,
                                  height: 1,
                                  color: AppColors.foreground.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Título arriba de los números
            Text(
              'Nivel de Estrés',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            // Valor numérico y etiqueta
            Text(
              '${currentLevel.toStringAsFixed(0)}/10',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getLevelLabel(currentLevel),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
