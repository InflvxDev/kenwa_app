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
import 'dart:async';

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
  bool _breakJustCompleted = false; // Detectar cuando break se completa
  late TimerState _completedSessionType; // Guardar tipo de sesión completada

  // Guardar subscripciones para cancelarlas en dispose
  late StreamSubscription<int> _timerStreamSubscription;
  late StreamSubscription<TimerState> _stateStreamSubscription;

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
    _timerStreamSubscription = _timerService.timerStream.listen((seconds) {
      if (mounted) {
        setState(() => _remainingSeconds = seconds);
      }
    });

    _stateStreamSubscription = _timerService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _timerState = state;

          // Detectar cuando un break se completa y pasa a idle
          if (state == TimerState.idle &&
              _timerService.lastActiveState == TimerState.idle &&
              _remainingSeconds == 0 &&
              !_breakJustCompleted) {
            // El break acaba de completarse y auto-transicionar a idle
            _breakJustCompleted = true;
            // Guardar que fue un break el que se completó
            _completedSessionType = TimerState.breakActive;
            _handleTimerCompleted();
          } else if (state == TimerState.completed) {
            // El trabajo se completó, mostrar notificación
            _breakJustCompleted = false;
            // Guardar que fue trabajo el que se completó
            _completedSessionType = TimerState.working;
            _handleTimerCompleted();
          } else if (state != TimerState.idle) {
            // Reset cuando se inicia un nuevo timer
            _breakJustCompleted = false;
          }
        });
      }
    });
  }

  void _handleTimerCompleted() {
    // Usar _completedSessionType que se guardó ANTES de que se resetee el lastActiveState
    final message = _completedSessionType == TimerState.working
        ? '¡Hora de descansar!'
        : (_completedSessionType == TimerState.breakActive
              ? '¡Volvamos al trabajo!'
              : '');

    if (message.isNotEmpty) {
      // Mostrar solo la notificación del sistema
      final notificationService = NotificationService();
      notificationService.showNotification(
        id: 1,
        title: 'Kenwa',
        body: message,
      );
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

  void _resetTimer() {
    _timerService.reset();
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
                    lastActiveState: _timerService.lastActiveState,
                    onStart: _startTimer,
                    onPause: _pauseTimer,
                    onResume: _resumeTimer,
                    onStop: _stopTimer,
                    onBreakStart: _startBreak,
                    onReset: _resetTimer,
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
    // Cancelar las subscripciones al stream para evitar setState() after dispose
    _timerStreamSubscription.cancel();
    _stateStreamSubscription.cancel();
    _timerService.dispose();
    super.dispose();
  }
}
