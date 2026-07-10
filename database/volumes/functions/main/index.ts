// =============================================================
// Konect - Supabase Edge Functions Router (Main Service)
// =============================================================

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const path = url.pathname.replace(/^\/functions\/v1/, "") || "/";

  // Route to moderate-comment
  if (path === "/moderate-comment") {
    const mod = await import("../moderate-comment/index.ts");
    return await mod.default(req);
  }

  // Route to compute-embedding (relevance scoring)
  if (path === "/compute-embedding") {
    const mod = await import("../compute-embedding/index.ts");
    return await mod.default(req);
  }

  // Health check
  if (path === "/" || path === "/health") {
    return new Response(
      JSON.stringify({ status: "ok", service: "konect-edge-functions" }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  }

  return new Response(
    JSON.stringify({ error: "Function not found", path }),
    { status: 404, headers: { "Content-Type": "application/json" } }
  );
});
