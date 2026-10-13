-- Bebometro: permanent accounts, two-way sync and account deletion.
--
-- * revision / server_updated_at on every synced table, maintained ONLY by the
--   server (trigger). The app reads back by (server_updated_at, id) and
--   detects concurrent edits by revision, never by the phone's clock.
-- * base_revision: the revision the app's edit was based on. On UPDATE, if it
--   is set and differs from the stored revision, the write is refused with
--   SQLSTATE PT409 (PostgREST answers HTTP 409); the app keeps both versions
--   for the person to choose. Rows sent without it (older app builds) behave
--   as before (last write wins).
-- * deleted_at on outings and places, so deletions travel as tombstones like
--   the other tables (nothing in the app hard-deletes synced rows).
-- * account_deletions: progress of the delete-account Edge Function, so a
--   partial failure can be retried. Only the service role touches it.
--
-- Requires 20261012000000..20261017000000. Idempotent; safe to run more than
-- once. Existing rows get revision 1 and server_updated_at = now(), so the
-- first read on a new device brings everything.

do $$
declare
  t text;
begin
  foreach t in array array['places','outings','custom_drinks','outing_drinks',
                           'outing_photos','outing_tabs','drink_entries'] loop
    execute format('alter table public.%I add column if not exists revision bigint not null default 1', t);
    execute format('alter table public.%I add column if not exists server_updated_at timestamptz not null default now()', t);
    execute format('alter table public.%I add column if not exists base_revision bigint', t);
    execute format('create index if not exists %I on public.%I (owner_id, server_updated_at, id)',
                   t || '_owner_sync_idx', t);
  end loop;
end $$;

alter table public.outings add column if not exists deleted_at timestamptz;
alter table public.places add column if not exists deleted_at timestamptz;

create or replace function public.bebometro_revision()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' then
    if new.base_revision is not null and new.base_revision <> old.revision then
      raise exception 'revision_conflict'
        using errcode = 'PT409',
              detail = format('stored revision %s, edit based on %s', old.revision, new.base_revision);
    end if;
    new.revision := old.revision + 1;
    new.base_revision := null;
  else
    -- On INSERT ... ON CONFLICT DO UPDATE the UPDATE branch sees the values
    -- produced here, so base_revision must survive this step to be checked.
    new.revision := 1;
  end if;
  new.server_updated_at := clock_timestamp();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array['places','outings','custom_drinks','outing_drinks',
                           'outing_photos','outing_tabs','drink_entries'] loop
    execute format('drop trigger if exists %I on public.%I', t || '_revision_trg', t);
    execute format(
      'create trigger %I before insert or update on public.%I '
      'for each row execute function public.bebometro_revision()',
      t || '_revision_trg', t);
  end loop;
end $$;

-- Progress of account deletions (service role only; no client policy).
create table if not exists public.account_deletions (
  user_id uuid primary key,
  status text not null default 'started'
    check (status in ('started','files_removed','rows_removed','done','failed')),
  last_error text,
  attempts integer not null default 0,
  started_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.account_deletions enable row level security;
revoke all on public.account_deletions from anon, authenticated;

notify pgrst, 'reload schema';
