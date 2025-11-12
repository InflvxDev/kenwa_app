import 'dart:async';

/// Estados posibles del timer
enum TimerState { idle, working, paused, breakActive, completed }

/// Servicio para gestionar el contador regresivo de trabajo y descanso
class TimerService {
  static final TimerService _instance = TimerService._internal();

  factory TimerService() {
    return _instance;
  }

  TimerService._internal();

  Timer? _timer;
  int _remainingSeconds = 0;
  TimerState _state = TimerState.idle;
  TimerState _lastActiveState =
      TimerState.idle; // Almacena el último estado activo

  // Configuración actual (EN SEGUNDOS, no minutos)
  int _workDurationSeconds = 3600;
  int _breakDurationSeconds = 300;

  // Timestamps para sincronización en background
  DateTime? _sessionStartTime; // Hora cuando se inició la sesión actual

  // Streams para notificar cambios
  final _timerStream = StreamController<int>.broadcast();
  final _stateStream = StreamController<TimerState>.broadcast();

  Stream<int> get timerStream => _timerStream.stream;
  Stream<TimerState> get stateStream => _stateStream.stream;

  int get remainingSeconds => _remainingSeconds;
  TimerState get state => _state;
  TimerState get lastActiveState => _lastActiveState;

  /// Configurar duración de trabajo y descanso (EN SEGUNDOS)
  void configure({
    required int workDurationSeconds,
    required int breakDurationSeconds,
  }) {
    _workDurationSeconds = workDurationSeconds;
    _breakDurationSeconds = breakDurationSeconds;
  }

  /// Iniciar sesión de trabajo
  void startWorkSession() {
    if (_state != TimerState.idle) {
      stop();
    }

    _remainingSeconds = _workDurationSeconds;
    _state = TimerState.working;
    _lastActiveState = TimerState.working;
    _sessionStartTime = DateTime.now();
    _stateStream.add(_state);
    _startTimer();
  }

  /// Iniciar sesión de descanso
  void startBreakSession() {
    if (_state != TimerState.idle) {
      stop();
    }

    _remainingSeconds = _breakDurationSeconds;
    _state = TimerState.breakActive;
    _lastActiveState = TimerState.breakActive;
    _sessionStartTime = DateTime.now();
    _stateStream.add(_state);
    _startTimer();
  }

  /// Pausar timer
  void pause() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _state = TimerState.paused;
      _stateStream.add(_state);
    }
  }

  /// Reanudar timer
  void resume() {
    if (_state == TimerState.paused) {
      _state = _lastActiveState;
      _startTimer();
    }
  }

  /// Reiniciar timer (vuelve al estado idle)
  void reset() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _remainingSeconds = 0;
    _state = TimerState.idle;
    _lastActiveState = TimerState.idle;
    _sessionStartTime = null;
    _stateStream.add(_state);
    _timerStream.add(0);
  }

  /// Detener timer completamente
  void stop() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _remainingSeconds = 0;
    _state = TimerState.idle;
    _sessionStartTime = null;
    _stateStream.add(_state);
    _timerStream.add(0);
  }

  /// Sincronizar el timer cuando se regresa del background
  /// Recalcula el tiempo restante basado en el tiempo transcurrido
  void syncFromBackground() {
    if (_state == TimerState.idle || _sessionStartTime == null) {
      return; // No hay sesión activa
    }

    if (_state == TimerState.paused) {
      return; // Si está pausado, no hacer nada
    }

    // Calcular tiempo transcurrido desde el inicio de la sesión
    final now = DateTime.now();
    final elapsedSeconds = now.difference(_sessionStartTime!).inSeconds;

    // Determinar la duración original de la sesión
    final originalDuration = _lastActiveState == TimerState.breakActive
        ? _breakDurationSeconds
        : _workDurationSeconds;

    // Calcular nuevo tiempo restante
    int newRemainingSeconds = originalDuration - elapsedSeconds;

    // Si ya pasó el tiempo, marcar como completado
    if (newRemainingSeconds <= 0) {
      _remainingSeconds = 0;
      _timer?.cancel();

      if (_lastActiveState == TimerState.breakActive) {
        _state = TimerState.idle;
        _lastActiveState = TimerState.idle;
      } else {
        _state = TimerState.completed;
      }

      _stateStream.add(_state);
      _timerStream.add(0);
    } else {
      // Actualizar el tiempo restante
      _remainingSeconds = newRemainingSeconds;
      _timerStream.add(_remainingSeconds);
    }
  }

  /// Iniciar el contador interno
  void _startTimer() {
    _timer?.cancel();

    _stateStream.add(_state);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _timerStream.add(_remainingSeconds);
      } else {
        // Timer completado
        _timer?.cancel();

        // Si fue un descanso, volver automáticamente a idle
        // Si fue trabajo, mostrar completed para que el usuario elija descansar
        if (_lastActiveState == TimerState.breakActive) {
          _state = TimerState.idle;
          _lastActiveState = TimerState.idle;
        } else {
          _state = TimerState.completed;
        }

        _stateStream.add(_state);
        _timerStream.add(0);
      }
    });
  }

  /// Obtener formato de tiempo HH:MM:SS
  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Limpiar recursos
  void dispose() {
    _timer?.cancel();
  }
}
