part of 'player_bloc.dart';

enum PlaybackStatus { idle, loading, playing, paused, error }

final class PlayerState extends Equatable {
  const PlayerState({
    this.status = PlaybackStatus.idle,
    this.station,
    this.volume = 1,
    this.errorMessage,
    this.sleepMinutes,
  });

  final PlaybackStatus status;
  final Station? station;
  final double volume;
  final String? errorMessage;
  final int? sleepMinutes;

  bool get isActive => station != null && status != PlaybackStatus.idle;

  bool get isPlaying => status == PlaybackStatus.playing;

  bool get isBuffering => status == PlaybackStatus.loading;

  PlayerState copyWith({
    PlaybackStatus? status,
    Station? station,
    double? volume,
    String? errorMessage,
    bool clearError = false,
    int? sleepMinutes,
    bool clearSleep = false,
  }) {
    return PlayerState(
      status: status ?? this.status,
      station: station ?? this.station,
      volume: volume ?? this.volume,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sleepMinutes: clearSleep ? null : (sleepMinutes ?? this.sleepMinutes),
    );
  }

  @override
  List<Object?> get props => [
    status,
    station,
    volume,
    errorMessage,
    sleepMinutes,
  ];
}
