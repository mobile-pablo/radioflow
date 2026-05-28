part of 'player_bloc.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

final class PlayStationRequested extends PlayerEvent {
  const PlayStationRequested(this.station, {this.queue = const []});

  final Station station;
  final List<Station> queue;

  @override
  List<Object?> get props => [station, queue];
}

final class PlayNext extends PlayerEvent {
  const PlayNext();
}

final class PlayPrevious extends PlayerEvent {
  const PlayPrevious();
}

final class PlayPauseToggled extends PlayerEvent {
  const PlayPauseToggled();
}

final class StopRequested extends PlayerEvent {
  const StopRequested();
}

final class VolumeChanged extends PlayerEvent {
  const VolumeChanged(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

final class VolumeNudged extends PlayerEvent {
  const VolumeNudged({required this.up});

  final bool up;

  @override
  List<Object?> get props => [up];
}

final class SleepTimerSet extends PlayerEvent {
  const SleepTimerSet(this.minutes);

  final int? minutes;

  @override
  List<Object?> get props => [minutes];
}

final class _PlaybackStatusUpdated extends PlayerEvent {
  const _PlaybackStatusUpdated(this.status);

  final PlaybackStatus status;

  @override
  List<Object?> get props => [status];
}

final class _TrackUpdated extends PlayerEvent {
  const _TrackUpdated(this.track);

  final String? track;

  @override
  List<Object?> get props => [track];
}
