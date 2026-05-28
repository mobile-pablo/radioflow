import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: FavoritesStatus.loading));
    final favorites = await _repository.getFavorites();
    emit(state.copyWith(status: FavoritesStatus.loaded, favorites: favorites));
  }

  Future<void> toggle(Station station) async {
    try {
      if (state.isFavorite(station.uuid)) {
        await _repository.remove(station.uuid);
      } else {
        await _repository.add(station);
      }
      await load();
    } on Failure {
      return;
    }
  }

  Future<void> remove(String uuid) async {
    try {
      await _repository.remove(uuid);
      await load();
    } on Failure {
      return;
    }
  }
}
