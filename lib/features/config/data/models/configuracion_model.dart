import 'package:kenwa_app/features/config/domain/entities/configuracion.dart';

/// Modelo que extiende la entidad Configuracion con métodos de serialización
class ConfiguracionModel extends Configuracion {
  ConfiguracionModel({
    required super.horaInicio,
    required super.horaFin,
    required super.intervaloDescansos,
    required super.tiempoDescanso,
    required super.notificacionesActivas,
    super.nivelEstresInicial = 1,
    super.fechaCreacion,
  });

  /// Convierte el modelo a un mapa para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'horaInicio': horaInicio.toString(),
      'horaFin': horaFin.toString(),
      'intervaloDescansos': intervaloDescansos,
      'tiempoDescanso': tiempoDescanso,
      'notificacionesActivas': notificacionesActivas,
      'nivelEstresInicial': nivelEstresInicial,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Crea un modelo a partir de un mapa
  factory ConfiguracionModel.fromJson(Map<String, dynamic> json) {
    return ConfiguracionModel(
      horaInicio: HoraDelDia.fromString(json['horaInicio']),
      horaFin: HoraDelDia.fromString(json['horaFin']),
      intervaloDescansos: json['intervaloDescansos'],
      tiempoDescanso: json['tiempoDescanso'],
      notificacionesActivas: json['notificacionesActivas'],
      nivelEstresInicial: json['nivelEstresInicial'] ?? 1,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  /// Crea una copia del modelo con cambios opcionales
  ConfiguracionModel copyWith({
    HoraDelDia? horaInicio,
    HoraDelDia? horaFin,
    int? intervaloDescansos,
    int? tiempoDescanso,
    bool? notificacionesActivas,
    int? nivelEstresInicial,
    DateTime? fechaCreacion,
  }) {
    return ConfiguracionModel(
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      intervaloDescansos: intervaloDescansos ?? this.intervaloDescansos,
      tiempoDescanso: tiempoDescanso ?? this.tiempoDescanso,
      notificacionesActivas:
          notificacionesActivas ?? this.notificacionesActivas,
      nivelEstresInicial: nivelEstresInicial ?? this.nivelEstresInicial,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}
