import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'stations_event.dart';
part 'stations_state.dart';

class StationsBloc extends Bloc<StationsEvent, StationsState> {
  StationsBloc(this._repository, {int minBitrate = 0})
    : _minBitrate = minBitrate,
      super(const StationsState()) {
    on<StationsRequested>(_onRequested, transformer: restartable());
    on<StationsRefreshed>(_onRefreshed, transformer: restartable());
    on<StationsSearchChanged>(_onSearchChanged, transformer: restartable());
    on<StationsSortChanged>(_onSortChanged, transformer: restartable());
    on<StationsMinBitrateChanged>(
      _onMinBitrateChanged,
      transformer: restartable(),
    );
  }

  final StationRepository _repository;
  int _minBitrate;

  Future<void> _onRequested(
    StationsRequested event,
    Emitter<StationsState> emit,
  ) => _load(emit, showLoading: true);

  Future<void> _onRefreshed(
    StationsRefreshed event,
    Emitter<StationsState> emit,
  ) => _load(emit, showLoading: false);

  Future<void> _onSearchChanged(
    StationsSearchChanged event,
    Emitter<StationsState> emit,
  ) {
    emit(state.copyWith(query: event.query));
    return _load(emit, showLoading: true);
  }

  Future<void> _onSortChanged(
    StationsSortChanged event,
    Emitter<StationsState> emit,
  ) {
    emit(state.copyWith(sort: event.sort));
    return _load(emit, showLoading: true);
  }

  Future<void> _onMinBitrateChanged(
    StationsMinBitrateChanged event,
    Emitter<StationsState> emit,
  ) {
    if (_minBitrate == event.minBitrate) return Future.value();
    _minBitrate = event.minBitrate;
    return _load(emit, showLoading: true);
  }

  Future<void> _load(
    Emitter<StationsState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) emit(state.copyWith(status: StationsStatus.loading));
    try {
      final stations = await _repository.getStations(
        query: state.query,
        sort: state.sort,
        minBitrate: _minBitrate,
      );
      emit(
        state.copyWith(
          status: StationsStatus.success,
          stations: stations,
          clearError: true,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          status: StationsStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }
  }
}
