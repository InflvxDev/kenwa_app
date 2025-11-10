import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  /// Reproduce un sonido de alarma durante 3 segundos
  static Future<void> playAlarm() async {
    try {
      await _player.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      // Manejar el error de reproducción aquí
    }
  }
}
