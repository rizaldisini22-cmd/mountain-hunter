name: build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: '3.22.0'

      # FIX GRADLE ERROR - INI KUNCINYA!
      - run: |
          mv lib/main.dart /tmp/main.dart
          rm -rf android
          flutter create --project-name mountain_hunter --org com.rizal.mountainhunter.
          mv /tmp/main.dart lib/main.dart

      - run: flutter pub add shared_preferences
      - run: flutter build apk --release

      - uses: actions/upload-artifact@v4
        with:
          name: mountain-hunter-100-levels-rapi
          path: build/app/outputs/flutter-apk/app-release.apk
