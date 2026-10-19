-- Bebometro: who drank each record, and per-person portions of a shared bottle.
--
-- Additive and idempotent; safe to run more than once. Apply in the Supabase SQL
-- Editor. The app keeps working before this is applied: a record that names a
-- person (a guest as consumer, or portions) is NOT sent in a degraded form
-- (another device would read it as a drink of the owner); it waits on the phone
-- with the "server not updated" notice until the columns exist. Ordinary
-- records of the owner (consumer_id and portions both null) are sent as before.
--
-- consumer_id : text, opaque id of a participant of the outing's tab
--               (outing_tabs.data.participants[].id). NULL means the owner
--               ("Voce"), which is how every record made before this existed is
--               read. A guest is never a row or an account.
-- portions    : jsonb object, only for a shared bottle/jug with per-person
--               portions: { "<participant id or 'me'>": <ml or null> }.
--
-- Participants live inside the tab document (same owner by RLS, same outing as
-- its key), so there is no foreign key to them. The app treats an unknown
-- consumer_id as "not assigned", never as the owner.

alter table public.drink_entries add column if not exists consumer_id text;
alter table public.drink_entries add column if not exists portions jsonb;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'drink_entries_consumer_len_chk'
  ) then
    alter table public.drink_entries
      add constraint drink_entries_consumer_len_chk
      check (consumer_id is null or char_length(consumer_id) between 1 and 64);
  end if;

  if not exists (
    select 1 from pg_constraint where conname = 'drink_entries_portions_object_chk'
  ) then
    alter table public.drink_entries
      add constraint drink_entries_portions_object_chk
      check (portions is null or jsonb_typeof(portions) = 'object');
  end if;

  -- A record is either one person's (consumer_id) or a shared bottle with
  -- portions, never both.
  if not exists (
    select 1 from pg_constraint where conname = 'drink_entries_one_attribution_chk'
  ) then
    alter table public.drink_entries
      add constraint drink_entries_one_attribution_chk
      check (portions is null or consumer_id is null);
  end if;
end $$;

-- The tab document may only move forward in schema_version: an older app
-- (which does not know participants who left or the automatic tab) must not
-- overwrite a tab saved by a newer one and silently drop that information.
create or replace function public.outing_tabs_keep_schema_version()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.schema_version < old.schema_version then
    raise exception
      'outing_tabs: schema_version % is older than the saved %; update the app',
      new.schema_version, old.schema_version
      using errcode = '22023';
  end if;
  return new;
end;
$$;

drop trigger if exists outing_tabs_keep_schema_version_trg on public.outing_tabs;
create trigger outing_tabs_keep_schema_version_trg
  before update on public.outing_tabs
  for each row execute function public.outing_tabs_keep_schema_version();

notify pgrst, 'reload schema';
