#!/bin/bash
set -a
source .env
set +a
flutter run --dart-define=MAPBOX_TOKEN="$MAPBOX_TOKEN" "$@"
