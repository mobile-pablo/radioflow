import 'package:domain/domain.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioController {
  AudioController() : _player = AudioPlayer();

  final AudioPlayer _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  double get volume => _player.volume;

  Future<void> playStation(Station station) async {
    final favicon = station.faviconUrl;
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(station.streamUrl),
        tag: MediaItem(
          id: station.uuid,
          title: station.name,
          artist: station.country.isEmpty ? 'Radio' : station.country,
          artUri: (favicon != null && favicon.isNotEmpty)
              ? Uri.tryParse(favicon)
              : null,
        ),
      ),
    );
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() => _player.play();

  Future<void> stop() => _player.stop();

  Future<void> setVolume(double value) =>
      _player.setVolume(value.clamp(0.0, 1.0));

  Future<void> dispose() => _player.dispose();
}
