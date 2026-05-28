# RadioFlow

**RadioFlow** is a mobile app that lets you listen to radio stations from around the world. You can browse through thousands of stations, search for your favorites, tap to play instantly, and save stations you love for quick access later.

The app works on both iPhones (iOS) and Android phones. The station information comes from a free public database that anyone can access—no special account or key required.

## What You Can Do

- **Browse and search** thousands of radio stations from around the world
- **Sort stations** by popularity, number of votes, or alphabetically
- **Play any station** instantly by tapping it
- **Control playback** with play/pause buttons and a volume slider
- **See what's playing** with a player bar that shows the station name and details
- **Play in the background** while using other apps; control playback from your lock screen or notifications
- **Save favorites** so you can find them instantly next time
- **Use offline mode** and see helpful error messages if something goes wrong
- **Use the app in English or Spanish**

## How It's Built

RadioFlow is built using **Flutter**, a framework that lets developers write one set of code that works on both iPhones and Android phones (rather than writing separate code for each).

The code is organized into three main parts:
- **Visual design** (colors, buttons, layouts, themes)
- **Core logic** (how the app gets and stores station information)
- **Data handling** (connecting to the online database and fetching station lists)

This organization makes it easy to change how the app looks or works without breaking anything else.

## Getting Started

### What You Need

- Flutter 3.27 or newer (a tool for building mobile apps)
- Xcode (for iPhone) and/or Android Studio (for Android)

### Setting Up the Mapbox 3D Globe

The app includes a 3D globe map view. To use this feature, you need tokens (free accounts) from Mapbox:

1. Create a free account at [account.mapbox.com](https://account.mapbox.com)
2. Get your **public token** (starts with `pk.`) and create a file called `env.json` in the main folder with:
   ```json
   { "MAPBOX_TOKEN": "pk.your-public-token" }
   ```
3. Get your **secret download token** (starts with `sk.` and has downloads permission):
   - For Android: add it to `~/.gradle/gradle.properties`
   - For iPhone: add it to `~/.netrc`

The regular radio station browsing works without any tokens—only the globe feature needs this setup.

### Running the App

```bash
# Install dependencies
flutter pub get

# Generate code files
dart run melos run gen

# Run the app
flutter run --dart-define-from-file=env.json

# For iPhone (first time only)
cd ios && pod install && cd ..
flutter run --dart-define-from-file=env.json
```

## Testing

```bash
# Run app tests
flutter test

# Run data handling tests
cd packages/data && flutter test
```

## Available Platforms

- **iPhone** (iOS)
- **Android**

(Android was used for the demo video)

## Credits

- Station data: [Radio Browser](https://www.radio-browser.info/)
