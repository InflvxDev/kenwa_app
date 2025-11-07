import 'package:kenwa_app/features/config/data/models/configuracion_model.dart';
import 'package:kenwa_app/features/config/data/sources/configuracion_local_source.dart';
import 'package:kenwa_app/features/config/domain/entities/configuracion.dart';

/// Repositorio que gestiona la configuración del usuario
abstract class ConfiguracionRepository {
  Future<void> guardarConfiguracion(Configuracion configuracion);
  Future<Configuracion?> obtenerConfiguracion();
  Future<bool> existeConfiguracion();
  Future<void> eliminarConfiguracion();
}

/// Implementación del repositorio usando fuente local
class ConfiguracionRepositoryImpl implements ConfiguracionRepository {
  final ConfiguracionLocalSource localSource;

  ConfiguracionRepositoryImpl({required this.localSource});

  @override
  Future<void> guardarConfiguracion(Configuracion configuracion) async {
    final model = ConfiguracionModel(
      horaInicio: configuracion.horaInicio,
      horaFin: configuracion.horaFin,
      intervaloDescansos: configuracion.intervaloDescansos,
      tiempoDescanso: configuracion.tiempoDescanso,
      notificacionesActivas: configuracion.notificacionesActivas,
      fechaCreacion: configuracion.fechaCreacion,
    );
    await localSource.guardarConfiguracion(model);
  }

  @override
  Future<Configuracion?> obtenerConfiguracion() async {
    return await localSource.obtenerConfiguracion();
  }

  @override
  Future<bool> existeConfiguracion() async {
    return await localSource.existeConfiguracion();
  }

  @override
  Future<void> eliminarConfiguracion() async {
    await localSource.eliminarConfiguracion();
  }
}
