import 'dart:async';

import 'package:domain/domain.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioController {
  AudioController();

  final AndroidEqualizer _equalizer = AndroidEqualizer();
  late final AudioPlayer _player = AudioPlayer(
    audioPipeline: AudioPipeline(androidAudioEffects: [_equalizer]),
  );

  AndroidEqualizer get equalizer => _equalizer;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<IcyMetadata?> get icyMetadataStream => _player.icyMetadataStream;

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
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Stream connection timeout'),
    );
    await _player.play().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('Playback timeout'),
    );
  }

  Future<void> pause() => _player.pause();

  Future<void> resume() => _player.play();

  Future<void> stop() => _player.stop();

  Future<void> setVolume(double value) =>
      _player.setVolume(value.clamp(0.0, 1.0));

  Future<void> dispose() => _player.dispose();
}
