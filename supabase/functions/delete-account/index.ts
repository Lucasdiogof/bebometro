// Bebometro: deletes the CALLER's account. The user is taken from the JWT in
// the Authorization header (validated by Supabase Auth), never from the body,
// so nobody can delete someone else by sending an id. A body of
// {"dry_run": true} runs the authentication checks and returns without
// deleting anything (used to verify a deployment).
//
// Order, each step idempotent and recorded in public.account_deletions so a
// failure can simply be retried by calling again:
//   1. private photos in storage (outing-photos/<uid>/...), paginated;
//   2. the user's rows, children before parents;
//   3. the auth identity (last: until then the person can sign in and retry).
//
// Secrets come from the function environment (SUPABASE_URL,
// SUPABASE_SERVICE_ROLE_KEY are injected by Supabase). Nothing is logged
// except the step and a short error.
import { createClient } from "jsr:@supabase/supabase-js@2";

const BUCKET = "outing-photos";
const TABLES = [
  "drink_entries",
  "outing_tabs",
  "outing_photos",
  "outing_drinks",
  "outings",
  "custom_drinks",
  "places",
];

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const url = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  if (!token) return json({ error: "not_authenticated" }, 401);

  const admin = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  // Who is calling: validated by Auth, not trusted from the request body.
  const { data: who, error: whoErr } = await admin.auth.getUser(token);
  if (whoErr || !who?.user) return json({ error: "not_authenticated" }, 401);
  const user = who.user;
  if (user.is_anonymous) return json({ error: "anonymous_not_allowed" }, 403);

  // Optional dry run: proves that a valid session reaches this function and
  // passes the same checks, WITHOUT changing anything. The body is never
  // trusted for who to delete; it can only ask for this harmless check.
  let dryRun = false;
  try {
    const body = await req.json();
    dryRun = body?.dry_run === true;
  } catch (_) {
    // No body (the app sends none): a real deletion request.
  }

  // Recent sign-in required (the app asks for the password right before).
  const lastSignIn = user.last_sign_in_at ? Date.parse(user.last_sign_in_at) : 0;
  const recentSignIn = Date.now() - lastSignIn <= 10 * 60 * 1000;
  if (dryRun) {
    return json({ ok: true, dry_run: true, reauthentication_needed: !recentSignIn });
  }
  if (!recentSignIn) {
    return json({ error: "reauthentication_needed" }, 403);
  }

  const uid = user.id;
  const mark = async (status: string, lastError: string | null = null) => {
    await admin.from("account_deletions").upsert({
      user_id: uid,
      status,
      last_error: lastError,
      updated_at: new Date().toISOString(),
    });
  };

  const { data: existing } = await admin
    .from("account_deletions")
    .select("attempts")
    .eq("user_id", uid)
    .maybeSingle();
  await admin.from("account_deletions").upsert({
    user_id: uid,
    status: "started",
    attempts: (existing?.attempts ?? 0) + 1,
    updated_at: new Date().toISOString(),
  });

  try {
    // 1. Files: every object under <uid>/ (outing folders, plus anything at
    //    the root), repeated until nothing is left. A page is at most 1000
    //    entries, so a person with more than 1000 outing folders needs more
    //    than one pass. The guard stops a pass that removes nothing, so a
    //    listing that never empties cannot loop forever.
    const storage = admin.storage.from(BUCKET);
    for (let pass = 0; pass < 100; pass++) {
      const { data: entries, error: listErr } = await storage.list(uid, { limit: 1000 });
      if (listErr) throw new Error(`list: ${listErr.message}`);
      if (!entries || entries.length === 0) break;
      let removed = 0;
      // Files directly under <uid>/ have an id; folders do not.
      const rootFiles = entries.filter((f) => f.id).map((f) => `${uid}/${f.name}`);
      if (rootFiles.length > 0) {
        const { error: rmErr } = await storage.remove(rootFiles);
        if (rmErr) throw new Error(`remove: ${rmErr.message}`);
        removed += rootFiles.length;
      }
      for (const folder of entries.filter((f) => !f.id)) {
        const prefix = `${uid}/${folder.name}`;
        while (true) {
          const { data: files, error } = await storage.list(prefix, { limit: 1000 });
          if (error) throw new Error(`list files: ${error.message}`);
          const paths = (files ?? []).filter((f) => f.id).map((f) => `${prefix}/${f.name}`);
          if (paths.length === 0) break;
          const { error: rmErr } = await storage.remove(paths);
          if (rmErr) throw new Error(`remove: ${rmErr.message}`);
          removed += paths.length;
          if (paths.length < 1000) break;
        }
      }
      if (removed === 0) break;
    }
    await mark("files_removed");

    // 2. Rows, children first (cascades would also do it, but explicit
    //    deletion keeps the order and works even if a FK changes).
    for (const table of TABLES) {
      const { error } = await admin.from(table).delete().eq("owner_id", uid);
      if (error && error.code !== "42P01") throw new Error(`${table}: ${error.code}`);
    }
    await mark("rows_removed");

    // 3. The identity, last.
    const { error: delErr } = await admin.auth.admin.deleteUser(uid);
    if (delErr && !/not.?found/i.test(delErr.message)) {
      throw new Error(`auth: ${delErr.message}`);
    }
    await mark("done");
    return json({ ok: true });
  } catch (e) {
    const msg = e instanceof Error ? e.message.slice(0, 200) : "unknown";
    console.error(`delete-account failed: ${msg}`);
    await mark("failed", msg);
    return json({ error: "partial_failure", retry: true }, 500);
  }
});
