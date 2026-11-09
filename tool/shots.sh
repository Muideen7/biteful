#!/bin/sh
# Website and store screenshots from the iOS simulator, with a clean status
# bar. Runs integration_test/store_shots_test.dart and captures the
# simulator each time it prints SHOT:<name>.
#   tool/shots.sh <out-dir> [device-id]
set -eu
OUT=${1:?out dir}
DEV=${2:-booted}
mkdir -p "$OUT"
xcrun simctl status_bar "$DEV" override --time 9:41 --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 --batteryState charged --batteryLevel 100
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/store_shots_test.dart \
  -d "$( [ "$DEV" = booted ] && xcrun simctl list devices booted | grep -oE '[0-9A-F-]{36}' | head -1 || echo "$DEV")" 2>&1 |
while IFS= read -r line; do
  echo "$line"
  case "$line" in
    *SHOT:*) name=${line##*SHOT:}; xcrun simctl io "$DEV" screenshot "$OUT/$name.png" >/dev/null 2>&1 && echo "  captured $name" ;;
  esac
done
xcrun simctl status_bar "$DEV" clear
