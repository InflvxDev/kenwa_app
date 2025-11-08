/// Entidad que representa la configuración del usuario
class Configuracion {
  final HoraDelDia horaInicio;
  final HoraDelDia horaFin;
  final int intervaloDescansos; // en minutos
  final int tiempoDescanso; // en minutos
  final bool notificacionesActivas;
  final int nivelEstresInicial; // 1, 4, 7 o 10
  final DateTime fechaCreacion;

  Configuracion({
    required this.horaInicio,
    required this.horaFin,
    required this.intervaloDescansos,
    required this.tiempoDescanso,
    required this.notificacionesActivas,
    this.nivelEstresInicial = 1,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();
}

/// Clase auxiliar para representar hora del día
class HoraDelDia {
  final int hour;
  final int minute;

  HoraDelDia({required this.hour, required this.minute});

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';

  factory HoraDelDia.fromString(String time) {
    final parts = time.split(':');
    return HoraDelDia(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
