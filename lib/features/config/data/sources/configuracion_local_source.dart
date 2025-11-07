import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kenwa_app/features/config/data/models/configuracion_model.dart';

/// Fuente local de datos usando SharedPreferences
class ConfiguracionLocalSource {
  static const String _keyConfiguracion = 'configuracion';

  /// Guarda la configuración en el almacenamiento local
  Future<void> guardarConfiguracion(ConfiguracionModel configuracion) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(configuracion.toJson());
    await prefs.setString(_keyConfiguracion, json);
  }

  /// Obtiene la configuración del almacenamiento local
  Future<ConfiguracionModel?> obtenerConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyConfiguracion);

    if (json == null) {
      return null;
    }

    try {
      final Map<String, dynamic> decodedJson = jsonDecode(json);
      return ConfiguracionModel.fromJson(decodedJson);
    } catch (e) {
      throw Exception('Error al decodificar la configuración: $e');
    }
  }

  /// Elimina la configuración del almacenamiento local
  Future<void> eliminarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyConfiguracion);
  }

  /// Verifica si existe una configuración guardada
  Future<bool> existeConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyConfiguracion);
  }
}
