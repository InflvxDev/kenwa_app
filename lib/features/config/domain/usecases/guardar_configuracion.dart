import 'package:kenwa_app/features/config/domain/entities/configuracion.dart';
import 'package:kenwa_app/features/config/domain/repositories/configuracion_repository.dart';

/// Use case para guardar la configuración del usuario
class GuardarConfiguracionUseCase {
  final ConfiguracionRepository repository;

  GuardarConfiguracionUseCase({required this.repository});

  Future<void> call(Configuracion configuracion) async {
    return await repository.guardarConfiguracion(configuracion);
  }
}
