import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  /// Reproduce un sonido de alarma
  static Future<void> playAlarm() async {
    try {
      // Establecer la fuente del audio
      await _player.setSource(AssetSource('sounds/timer.mp3'));

      // Reproducir el audio
      await _player.resume();
      
      // Detener después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () async {
        await _player.stop();
      });
    } catch (e) {
      await _player.stop();
    }
  }
}
