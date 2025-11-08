import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';

/// Widget que muestra un termómetro visual del nivel de estrés
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

  Color _getColorForLevel(double level) {
    if (level <= 1) {
      return Colors.green;
    } else if (level <= 4) {
      return Colors.yellow.shade700;
    } else if (level <= 7) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getLevelLabel(double level) {
    if (level <= 1) {
      return 'Bajo';
    } else if (level <= 4) {
      return 'Moderado';
    } else if (level <= 7) {
      return 'Alto';
    } else {
      return 'Muy Alto';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentLevel = _animation.value;
        final percentage = (currentLevel / widget.maxLevel).clamp(0.0, 1.0);
        final color = _getColorForLevel(currentLevel);

        return Column(
          children: [
            // Etiqueta del nivel
            Text(
              'Nivel de Estrés',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.foreground),
            ),
            const SizedBox(height: 12),

            // Termómetro
            Container(
              width: 60,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.foreground.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Fondo gris claro
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.foreground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),

                  // Relleno del termómetro (animado)
                  Container(
                    height: 196 * percentage,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                    ),
                  ),

                  // Bulbo en la parte inferior
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.foreground.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Valor numérico
            Text(
              '${currentLevel.toStringAsFixed(0)}/10',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _getColorForLevel(currentLevel),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Etiqueta descriptiva
            Text(
              _getLevelLabel(currentLevel),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _getColorForLevel(currentLevel),
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
