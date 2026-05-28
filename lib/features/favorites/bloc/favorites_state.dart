part of 'favorites_cubit.dart';

enum FavoritesStatus { initial, loading, loaded }

final class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
  });

  final FavoritesStatus status;
  final List<Station> favorites;

  bool isFavorite(String uuid) => favorites.any((s) => s.uuid == uuid);

  FavoritesState copyWith({FavoritesStatus? status, List<Station>? favorites}) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object?> get props => [status, favorites];
}
