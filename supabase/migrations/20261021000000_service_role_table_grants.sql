-- Bebometro: table privileges for the Edge Function `delete-account`.
--
-- The function runs with the service role and has to read and delete the
-- person's rows and record its progress in public.account_deletions. On the
-- project jiisoqkryhmtopaojyyu the service role only had REFERENCES, TRIGGER
-- and TRUNCATE on these tables, so every query failed with "permission
-- denied" and the deletion stopped before removing anything.
--
-- Scope: only the tables the function touches, only service_role. Nothing is
-- granted to anon or authenticated and row level security is left as it is
-- (the service role bypasses it by design). Idempotent.
grant select, insert, update, delete on
  public.outings,
  public.custom_drinks,
  public.drink_entries,
  public.places,
  public.outing_drinks,
  public.outing_photos,
  public.outing_tabs,
  public.account_deletions
to service_role;

notify pgrst, 'reload schema';
