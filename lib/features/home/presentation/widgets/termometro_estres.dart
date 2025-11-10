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

  // Ahora devuelve solo el texto sin emoji
  String _getLevelLabel(double level) {
    if (level <= 1) {
      return 'Tranquilo';
    } else if (level <= 2) {
      return 'Relajado';
    } else if (level <= 4) {
      return 'Normal';
    } else if (level <= 7) {
      return 'Estresado';
    } else {
      return 'Muy Estresado';
    }
  }

  // Nueva función para obtener solo el emoji
  String _getEmoji(double level) {
    if (level <= 1) {
      return '😌';
    } else if (level <= 2) {
      return '🙂';
    } else if (level <= 4) {
      return '😐';
    } else if (level <= 7) {
      return '😟';
    } else {
      return '😤';
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
            // Etiqueta con emoji grande arriba
            Text(
              _getLevelLabel(currentLevel),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            
            // Emoji grande
            Text(
              _getEmoji(currentLevel),
              style: const TextStyle(
                fontSize: 42,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 16),

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
                          color: AppColors.foreground.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Fondo completo con gradiente sutil
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.foreground.withValues(alpha: 0.05),
                                    AppColors.foreground.withValues(alpha: 0.08),
                                  ],
                                ),
                              ),
                            ),

                            // Base inferior siempre verde (primary) con resplandor
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
                                      AppColors.primary.withValues(alpha: 0.85),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Relleno con gradiente mejorado
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
                                    stops: const [0.0, 0.9],
                                  ),
                                ),
                              ),
                            ),

                            // Brillo superior en el líquido
                            Positioned(
                              bottom: height * percentage * 0.9,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Graduaciones mejoradas
                            ...List.generate(10, (index) {
                              final level = 10 - index;
                              final positionFromBottom = (index * height) / 9;
                              final isEven = level % 2 == 0;

                              return Positioned(
                                bottom: positionFromBottom,
                                right: 3,
                                child: Container(
                                  width: isEven ? 8 : 5,
                                  height: isEven ? 1.5 : 1,
                                  decoration: BoxDecoration(
                                    color: AppColors.foreground.withValues(
                                      alpha: isEven ? 0.5 : 0.3,
                                    ),
                                    borderRadius: BorderRadius.circular(1),
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
            const SizedBox(height: 16),

            // Título
            Center(
              child: Text(
                'Nivel de Estrés',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.foreground.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Valor numérico con estilo mejorado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${currentLevel.toStringAsFixed(0)}/10',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
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