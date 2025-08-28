# CyberAI — Flutter Cybersecurity Chatbot

CyberAI is a Flutter 3 application featuring a cybersecurity assistant chatbot with offline knowledge base, persistent learning via Hive, optional online LLM fallback through a FastAPI proxy, Wi‑Fi scanning, password strength analysis, phishing checks, local notifications, daily tips, and a cyberpunk UI.

## Project Structure

- `cyber_ai_app/`: Flutter app
- `server/`: Optional FastAPI proxy for online LLM
- `.github/workflows/flutter-android.yml`: CI to build release APK

## App Features

- Chat fallback order: Knowledge Base → Local Memory → Proxy (if enabled) → "I'm learning…"
- Tools: Wi‑Fi Scan (/24 ping sweep), Password Strength, Phishing Check
- Tips: Daily tips with local notifications and scheduling
- Settings: Toggle online intelligence, set proxy URL, clear/export memory

## Requirements

- Flutter stable (3.x) and Dart SDK (>=3.3.0)
- Android SDK; minSdkVersion 24

## Getting Started (App)

```bash
cd cyber_ai_app
flutter pub get
flutter run
```

Build release APK:

```bash
flutter build apk --release
```

## Android Permissions & Security

Declared in `android/app/src/main/AndroidManifest.xml`:
- INTERNET
- POST_NOTIFICATIONS (Android 13+)
- ACCESS_WIFI_STATE, CHANGE_WIFI_STATE
- ACCESS_NETWORK_STATE
- ACCESS_FINE_LOCATION

Cleartext is disabled by default; only loopback (`127.0.0.1`, `localhost`) is permitted via `res/xml/network_security_config.xml`.

## Optional FastAPI Proxy

```bash
cd server
cp .env.example .env
# set OPENAI_API_KEY and optionally OPENAI_BASE_URL, OPENAI_MODEL
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Docker:

```bash
cd server
docker build -t cyberai-proxy .
docker run --rm -p 8000:8000 --env-file .env cyberai-proxy
```

Then set the app Settings → `LLM_PROXY_URL` to `https://your-domain` or `http://10.0.2.2:8000` (Android emulator) or your LAN IP.

## CI (GitHub Actions)

Push to `main`/`master` to build the release APK. Download the artifact `app-release.apk` from the workflow run.

## Troubleshooting

- Notifications on Android 13+: grant the notification permission.
- Wi‑Fi scan requires location permission for SSID; ensure it is granted.
- Ping sweep may be slow or require `ping` binary; a TCP connect fallback is used.
- If KB not loading, ensure assets are listed in `pubspec.yaml` and run `flutter pub get`.
- Proxy CORS errors: ensure server is reachable and CORS is configured.

## License

MIT
