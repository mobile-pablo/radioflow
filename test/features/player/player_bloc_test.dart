import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:mocktail/mocktail.dart';
import 'package:radioflow/features/player/audio/audio_controller.dart';
import 'package:radioflow/features/player/bloc/player_bloc.dart';

class MockAudioController extends Mock implements AudioController {}

void main() {
  const station = Station(
    uuid: '1',
    name: 'Jazz FM',
    streamUrl: 'http://stream',
  );

  late MockAudioController audio;
  late StreamController<ja.PlayerState> stateController;

  setUpAll(() => registerFallbackValue(station));

  setUp(() {
    audio = MockAudioController();
    stateController = StreamController<ja.PlayerState>.broadcast();
    when(() => audio.playerStateStream).thenAnswer((_) => stateController.stream);
    when(() => audio.volume).thenReturn(1);
    when(() => audio.dispose()).thenAnswer((_) async {});
  });

  tearDown(() => stateController.close());

  group('PlayerBloc', () {
    test('play sets the requested station and asks the engine to play', () async {
      when(() => audio.playStation(any())).thenAnswer((_) async {});
      final bloc = PlayerBloc(audio);
      bloc.add(const PlayStationRequested(station));
      await pumpEventQueue();
      expect(bloc.state.station, station);
      verify(() => audio.playStation(station)).called(1);
      await bloc.close();
    });

    test('play surfaces an error when the engine throws', () async {
      when(() => audio.playStation(any())).thenThrow(Exception('boom'));
      final bloc = PlayerBloc(audio);
      bloc.add(const PlayStationRequested(station));
      await pumpEventQueue();
      expect(bloc.state.status, PlaybackStatus.error);
      await bloc.close();
    });

    test('volume change is applied and stored', () async {
      when(() => audio.setVolume(any())).thenAnswer((_) async {});
      final bloc = PlayerBloc(audio);
      bloc.add(const VolumeChanged(0.5));
      await pumpEventQueue();
      expect(bloc.state.volume, 0.5);
      verify(() => audio.setVolume(0.5)).called(1);
      await bloc.close();
    });
  });
}
