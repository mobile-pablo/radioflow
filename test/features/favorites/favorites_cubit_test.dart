import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radioflow/features/favorites/bloc/favorites_cubit.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  const station = Station(
    uuid: '1',
    name: 'Jazz FM',
    streamUrl: 'http://stream',
  );

  late MockFavoritesRepository repository;

  setUpAll(() => registerFallbackValue(station));
  setUp(() => repository = MockFavoritesRepository());

  group('FavoritesCubit', () {
    test('load exposes stored favorites', () async {
      when(() => repository.getFavorites()).thenAnswer((_) async => [station]);
      final cubit = FavoritesCubit(repository);
      await cubit.load();
      expect(cubit.state.status, FavoritesStatus.loaded);
      expect(cubit.state.favorites, [station]);
    });

    test('toggle adds a station that is not yet a favorite', () async {
      when(() => repository.add(any())).thenAnswer((_) async {});
      when(() => repository.getFavorites()).thenAnswer((_) async => [station]);
      final cubit = FavoritesCubit(repository);
      await cubit.toggle(station);
      verify(() => repository.add(station)).called(1);
      expect(cubit.state.isFavorite(station.uuid), isTrue);
    });

    test('toggle removes a station that is already a favorite', () async {
      when(() => repository.getFavorites()).thenAnswer((_) async => [station]);
      when(() => repository.remove(any())).thenAnswer((_) async {});
      final cubit = FavoritesCubit(repository);
      await cubit.load();

      when(() => repository.getFavorites()).thenAnswer((_) async => []);
      await cubit.toggle(station);

      verify(() => repository.remove(station.uuid)).called(1);
      expect(cubit.state.favorites, isEmpty);
    });
  });
}
