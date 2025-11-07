import 'package:kenwa_app/features/config/domain/entities/configuracion.dart';
import 'package:kenwa_app/features/config/domain/usecases/guardar_configuracion.dart';
import 'package:kenwa_app/features/config/domain/usecases/obtener_configuracion.dart';

/// Controller que gestiona la lógica de la configuración
class ConfiguracionController {
  final GuardarConfiguracionUseCase guardarUseCase;
  final ObtenerConfiguracionUseCase obtenerUseCase;

  // Estados
  bool _isLoading = false;
  String? _errorMessage;
  Configuracion? _currentConfiguracion;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Configuracion? get currentConfiguracion => _currentConfiguracion;

  ConfiguracionController({
    required this.guardarUseCase,
    required this.obtenerUseCase,
  });

  /// Guarda la configuración
  Future<bool> guardarConfiguracion(Configuracion configuracion) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      // Validar que hora inicio sea menor que hora fin
      if (configuracion.horaInicio.hour > configuracion.horaFin.hour) {
        _errorMessage =
            'La hora de inicio no puede ser mayor que la hora de fin';
        _isLoading = false;
        return false;
      }

      // Validar intervalos
      if (configuracion.intervaloDescansos <= 0 ||
          configuracion.tiempoDescanso <= 0) {
        _errorMessage = 'Los intervalos deben ser mayores a 0';
        _isLoading = false;
        return false;
      }

      await guardarUseCase(configuracion);
      _currentConfiguracion = configuracion;
      _isLoading = false;
      return true;
    } catch (e) {
      _errorMessage = 'Error al guardar: ${e.toString()}';
      _isLoading = false;
      return false;
    }
  }

  /// Obtiene la configuración guardada
  Future<Configuracion?> obtenerConfiguracion() async {
    try {
      _isLoading = true;
      _errorMessage = null;

      final configuracion = await obtenerUseCase();
      _currentConfiguracion = configuracion;
      _isLoading = false;
      return configuracion;
    } catch (e) {
      _errorMessage = 'Error al obtener: ${e.toString()}';
      _isLoading = false;
      return null;
    }
  }

  /// Limpia los errores
  void clearError() {
    _errorMessage = null;
  }
}
