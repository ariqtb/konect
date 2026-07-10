// =============================================================
// Konect - ML Relevance Scorer
// Supabase Edge Function (Deno) — OpenRouter API
//
// Deploy: supabase functions deploy compute-score
// Test:   curl -X POST http://localhost:54321/functions/v1/compute-score \
//          -H "Authorization: Bearer $ANON_KEY" \
//          -H "Content-Type: application/json" \
//          -d '{"topic":"Distribusi pupuk","opinion":"Setiap bulan telat"}'
// =============================================================

import { serve } from "https://deno.land/std@0.210.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface ScoreRequest {
  topic: string;
  opinion: string;
}

interface BatchRequest {
  topic: string;
  opinions: string[];
}

serve(async (req) => {
  // CORS headers
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Content-Type": "application/json",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  try {
    const body = await req.json();
    const path = new URL(req.url).pathname;
    const action = path.split("/").pop(); // 'score' | 'batch'

    switch (action) {
      case "batch":
        return await handleBatch(body as BatchRequest, headers);
      default:
        return await handleSingle(body as ScoreRequest, headers);
    }
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : "Unknown error" }),
      { status: 500, headers },
    );
  }
});

// --------------------------------------------------------------
// Single: score satu pasang (topic, opinion)
// --------------------------------------------------------------
async function handleSingle(req: ScoreRequest, headers: HeadersInit): Promise<Response> {
  const { topic, opinion } = req;
  if (!topic || !opinion) {
    return new Response(JSON.stringify({ error: "topic and opinion are required" }), {
      status: 400,
      headers,
    });
  }

  const score = await callOpenRouter(topic, opinion);
  return new Response(JSON.stringify({ score }), { headers });
}

// --------------------------------------------------------------
// Batch: score banyak opinions untuk satu topic
// --------------------------------------------------------------
async function handleBatch(req: BatchRequest, headers: HeadersInit): Promise<Response> {
  const { topic, opinions } = req;
  if (!topic || !opinions?.length) {
    return new Response(JSON.stringify({ error: "topic and opinions[] are required" }), {
      status: 400,
      headers,
    });
  }

  // Batch paralel — maks 5 concurrent
  const results: number[] = [];
  const chunkSize = 5;
  for (let i = 0; i < opinions.length; i += chunkSize) {
    const chunk = opinions.slice(i, i + chunkSize);
    const scores = await Promise.all(
      chunk.map((op) => callOpenRouter(topic, op)),
    );
    results.push(...scores);
  }

  return new Response(JSON.stringify({ scores: results }), { headers });
}

// --------------------------------------------------------------
// Call OpenRouter API
// --------------------------------------------------------------
async function callOpenRouter(topic: string, opinion: string): Promise<number> {
  const apiKey = Deno.env.get("OPENROUTER_KEY");
  if (!apiKey) {
    console.warn("OPENROUTER_KEY not set — returning default 0.5");
    return 0.5;
  }

  const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "HTTP-Referer": Deno.env.get("APP_URL") ?? "https://konect.app",
      "X-Title": "Konect MVP",
    },
    body: JSON.stringify({
      model: "mistralai/mistral-7b-instruct:free",
      messages: [
        {
          role: "system",
          content:
            "You are a relevance scorer. Given a Topic and an Opinion, rate how relevant the opinion is to the topic. Return ONLY a single number between 0.0 (completely irrelevant) and 1.0 (perfectly relevant). No explanation, no extra text.",
        },
        {
          role: "user",
          content: `Topic: ${topic}\nOpinion: ${opinion}\nScore:`,
        },
      ],
      max_tokens: 5,
      temperature: 0,
    }),
  });

  if (!response.ok) {
    console.error("OpenRouter error:", response.status, await response.text());
    return 0.5; // graceful fallback
  }

  const data = await response.json();
  const raw = data.choices?.[0]?.message?.content?.trim() ?? "0.5";
  const score = parseFloat(raw);

  // Clamp ke 0.0-1.0
  return Math.max(0, Math.min(1, isNaN(score) ? 0.5 : score));
}
