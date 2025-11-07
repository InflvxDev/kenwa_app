import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/services/timer_service.dart';

/// Widget que muestra los botones de control del timer
class TimerControls extends StatelessWidget {
  final TimerState timerState;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onBreakStart;

  const TimerControls({
    super.key,
    required this.timerState,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onBreakStart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Botón de inicio
        if (timerState == TimerState.idle)
          ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Comenzar Trabajo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

        // Botón de pausa/resume
        if (timerState == TimerState.working ||
            timerState == TimerState.breakActive)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onPause,
                icon: const Icon(Icons.pause),
                label: const Text('Pausar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onStop,
                icon: const Icon(Icons.stop),
                label: const Text('Detener'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.foreground.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

        // Botón de reanudar
        if (timerState == TimerState.paused)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Reanudar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onStop,
                icon: const Icon(Icons.stop),
                label: const Text('Detener'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.foreground.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

        // Botón de completado
        if (timerState == TimerState.completed)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: onBreakStart,
                icon: const Icon(Icons.emoji_food_beverage),
                label: const Text('Descansar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reiniciar'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.foreground.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
