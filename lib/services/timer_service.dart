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

  // Configuración actual
  int _workDurationMinutes = 60;
  int _breakDurationMinutes = 5;

  // Streams para notificar cambios
  final _timerStream = StreamController<int>.broadcast();
  final _stateStream = StreamController<TimerState>.broadcast();

  Stream<int> get timerStream => _timerStream.stream;
  Stream<TimerState> get stateStream => _stateStream.stream;

  int get remainingSeconds => _remainingSeconds;
  TimerState get state => _state;
  TimerState get lastActiveState => _lastActiveState;

  /// Configurar duración de trabajo y descanso
  void configure({
    required int workDurationMinutes,
    required int breakDurationMinutes,
  }) {
    _workDurationMinutes = workDurationMinutes;
    _breakDurationMinutes = breakDurationMinutes;
  }

  /// Iniciar sesión de trabajo
  void startWorkSession() {
    if (_state != TimerState.idle) {
      stop();
    }

    _remainingSeconds = _workDurationMinutes * 60;
    _state = TimerState.working;
    _lastActiveState = TimerState.working;
    _stateStream.add(_state);
    _startTimer();
  }

  /// Iniciar sesión de descanso
  void startBreakSession() {
    if (_state != TimerState.idle) {
      stop();
    }

    _remainingSeconds = _breakDurationMinutes * 60;
    _state = TimerState.breakActive;
    _lastActiveState = TimerState.breakActive;
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
    _stateStream.add(_state);
    _timerStream.add(0);
  }

  /// Iniciar el contador interno
  void _startTimer() {
    _timer?.cancel();

    // Si estamos reanudando desde pausa, no cambiar el estado
    // Solo continuar con el estado actual
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
    // NO cerramos los streams porque TimerService es un singleton
    // que se reutiliza en toda la app. Los streams deben permanecer abiertos.
  }
}
