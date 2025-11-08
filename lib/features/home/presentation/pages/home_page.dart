import 'package:flutter/material.dart';
import 'package:kenwa_app/app/router.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/config/data/sources/configuracion_local_source.dart';
import 'package:kenwa_app/features/config/domain/repositories/configuracion_repository.dart';
import 'package:kenwa_app/features/config/domain/usecases/obtener_configuracion.dart';
import 'package:kenwa_app/features/home/presentation/widgets/home_header.dart';
import 'package:kenwa_app/features/home/presentation/widgets/termometro_estres.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_controls.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_display.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_status_label.dart';
import 'package:kenwa_app/services/notification_service.dart';
import 'package:kenwa_app/services/stress_service.dart';
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
  late StressService _stressService;
  bool _isLoading = true;
  late TimerState _timerState;
  late int _remainingSeconds;
  late int _currentStressLevel;
  bool _breakJustCompleted = false; // Detectar cuando break se completa
  late TimerState _completedSessionType; // Guardar tipo de sesión completada
  bool _wasInBreak = false; // Rastrear si estábamos en break antes del reset

  // Guardar subscripciones para cancelarlas en dispose
  late StreamSubscription<int> _timerStreamSubscription;
  late StreamSubscription<TimerState> _stateStreamSubscription;
  late StreamSubscription<int> _stressStreamSubscription;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _stressService = StressService();
    _timerState = _timerService.state;
    _remainingSeconds = _timerService.remainingSeconds;
    _currentStressLevel = _stressService.stressLevel;
    _loadConfiguration();
    _setupTimerListeners();
    _setupStressListeners();
  }

  void _loadConfiguration() async {
    try {
      final localSource = ConfiguracionLocalSource();
      final repository = ConfiguracionRepositoryImpl(localSource: localSource);
      final obtenerUseCase = ObtenerConfiguracionUseCase(
        repository: repository,
      );

      // Inicializar servicio de estrés
      await _stressService.initialize();

      final config = await obtenerUseCase.call();

      if (config != null) {
        setState(() {
          _timerService.configure(
            workDurationMinutes: config.intervaloDescansos,
            breakDurationMinutes: config.tiempoDescanso,
          );
          _currentStressLevel = _stressService.stressLevel;
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

          // Detectar cuando se completa una sesión de TRABAJO (estado 'completed')
          if (state == TimerState.completed) {
            // El trabajo se completó, aumentar estrés
            _completedSessionType = TimerState.working;
            _wasInBreak = false;
            _handleTimerCompleted();
          }
          // Detectar cuando se completa un DESCANSO (break que llega a 0 segundos)
          else if (state == TimerState.idle &&
              _remainingSeconds == 0 &&
              !_breakJustCompleted &&
              _wasInBreak) {
            // Solo si estábamos EN un break (no fue un reset desde idle)
            _breakJustCompleted = true;
            _completedSessionType = TimerState.breakActive;
            _wasInBreak = false;
            _handleTimerCompleted();
          }
          // Si el estado cambia a idle
          else if (state == TimerState.idle) {
            // Usuario presionó reset, resetear flags
            _breakJustCompleted = false;
            _wasInBreak = false;
          }
          // Si iniciamos un nuevo timer (working o breakActive)
          else if (state == TimerState.working ||
              state == TimerState.breakActive) {
            // Rastrear si iniciamos un break
            _wasInBreak = (state == TimerState.breakActive);
            _breakJustCompleted = false;
          }
        });
      }
    });
  }

  void _setupStressListeners() {
    _stressStreamSubscription = _stressService.stressStream.listen((level) {
      if (mounted) {
        setState(() => _currentStressLevel = level);
      }
    });
  }

  void _handleTimerCompleted() async {
    // Usar _completedSessionType que se guardó ANTES de que se resetee el lastActiveState
    final message = _completedSessionType == TimerState.working
        ? '¡Hora de descansar!'
        : (_completedSessionType == TimerState.breakActive
              ? '¡Volvamos al trabajo!'
              : '');

    // Aumentar o disminuir estrés según el tipo de sesión completada
    if (_completedSessionType == TimerState.working) {
      // Se completó trabajo, aumentar estrés
      await _stressService.increaseStress();
    } else if (_completedSessionType == TimerState.breakActive) {
      // Se completó descanso, disminuir estrés
      await _stressService.decreaseStress();
    }

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
              child: SingleChildScrollView(
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

                    // Termómetro de estrés
                    TermometroEstres(
                      currentLevel: _currentStressLevel,
                      maxLevel: 10,
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
    _stressStreamSubscription.cancel();
    _timerService.dispose();
    _stressService.dispose();
    super.dispose();
  }
}
