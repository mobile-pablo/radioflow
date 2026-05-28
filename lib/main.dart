import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app/app.dart';
import 'app/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');
  if (mapboxToken.isNotEmpty) MapboxOptions.setAccessToken(mapboxToken);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mobile.pablo.radioflow.audio',
    androidNotificationChannelName: 'RadioFlow',
    androidNotificationOngoing: true,
  );
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
  await configureDependencies();
  runApp(const RadioFlowApp());
}
