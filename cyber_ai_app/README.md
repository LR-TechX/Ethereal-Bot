# CyberAI App (Flutter)

A dark cyberpunk Flutter chatbot with offline knowledge, local memory, optional online LLM proxy, Wi‑Fi scanning tools, password strength, phishing checks, notifications, and daily tips.

## Setup

```bash
flutter pub get
# If platform folders missing
flutter create .
flutter run
```

Build release APK:

```bash
flutter build apk --release
```

## Permissions

- INTERNET
- POST_NOTIFICATIONS (Android 13+)
- ACCESS_WIFI_STATE, CHANGE_WIFI_STATE, ACCESS_NETWORK_STATE
- ACCESS_FINE_LOCATION (for SSID)

## Settings

- Toggle: Use Online Intelligence
- Field: LLM_PROXY_URL (e.g., http://10.0.2.2:8000)
- Clear Learned Memory
- Export Memory (JSON)

## Proxy

Use the server in `../server`. Configure `OPENAI_API_KEY` and point `LLM_PROXY_URL` to it.