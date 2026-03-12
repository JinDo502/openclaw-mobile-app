# OpenClaw Mobile App (Flutter)

Flutter-based cross-platform management app for OpenClaw.

## Prereqs
- Flutter (via FVM recommended)
- Mock Server (from backend repo/workdir)

## Quick start
1) Start mock server:
```bash
cd mock-server
npm run dev
# BaseURL http://localhost:8787
```

2) Run app:
```bash
# Option A: dart-define
flutter run --dart-define API_BASE_URL=http://localhost:8787

# Option B: edit .env (if you wire dotenv)
```

## API base URL
The app expects an API base URL configured via `--dart-define API_BASE_URL=...`.

## Status
Scaffold only (repo bootstrap).