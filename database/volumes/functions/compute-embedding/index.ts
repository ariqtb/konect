// =============================================================
// Konect - Compute Embedding + Relevance Score
//
// Flow:
//   1. Flutter INSERT opini baru (relevance_score=0.5, embedding=NULL)
//   2. Flutter panggil edge function ini dengan opinion_id, content, room_id
//   3. Edge function: fetch topic embedding, call OpenRouter, UPDATE opinion.embedding
//   4. Trigger auto_compute_opinion_relevance fires, set relevance_score
//
// Endpoint: POST /functions/v1/compute-embedding
// Body: { opinion_id, content, room_id }
// =============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OPENROUTER_URL = "https://openrouter.ai/api/v1/embeddings";
const MODEL = "openai/text-embedding-3-small";
const DIM = 1536;

const supabase = createClient(
  Deno.env.get("SUPABASE_URL") ?? "http://kong:8000",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
);

const OPENROUTER_KEY = Deno.env.get("OPENROUTER_API_KEY") ?? "";

interface EmbeddingResponse {
  data: Array<{ embedding: number[] }>;
}

export default async function handler(req: Request): Promise<Response> {
  const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Content-Type": "application/json",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers,
    });
  }

  if (!OPENROUTER_KEY) {
    return new Response(JSON.stringify({
      error: "OPENROUTER_API_KEY not set on server",
    }), { status: 500, headers });
  }

  try {
    const body = await req.json();
    const { opinion_id, content, room_id } = body;

    if (!opinion_id || !content || !room_id) {
      return new Response(JSON.stringify({
        error: "opinion_id, content, room_id required",
      }), { status: 400, headers });
    }

    // 1. Verify topic has embedding
    const { data: topic, error: topicErr } = await supabase
      .from("discussion_rooms")
      .select("id, embedding")
      .eq("id", room_id)
      .single();

    if (topicErr || !topic) {
      return new Response(JSON.stringify({
        error: "Topic not found",
        detail: topicErr?.message,
      }), { status: 404, headers });
    }

    if (!topic.embedding) {
      return new Response(JSON.stringify({
        error: "Topic embedding not computed. Run backfill migration first.",
      }), { status: 422, headers });
    }

    // 2. Call OpenRouter embeddings API
    const embRes = await fetch(OPENROUTER_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENROUTER_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: MODEL,
        input: content,
      }),
    });

    if (!embRes.ok) {
      const errText = await embRes.text();
      console.error("OpenRouter error:", embRes.status, errText);
      return new Response(JSON.stringify({
        error: "OpenRouter embedding failed",
        status: embRes.status,
        detail: errText.slice(0, 500),
      }), { status: 502, headers });
    }

    const embData: EmbeddingResponse = await embRes.json();
    const embedding = embData.data?.[0]?.embedding;

    if (!embedding || embedding.length !== DIM) {
      return new Response(JSON.stringify({
        error: `Invalid embedding from OpenRouter: got ${embedding?.length ?? 0} dims, expected ${DIM}`,
      }), { status: 502, headers });
    }

    // 3. UPDATE opinion.embedding → trigger auto_compute_opinion_relevance fires
    //    dan hitung relevance_score = 1.0 - cosine_distance
    const { error: updateErr } = await supabase
      .from("opinions")
      .update({ embedding: embedding as unknown as string })
      .eq("id", opinion_id);

    if (updateErr) {
      console.error("Update error:", updateErr);
      return new Response(JSON.stringify({
        error: "Failed to update opinion",
        detail: updateErr.message,
      }), { status: 500, headers });
    }

    // 4. Fetch updated opinion untuk return relevance_score
    const { data: updated } = await supabase
      .from("opinions")
      .select("id, relevance_score")
      .eq("id", opinion_id)
      .single();

    return new Response(JSON.stringify({
      success: true,
      opinion_id,
      relevance_score: updated?.relevance_score,
      embedding_dim: embedding.length,
      model: MODEL,
    }), { status: 200, headers });

  } catch (err) {
    console.error("Compute embedding error:", err);
    return new Response(JSON.stringify({
      error: err instanceof Error ? err.message : "Unknown error",
    }), { status: 500, headers });
  }
}
