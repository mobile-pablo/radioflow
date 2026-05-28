import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radioflow/features/stations/bloc/stations_bloc.dart';

class MockStationRepository extends Mock implements StationRepository {}

void main() {
  const station = Station(
    uuid: '1',
    name: 'Jazz FM',
    streamUrl: 'http://stream',
    country: 'UK',
    tags: ['jazz'],
  );

  late MockStationRepository repository;

  setUpAll(() => registerFallbackValue(StationSort.popularity));
  setUp(() => repository = MockStationRepository());

  void stubStations(List<Station> result) {
    when(
      () => repository.getStations(
        query: any(named: 'query'),
        sort: any(named: 'sort'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => result);
  }

  group('StationsBloc', () {
    test('emits success with stations on request', () async {
      stubStations([station]);
      final bloc = StationsBloc(repository);
      bloc.add(const StationsRequested());
      await pumpEventQueue();
      expect(bloc.state.status, StationsStatus.success);
      expect(bloc.state.stations, [station]);
      await bloc.close();
    });

    test('emits failure when the repository throws', () async {
      when(
        () => repository.getStations(
          query: any(named: 'query'),
          sort: any(named: 'sort'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(const NetworkFailure());
      final bloc = StationsBloc(repository);
      bloc.add(const StationsRequested());
      await pumpEventQueue();
      expect(bloc.state.status, StationsStatus.failure);
      expect(bloc.state.errorMessage, isNotNull);
      await bloc.close();
    });

    test('passes the query through on search', () async {
      stubStations([]);
      final bloc = StationsBloc(repository);
      bloc.add(const StationsSearchChanged('jazz'));
      await pumpEventQueue();
      expect(bloc.state.query, 'jazz');
      verify(
        () => repository.getStations(
          query: 'jazz',
          sort: any(named: 'sort'),
          limit: any(named: 'limit'),
        ),
      ).called(1);
      await bloc.close();
    });
  });
}
