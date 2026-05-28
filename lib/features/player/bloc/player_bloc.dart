import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as ja;

import '../audio/audio_controller.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc(this._audio) : super(const PlayerState()) {
    on<PlayStationRequested>(_onPlayStation);
    on<PlayPauseToggled>(_onTogglePlayPause);
    on<StopRequested>(_onStop);
    on<VolumeChanged>(_onVolumeChanged);
    on<VolumeNudged>(_onVolumeNudged);
    on<SleepTimerSet>(_onSleepTimerSet);
    on<_PlaybackStatusUpdated>(_onStatusUpdated);
    on<_TrackUpdated>(_onTrackUpdated);

    _subscription = _audio.playerStateStream.listen(
      (playerState) => add(_PlaybackStatusUpdated(_mapStatus(playerState))),
    );
    _icySubscription = _audio.icyMetadataStream.listen(
      (metadata) => add(_TrackUpdated(metadata?.info?.title)),
    );
  }

  final AudioController _audio;
  late final StreamSubscription<ja.PlayerState> _subscription;
  late final StreamSubscription<ja.IcyMetadata?> _icySubscription;
  Timer? _sleepTimer;

  Future<void> _onPlayStation(
    PlayStationRequested event,
    Emitter<PlayerState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PlaybackStatus.loading,
        station: event.station,
        clearError: true,
        clearTrack: true,
      ),
    );
    try {
      await _audio.playStation(event.station);
    } catch (_) {
      emit(
        state.copyWith(
          status: PlaybackStatus.error,
          errorMessage: const PlaybackFailure().message,
        ),
      );
    }
  }

  Future<void> _onTogglePlayPause(
    PlayPauseToggled event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.station == null) return;
    if (state.isPlaying) {
      await _audio.pause();
    } else {
      await _audio.resume();
    }
  }

  Future<void> _onStop(StopRequested event, Emitter<PlayerState> emit) async {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    await _audio.stop();
    emit(const PlayerState());
  }

  void _onSleepTimerSet(SleepTimerSet event, Emitter<PlayerState> emit) {
    _sleepTimer?.cancel();
    final minutes = event.minutes;
    if (minutes == null) {
      _sleepTimer = null;
      emit(state.copyWith(clearSleep: true));
      return;
    }
    _sleepTimer = Timer(
      Duration(minutes: minutes),
      () => add(const StopRequested()),
    );
    emit(state.copyWith(sleepMinutes: minutes));
  }

  Future<void> _onVolumeChanged(
    VolumeChanged event,
    Emitter<PlayerState> emit,
  ) async {
    final clamped = event.volume.clamp(0.0, 1.0);
    await _audio.setVolume(clamped);
    emit(state.copyWith(volume: clamped));
  }

  Future<void> _onVolumeNudged(
    VolumeNudged event,
    Emitter<PlayerState> emit,
  ) async {
    final next = (state.volume + (event.up ? 0.1 : -0.1)).clamp(0.0, 1.0);
    await _audio.setVolume(next);
    emit(state.copyWith(volume: next));
  }

  void _onStatusUpdated(
    _PlaybackStatusUpdated event,
    Emitter<PlayerState> emit,
  ) {
    if (state.status == PlaybackStatus.error &&
        event.status != PlaybackStatus.playing) {
      return;
    }
    if (state.station == null && event.status != PlaybackStatus.idle) return;
    emit(
      state.copyWith(
        status: event.status,
        clearError: event.status == PlaybackStatus.playing,
      ),
    );
  }

  void _onTrackUpdated(_TrackUpdated event, Emitter<PlayerState> emit) {
    final track = event.track?.trim();
    if (track == null || track.isEmpty) {
      emit(state.copyWith(clearTrack: true));
    } else {
      emit(state.copyWith(track: track));
    }
  }

  PlaybackStatus _mapStatus(ja.PlayerState playerState) {
    switch (playerState.processingState) {
      case ja.ProcessingState.idle:
        return PlaybackStatus.idle;
      case ja.ProcessingState.loading:
      case ja.ProcessingState.buffering:
        return PlaybackStatus.loading;
      case ja.ProcessingState.ready:
        return playerState.playing
            ? PlaybackStatus.playing
            : PlaybackStatus.paused;
      case ja.ProcessingState.completed:
        return PlaybackStatus.paused;
    }
  }

  @override
  Future<void> close() async {
    _sleepTimer?.cancel();
    await _subscription.cancel();
    await _icySubscription.cancel();
    await _audio.dispose();
    return super.close();
  }
}
