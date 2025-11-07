import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/services/timer_service.dart';

/// Widget que muestra el contador circular con el tiempo restante
class TimerDisplay extends StatelessWidget {
  final TimerService timerService;
  final int remainingSeconds;

  const TimerDisplay({
    super.key,
    required this.timerService,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          timerService.formatTime(remainingSeconds),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontSize: 44,
          ),
        ),
      ),
    );
  }
}
