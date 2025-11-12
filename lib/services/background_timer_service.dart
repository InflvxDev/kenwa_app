import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';

/// Servicio para mantener el timer activo en segundo plano
/// Utiliza flutter_background para ejecutar una foreground service en Android
class BackgroundTimerService {
  static final BackgroundTimerService _instance =
      BackgroundTimerService._internal();

  factory BackgroundTimerService() {
    return _instance;
  }

  BackgroundTimerService._internal();

  bool _isInitialized = false;
  bool _isBackgroundExecutionEnabled = false;

  /// Inicializar el servicio de background
  /// Solo disponible en Android
  /// Nota: Usa la notificación del timer existente, no crea una nueva
  Future<bool> initialize() async {
    if (_isInitialized) {
      return _isBackgroundExecutionEnabled;
    }

    try {
      // Configuración mínima para Android - sin notificación adicional
      // La notificación del timer existente es suficiente
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "Kenwa",
        notificationText: "Timer activo",
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(
          name: 'ic_launcher',
          defType: 'mipmap',
        ),
        enableWifiLock: true,
      );

      // Inicializar flutter_background
      final success = await FlutterBackground.initialize(
        androidConfig: androidConfig,
      );

      _isInitialized = success;
      return success;
    } catch (e) {
      debugPrint('Error inicializando BackgroundTimerService: $e');
      return false;
    }
  }

  /// Habilitar ejecución en background
  Future<bool> enableBackground() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return false;
      }
    }

    try {
      final success = await FlutterBackground.enableBackgroundExecution();
      _isBackgroundExecutionEnabled = success;
      return success;
    } catch (e) {
      debugPrint('Error habilitando background execution: $e');
      return false;
    }
  }

  /// Deshabilitar ejecución en background
  Future<bool> disableBackground() async {
    if (!_isInitialized) {
      return true; // Ya está deshabilitado
    }

    try {
      final success = await FlutterBackground.disableBackgroundExecution();
      _isBackgroundExecutionEnabled = false;
      return success;
    } catch (e) {
      debugPrint('Error deshabilitando background execution: $e');
      return false;
    }
  }

  /// Verificar si ya tiene permisos
  Future<bool> hasPermissions() async {
    try {
      return await FlutterBackground.hasPermissions;
    } catch (e) {
      debugPrint('Error verificando permisos: $e');
      return false;
    }
  }

  /// Verificar si la ejecución en background está habilitada
  bool get isBackgroundExecutionEnabled => _isBackgroundExecutionEnabled;

  /// Verificar si el servicio está inicializado
  bool get isInitialized => _isInitialized;
}
