import 'package:flutter/material.dart';
import 'package:kenwa_app/app/router.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/config/data/sources/configuracion_local_source.dart';
import 'package:kenwa_app/features/config/domain/repositories/configuracion_repository.dart';
import 'package:kenwa_app/features/config/domain/usecases/obtener_configuracion.dart';
import 'package:kenwa_app/features/home/presentation/widgets/home_header.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_controls.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_display.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_status_label.dart';
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
        ? (_timerService.lastActiveState == TimerState.working
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
            HomeHeader(onSettingsPressed: () => AppRouter.goSettings(context)),
            // Contenido central con countdown
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Etiqueta del estado actual
                  TimerStatusLabel(timerState: _timerState),
                  const SizedBox(height: 40),

                  // Circular countdown display
                  TimerDisplay(
                    timerService: _timerService,
                    remainingSeconds: _remainingSeconds,
                  ),

                  const SizedBox(height: 60),

                  // Botones de control
                  TimerControls(
                    timerState: _timerState,
                    onStart: _startTimer,
                    onPause: _pauseTimer,
                    onResume: _resumeTimer,
                    onStop: _stopTimer,
                    onBreakStart: _startBreak,
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
