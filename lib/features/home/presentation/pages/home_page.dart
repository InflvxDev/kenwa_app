import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kenwa_app/app/router.dart';
import 'package:kenwa_app/app/theme/app_colors.dart';
import 'package:kenwa_app/features/config/data/sources/configuracion_local_source.dart';
import 'package:kenwa_app/features/config/domain/repositories/configuracion_repository.dart';
import 'package:kenwa_app/features/config/domain/usecases/obtener_configuracion.dart';
import 'package:kenwa_app/features/home/presentation/widgets/break_decision_modal.dart';
import 'package:kenwa_app/features/home/presentation/widgets/home_header.dart';
import 'package:kenwa_app/features/home/presentation/widgets/termometro_estres.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_controls.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_display.dart';
import 'package:kenwa_app/features/home/presentation/widgets/timer_status_label.dart';
import 'package:kenwa_app/features/home/presentation/widgets/estado_animo_modal.dart';
import 'package:kenwa_app/services/notification_service.dart';
import 'package:kenwa_app/services/sound_service.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() async {
        if (!StressService.modalMostrado) {
          await _mostrarEstadoAnimoModal();
          StressService.marcarModalMostrado();
        }
      });
    });
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

      // Actualizar notificación persistente cuando el timer está corriendo
      if (_timerState == TimerState.working ||
          _timerState == TimerState.breakActive) {
        _updateTimerNotification();
      }
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
          _cancelTimerNotification(); // Cancelar notificación al completar
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
          _cancelTimerNotification(); // Cancelar notificación al completar
          _handleTimerCompleted();
        }
        // Si el estado cambia a idle (usuario presionó reset)
        else if (state == TimerState.idle) {
          // Usuario presionó reset, resetear flags
          _breakJustCompleted = false;
          _wasInBreak = false;
          _cancelTimerNotification(); // Cancelar notificación al hacer reset
        }
        // Si el estado cambia a paused - MANTENER el flag _wasInBreak
        else if (state == TimerState.paused) {
          // NO resetear _wasInBreak aquí, solo cancelar la notificación
          // Esto permite que se recuerde si estábamos en break cuando se pausa
          _cancelTimerNotification();
        }
        // Si iniciamos un nuevo timer (working o breakActive)
        else if (state == TimerState.working ||
            state == TimerState.breakActive) {
          // Rastrear si iniciamos un break
          _wasInBreak = (state == TimerState.breakActive);
          _breakJustCompleted = false;
          _updateTimerNotification(); // Mostrar notificación al iniciar
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

  /// Actualizar la notificación persistente del timer
  void _updateTimerNotification() {
    final notificationService = NotificationService();
    final timeString = _timerService.formatTime(_remainingSeconds);

    String status;
    if (_timerState == TimerState.working) {
      status = 'Trabajando';
    } else if (_timerState == TimerState.breakActive) {
      status = 'Descansando';
    } else {
      return; // No mostrar notificación si no está corriendo
    }

    notificationService.showTimerNotification(
      timeRemaining: timeString,
      status: status,
      isWorking: _timerState == TimerState.working,
    );
  }

  /// Cancelar la notificación persistente del timer
  void _cancelTimerNotification() {
    final notificationService = NotificationService();
    notificationService.cancelTimerNotification();
  }

  void _handleTimerCompleted() async {
    //Sonido de alarma al finalizar cualquier sesión
    await SoundService.playAlarm();

    // Usar _completedSessionType que se guardó ANTES de que se resetee el lastActiveState
    final wasWorkSession = _completedSessionType == TimerState.working;
    final wasBreakSession = _completedSessionType == TimerState.breakActive;

    // Aumentar o disminuir estrés según el tipo de sesión completada
    if (wasWorkSession) {
      // Se completó trabajo, aumentar estrés
      await _stressService.increaseStress();

      // Mostrar notificación del sistema
      final notificationService = NotificationService();
      await notificationService.showNotification(
        id: 1,
        title: 'Kenwa - ¡Trabajo Completado!',
        body:
            '¡Hora de descansar! Tómate un break para reducir tu nivel de estrés.',
      );

      // Mostrar modal de decisión para descansar o seguir trabajando
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => BreakDecisionModal(
            stressLevel: _stressService.stressLevel,
            onBreakPressed: () {
              Navigator.pop(context);
              _startBreak();
            },
            onContinueWorkPressed: () {
              Navigator.pop(context);
              _startTimer();
            },
          ),
        );
      }
    } else if (wasBreakSession) {
      // Se completó descanso, disminuir estrés
      await _stressService.decreaseStress();

      // Mostrar notificación del sistema
      final notificationService = NotificationService();
      await notificationService.showNotification(
        id: 2,
        title: 'Kenwa - ¡Descanso Completado!',
        body:
            '¡Volvamos al trabajo! Te sientes más fresco y listo para continuar.',
      );

      // Mostrar modal informativo
      if (mounted) {
        await BreakDecisionModal.showRestCompletedModal(context, () {
          // Auto-iniciar el timer de trabajo cuando el usuario presiona OK
          _startTimer();
        }, _stressService.stressLevel);
      }
    }
  }

  Future<void> _mostrarEstadoAnimoModal() async {
    await Future.delayed(const Duration(milliseconds: 400)); // breve pausa
    if (mounted) {
      await EstadoAnimoModal.show(context);
      // Actualizar el termómetro después de que se guarde el nuevo nivel
      setState(() {
        _currentStressLevel = _stressService.stressLevel;
      });
    }
  }

String _getImageForState(TimerState state) {
    switch (state) {
      case TimerState.working:
        return 'assets/images/working.svg';
      case TimerState.breakActive:
        return 'assets/images/break.svg';
      case TimerState.paused:
        // Cuando está pausado, mostrar la imagen del último estado activo
        return _timerService.lastActiveState == TimerState.breakActive
            ? 'assets/images/break.svg'
            : 'assets/images/working.svg';
      default:
        return 'assets/images/working.svg';
    }
  }

  void _startTimer() {
    if (_timerState == TimerState.idle || _timerState == TimerState.completed) {
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
            // Contenido central: Termómetro (izq) + Timer y Botones (der)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  children: [
                    // Termómetro a la izquierda (compacto)
                    SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TermometroEstres(
                              currentLevel: _currentStressLevel,
                              maxLevel: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Timer y Botones a la derecha (toma el resto del espacio)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Etiqueta del estado actual
                          TimerStatusLabel(timerState: _timerState),
                          const SizedBox(height: 12),

                          // Timer compacto
                          TimerDisplay(
                            timerService: _timerService,
                            remainingSeconds: _remainingSeconds,
                          ),
                          const SizedBox(height: 16),

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

                          const SizedBox(height: 60),

                          // Imagen que cambia según el estado del timer
                          SvgPicture.asset(
                            _getImageForState(_timerState),
                            height: 140,
                          ),
                        ],
                      ),
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
    // Cancelar notificación del timer al salir de la página
    // NOTA: Solo cancelamos si el timer NO está corriendo, para que siga visible
    // si el usuario navega a otra página con el timer activo
    // _cancelTimerNotification();
    // NO llamamos dispose() en los servicios singleton porque se reutilizan
    // Solo cancelamos las subscripciones de este widget
    super.dispose();
  }
}
