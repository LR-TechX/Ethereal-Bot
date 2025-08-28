import os
import json
import asyncio
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OPENAI_BASE_URL = os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
TIMEOUT_SECONDS = float(os.getenv("TIMEOUT_SECONDS", "15"))
MAX_TOKENS = int(os.getenv("MAX_TOKENS", "256"))

app = FastAPI(title="CyberAI Proxy", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    answer: str

@app.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    message = (req.message or "").strip()
    if not message:
        raise HTTPException(status_code=400, detail="Message is required.")

    if not OPENAI_API_KEY:
        # Simple offline echo fallback if no key provided
        return ChatResponse(answer="[Proxy offline] Provide OPENAI_API_KEY to enable model replies.")

    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "Content-Type": "application/json",
    }

    payload = {
        "model": OPENAI_MODEL,
        "messages": [
            {"role": "system", "content": "You are CyberAI, a helpful cybersecurity assistant. Be concise."},
            {"role": "user", "content": message},
        ],
        "max_tokens": MAX_TOKENS,
        "temperature": 0.2,
    }

    try:
        async with httpx.AsyncClient(base_url=OPENAI_BASE_URL, timeout=TIMEOUT_SECONDS) as client:
            resp = await client.post("/chat/completions", headers=headers, json=payload)
            if resp.status_code != 200:
                raise HTTPException(status_code=502, detail=f"Upstream error: {resp.status_code} {resp.text}")
            data = resp.json()
            answer = data.get("choices", [{}])[0].get("message", {}).get("content", "").strip()
            if not answer:
                answer = "No answer returned by the model."
            return ChatResponse(answer=answer)
    except httpx.ReadTimeout:
        raise HTTPException(status_code=504, detail="LLM request timed out.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Proxy error: {e}")