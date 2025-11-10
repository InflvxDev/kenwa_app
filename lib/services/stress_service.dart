import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el nivel de estrés del usuario
class StressService {
  static final StressService _instance = StressService._internal();
  static bool _modalMostrado = false;

  factory StressService() {
    return _instance;
  }

  StressService._internal() {
    _stressStream = StreamController<int>.broadcast();
  }

  static const String _keyStressLevel = 'stress_level';

  int _stressLevel = 1;

  // Stream para notificar cambios en el nivel de estrés
  late StreamController<int> _stressStream;
  bool _isDisposed = false;

  Stream<int> get stressStream => _stressStream.stream;
  int get stressLevel => _stressLevel;

  /// Inicializa el servicio cargando valores persistidos
  Future<void> initialize() async {
    // Reinicializar el stream si fue cerrado
    if (_isDisposed) {
      _stressStream = StreamController<int>.broadcast();
      _isDisposed = false;
    }

    final prefs = await SharedPreferences.getInstance();
    _stressLevel = prefs.getInt(_keyStressLevel) ?? 1;
  }

  /// Establece el nivel de estrés (usado en la primera configuración)
  Future<void> setStressLevel(int level) async {
    if (level < 1 || level > 10) {
      throw ArgumentError('Stress level must be between 1 and 10');
    }

    final prefs = await SharedPreferences.getInstance();
    _stressLevel = level;

    await prefs.setInt(_keyStressLevel, level);

    if (!_isDisposed && !_stressStream.isClosed) {
      _stressStream.add(_stressLevel);
    }
  }

  /// Incrementa el nivel de estrés en 1 (al terminar trabajo)
  /// El nivel máximo es 10
  Future<void> increaseStress() async {
    if (_stressLevel < 10) {
      _stressLevel = _stressLevel + 1;
      await _saveStressLevel();
      if (!_isDisposed && !_stressStream.isClosed) {
        _stressStream.add(_stressLevel);
      }
    }
  }

  /// Disminuye el nivel de estrés en 2 (al terminar descanso)
  /// El nivel mínimo es 1
  Future<void> decreaseStress() async {
    if (_stressLevel > 1) {
      _stressLevel = _stressLevel - 2;
      // Asegurar que no sea menor a 1
      if (_stressLevel < 1) {
        _stressLevel = 1;
      }
      await _saveStressLevel();
      if (!_isDisposed && !_stressStream.isClosed) {
        _stressStream.add(_stressLevel);
      }
    }
  }

  /// Guarda el nivel actual en persistencia
  Future<void> _saveStressLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStressLevel, _stressLevel);
  }

  void dispose() {
    if (!_stressStream.isClosed) {
      _stressStream.close();
    }
    _isDisposed = true;
  }

  static bool get modalMostrado => _modalMostrado;

  static void marcarModalMostrado() {
    _modalMostrado = true;
  }
}
