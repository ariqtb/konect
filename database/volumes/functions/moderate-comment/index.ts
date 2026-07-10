// =============================================================
// Konect - Comment Moderation Edge Function
//
// Flow:
//   1. Language detection (ind/eng only via heuristic)
//   2. Banned words check against banned_words table
//   3. INSERT to discussion_comments if clean
// =============================================================

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Supabase client
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "http://kong:8000";
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const supabase = createClient(supabaseUrl, supabaseKey);

// Cached banned words (refresh every 5 min)
let bannedWordsCache: { word: string; severity: string }[] | null = null;
let cacheTime = 0;
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

async function getBannedWords(): Promise<{ word: string; severity: string }[]> {
  const now = Date.now();
  if (bannedWordsCache && now - cacheTime < CACHE_TTL) {
    return bannedWordsCache;
  }
  const { data } = await supabase
    .from("banned_words")
    .select("word, severity")
    .eq("is_active", true);
  bannedWordsCache = data ?? [];
  cacheTime = now;
  return bannedWordsCache;
}

// Simple language detection (heuristic-based, no heavy dependency)
// Checks character patterns for Indonesian and English
function detectLanguage(text: string): "ind" | "eng" | "other" {
  const t = text.toLowerCase().trim();
  if (t.length < 5) return "ind"; // short text: default allow

  // Common Indonesian stopwords — strong signal
  const idSignals = [
    "yang", "di", "ke", "dari", "dan", "ini", "itu", "dengan", "untuk",
    "tidak", "akan", "dapat", "saya", "kamu", "kami", "kita", "mereka",
    "ada", "pada", "oleh", "sebagai", "dalam", "adalah", "sudah", "belum",
    "juga", "bisa", "telah", "akan", "lebih", "saja", "kalau", "karena",
    "jika", "sangat", "semua", "saat", "atau", "tetapi", "tapi", "pak",
    "bu", "mas", "mbak", "bang", "kak", "pak", "tolong", "mohon",
    "ya", "kok", "sih", "dong", "deh", "lah", "kah", "pun",
    "banget", "aja", "udah", "enggak", "gak", "ga", "nggak",
  ];

  const enSignals = [
    "the", "a", "an", "is", "are", "was", "were", "be", "been",
    "i", "you", "he", "she", "it", "we", "they", "my", "your",
    "his", "her", "its", "our", "their", "this", "that", "these",
    "those", "and", "or", "but", "if", "because", "so", "than",
    "very", "just", "also", "about", "can", "will", "would",
    "could", "should", "may", "might", "shall", "have", "has",
    "had", "do", "does", "did", "not", "no", "yes", "please",
    "thanks", "thank", "hello", "hi",
  ];

  // Count matching signals
  const words = t.split(/[\s,.\!?;:]+/);
  let idScore = 0;
  let enScore = 0;

  for (const word of words) {
    if (idSignals.includes(word)) idScore++;
    if (enSignals.includes(word)) enScore++;
  }

  if (idScore === 0 && enScore === 0) {
    // No clear signal — check for non-Latin script
    const nonLatin = /[\u0600-\u06FF\u0400-\u04FF\u4E00-\u9FFF\u3040-\u309F\uAC00-\uD7AF]/;
    if (nonLatin.test(t)) return "other";
    return "ind"; // Default to Indonesian for short/ambiguous text
  }

  return idScore >= enScore ? "ind" : "eng";
}

// Export default handler for main router
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

  try {
    const body = await req.json();
    const {
      content,
      opinion_id,
      user_id,
      latitude,
      longitude,
      is_anonymous,
      parent_id,
    } = body;

    // Validate
    if (!content?.trim()) {
      return new Response(
        JSON.stringify({ allowed: false, reason: "Komentar tidak boleh kosong" }),
        { status: 400, headers }
      );
    }
    if (!opinion_id || !user_id) {
      return new Response(
        JSON.stringify({ allowed: false, reason: "opinion_id dan user_id wajib diisi" }),
        { status: 400, headers }
      );
    }

    // Step 1: Language Detection
    const lang = detectLanguage(content);

    if (lang === "other") {
      return new Response(
        JSON.stringify({
          allowed: false,
          reason: "Hanya mendukung Bahasa Indonesia dan Inggris",
          detected_language: lang,
        }),
        { status: 200, headers }
      );
    }

    // Step 2: Banned Words Check
    const words = await getBannedWords();
    const lowerContent = content.toLowerCase();


    let matched: { word: string; severity: string } | null = null;

    for (const bw of words) {
      const lowerWord = bw.word.toLowerCase();
      if (lowerContent.includes(lowerWord)) {
        matched = bw;
        break;
      }
    }

    if (matched) {
      return new Response(
        JSON.stringify({
          allowed: false,
          reason: "Komentar mengandung kata tidak pantas",
          matched_word: matched.word,
          severity: matched.severity,
          detected_language: lang,
        }),
        { status: 200, headers }
      );
    }

    // Step 3: INSERT Comment
    const { data: comment, error: insertError } = await supabase
      .from("discussion_comments")
      .insert({
        opinion_id,
        user_id,
        parent_id: parent_id ?? null,
        content,
        is_anonymous: is_anonymous ?? false,
        latitude,
        longitude,
      })
      .select("id")
      .single();

    if (insertError) {
      console.error("Insert error:", insertError);
      return new Response(
        JSON.stringify({
          allowed: false,
          reason: "Gagal menyimpan komentar: " + insertError.message,
        }),
        { status: 500, headers }
      );
    }

    return new Response(
      JSON.stringify({
        allowed: true,
        comment_id: comment.id,
        detected_language: lang,
      }),
      { status: 201, headers }
    );
  } catch (err) {
    console.error("Moderation error:", err);
    return new Response(
      JSON.stringify({
        allowed: false,
        reason: err instanceof Error ? err.message : "Internal server error",
      }),
      { status: 500, headers }
    );
  }
}
