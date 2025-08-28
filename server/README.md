# CyberAI FastAPI Proxy

A minimal proxy that exposes `POST /chat` to forward messages to an OpenAI‑compatible API.

## Quickstart

```bash
cd server
cp .env.example .env
# Edit .env and set OPENAI_API_KEY (and optionally OPENAI_BASE_URL, OPENAI_MODEL)
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Docker:

```bash
cd server
cp .env.example .env
docker build -t cyberai-proxy .
docker run --rm -p 8000:8000 --env-file .env cyberai-proxy
```

## Endpoint

- POST `/chat`
  - Request: `{ "message": "..." }`
  - Response: `{ "answer": "..." }`

CORS is enabled for development convenience. Use a reverse proxy in production.