import 'package:kenwa_app/features/config/domain/entities/configuracion.dart';
import 'package:kenwa_app/features/config/domain/repositories/configuracion_repository.dart';

/// Use case para obtener la configuración del usuario
class ObtenerConfiguracionUseCase {
  final ConfiguracionRepository repository;

  ObtenerConfiguracionUseCase({required this.repository});

  Future<Configuracion?> call() async {
    return await repository.obtenerConfiguracion();
  }
}
