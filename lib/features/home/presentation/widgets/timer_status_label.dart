import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/services/timer_service.dart';

/// Widget que muestra la etiqueta del estado actual del timer
class TimerStatusLabel extends StatelessWidget {
  final TimerState timerState;

  const TimerStatusLabel({super.key, required this.timerState});

  String _getLabel() {
    switch (timerState) {
      case TimerState.idle:
        return 'Listo para comenzar';
      case TimerState.working:
        return 'Trabajando';
      case TimerState.paused:
        return 'Pausado';
      case TimerState.breakActive:
        return 'Tiempo de descanso';
      case TimerState.completed:
        return 'Completado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _getLabel(),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppColors.foreground.withValues(alpha: 0.7),
        fontSize: 18,
      ),
    );
  }
}
