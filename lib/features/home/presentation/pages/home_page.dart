import 'package:flutter/material.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/config/data/sources/configuracion_local_source.dart';
import 'package:kenwa_app/features/config/domain/repositories/configuracion_repository.dart';
import 'package:kenwa_app/features/config/domain/usecases/obtener_configuracion.dart';
import 'package:kenwa_app/services/notification_service.dart';
import 'package:kenwa_app/services/timer_service.dart';

/// Página principal de la app con contador regresivo
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TimerService _timerService;
  bool _isLoading = true;
  late TimerState _timerState;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerState = _timerService.state;
    _remainingSeconds = _timerService.remainingSeconds;
    _loadConfiguration();
    _setupTimerListeners();
  }

  void _loadConfiguration() async {
    try {
      final localSource = ConfiguracionLocalSource();
      final repository = ConfiguracionRepositoryImpl(localSource: localSource);
      final obtenerUseCase = ObtenerConfiguracionUseCase(
        repository: repository,
      );

      final config = await obtenerUseCase.call();

      if (config != null) {
        setState(() {
          _timerService.configure(
            workDurationMinutes: config.intervaloDescansos,
            breakDurationMinutes: config.tiempoDescanso,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading configuration: $e');
      setState(() => _isLoading = false);
    }
  }

  void _setupTimerListeners() {
    _timerService.timerStream.listen((seconds) {
      setState(() => _remainingSeconds = seconds);
    });

    _timerService.stateStream.listen((state) {
      setState(() => _timerState = state);

      // Mostrar notificación cuando se completa
      if (state == TimerState.completed) {
        _handleTimerCompleted();
      }
    });
  }

  void _handleTimerCompleted() {
    final message = _timerState == TimerState.completed
        ? (_timerService.state == TimerState.working
              ? '¡Hora de descansar!'
              : '¡Volvamos al trabajo!')
        : '';

    if (message.isNotEmpty) {
      // Mostrar notificación del sistema si están habilitadas
      final notificationService = NotificationService();
      notificationService.showNotification(
        id: 1,
        title: 'Kenwa',
        body: message,
      );

      // Mostrar SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _startTimer() {
    if (_timerState == TimerState.idle) {
      _timerService.startWorkSession();
    }
  }

  void _startBreak() {
    if (_timerState == TimerState.idle || _timerState == TimerState.completed) {
      _timerService.startBreakSession();
    }
  }

  void _pauseTimer() {
    _timerService.pause();
  }

  void _resumeTimer() {
    _timerService.resume();
  }

  void _stopTimer() {
    _timerService.stop();
  }

  String _getTimerLabel() {
    switch (_timerState) {
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header con el nombre de la app a la izquierda
            Padding(
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
                  ),
                  // Iconos adicionales (puede ser settings, perfil, etc.)
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            // Contenido central con countdown
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Etiqueta del estado actual
                  Text(
                    _getTimerLabel(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.foreground.withValues(alpha: 0.7),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Circular countdown display
                  Container(
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
                        _timerService.formatTime(_remainingSeconds),
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 44,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Botones de control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón de inicio
                      if (_timerState == TimerState.idle)
                        ElevatedButton.icon(
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Comenzar Trabajo'),
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

                      // Botón de pausa/resume
                      if (_timerState == TimerState.working ||
                          _timerState == TimerState.breakActive)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pauseTimer,
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
                              onPressed: _stopTimer,
                              icon: const Icon(Icons.stop),
                              label: const Text('Detener'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.foreground.withValues(
                                    alpha: 0.3,
                                  ),
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
                      if (_timerState == TimerState.paused)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _resumeTimer,
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
                              onPressed: _stopTimer,
                              icon: const Icon(Icons.stop),
                              label: const Text('Detener'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.foreground.withValues(
                                    alpha: 0.3,
                                  ),
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
                      if (_timerState == TimerState.completed)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _startBreak,
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
                              onPressed: _startTimer,
                              icon: const Icon(Icons.restart_alt),
                              label: const Text('Reiniciar'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.foreground.withValues(
                                    alpha: 0.3,
                                  ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }
}
