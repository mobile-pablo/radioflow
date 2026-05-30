#!/bin/bash
set -a
source .env
set +a
flutter build ios --dart-define=MAPBOX_TOKEN="$MAPBOX_TOKEN" "$@"
