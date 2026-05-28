part of 'stations_bloc.dart';

enum StationsStatus { initial, loading, success, failure }

final class StationsState extends Equatable {
  const StationsState({
    this.status = StationsStatus.initial,
    this.stations = const [],
    this.query = '',
    this.sort = StationSort.popularity,
    this.errorMessage,
  });

  final StationsStatus status;
  final List<Station> stations;
  final String query;
  final StationSort sort;
  final String? errorMessage;

  bool get isEmpty => status == StationsStatus.success && stations.isEmpty;

  StationsState copyWith({
    StationsStatus? status,
    List<Station>? stations,
    String? query,
    StationSort? sort,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StationsState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, stations, query, sort, errorMessage];
}
