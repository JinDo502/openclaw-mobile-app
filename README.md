# openclaw-mobile-app

Flutter management app (M1/P0).

## Quick start (local)

Prereqs: Flutter SDK installed.

```bash
cd app
flutter pub get
flutter run --dart-define API_BASE_URL=http://localhost:8787
```

## Config

- `API_BASE_URL`: backend/mock base url.

## CI

GitHub Actions runs lint/test/build.
