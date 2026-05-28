part of 'stations_bloc.dart';

sealed class StationsEvent extends Equatable {
  const StationsEvent();

  @override
  List<Object?> get props => [];
}

final class StationsRequested extends StationsEvent {
  const StationsRequested();
}

final class StationsRefreshed extends StationsEvent {
  const StationsRefreshed();
}

final class StationsSearchChanged extends StationsEvent {
  const StationsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class StationsSortChanged extends StationsEvent {
  const StationsSortChanged(this.sort);

  final StationSort sort;

  @override
  List<Object?> get props => [sort];
}

final class StationsMinBitrateChanged extends StationsEvent {
  const StationsMinBitrateChanged(this.minBitrate);

  final int minBitrate;

  @override
  List<Object?> get props => [minBitrate];
}
