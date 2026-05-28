# RadioFlow

Listen to radio stations from around the world. Browse and search thousands of
stations, tap to play, control playback, and keep your favorites one tap away.

Built with Flutter for **iOS and Android**. Station data comes from the free
[Radio Browser API](https://www.radio-browser.info/) (no API key required).

## Features

- Browse all stations with search and sorting (popularity, votes, A–Z)
- Tap any station to start streaming instantly
- Playback controls: play/pause and volume (slider + steps)
- Persistent mini-player and an expandable Now Playing view with station metadata
- Background playback with lock-screen / notification controls
- Mark favorites and access them any time (stored on device)
- Loading, empty, error-with-retry and offline states throughout
- English and Spanish localization

## Tech stack

- **Flutter** with a **melos** monorepo (Dart pub workspaces)
- **flutter_bloc** for state management
- **get_it** for dependency injection
- **dio + retrofit** for networking, with a logging interceptor and mirror failover
- **auto_mappr** for DTO → entity mapping
- **freezed** for immutable entities
- **just_audio** (+ `just_audio_background`) for streaming
- **shared_preferences** for favorites and settings
- **go_router** for navigation

## Architecture

Feature-first presentation on top of layered packages:

```
radioflow/                 # the Flutter app (features, UI, DI, routing)
  packages/
    core/                  # design system, shared widgets, theme
    domain/                # entities + repository contracts (pure Dart)
    data/                  # Radio Browser client, DTOs, mappers, repositories
```

The app depends on `core`, `domain`, and `data`. `data` implements the
contracts defined in `domain`. UI talks to BLoCs/Cubits, which talk to
repositories from `domain` — the data layer is swappable without touching the UI.

## Getting started

### Prerequisites

- Flutter 3.27 or newer (developed on 3.38.5, Dart 3.10)
- Xcode (for iOS) and/or Android Studio + SDK (for Android)

### Install and run

```bash
flutter pub get

# Generate freezed / json_serializable / retrofit / auto_mappr code
dart run melos run gen

# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run
```

No API key is needed — Radio Browser is open and free.

## Tests

```bash
flutter test                       # app BLoC/cubit tests
cd packages/data && flutter test   # DTO → entity mapping test
```

## Platform to compile

iOS and Android. Android is the primary target used for the demo recording.

## Attributions

- Station data: [Radio Browser](https://www.radio-browser.info/)
