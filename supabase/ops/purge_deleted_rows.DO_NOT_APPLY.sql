-- =====================================================================
-- NAO APLICAR sem autorizacao explicita do dono.
-- Prepared, NOT executed, NOT a migration (kept outside supabase/migrations
-- on purpose so nothing applies it automatically).
-- =====================================================================
--
-- Purpose: physically remove rows that the user deleted (deleted_at set) once
-- they are older than the retention period. The floor is 90 days (the function
-- never goes below it); the DEFAULT is 180 days after the sync analysis in
-- docs/app-store/privacy-audit.md (secao Retencao). The owner decides the final value.
--
-- Why the window matters (verified in lib/core/sync and the migrations): a deleted
-- row is a TOMBSTONE that other devices receive on their next pull (cursor on
-- server_updated_at). Push only sends rows with a pending local edit, as an upsert by
-- UUID. If the tombstone is purged before a device pulled it, that device keeps the
-- item visible forever and, if it edits it, the upsert INSERTS it again (resurrection).
-- No server-side bound exists for how long a device stays offline, so no window removes
-- the risk; a longer window only makes it rarer.
--
-- Extra safety rules in this function:
--   * outing_photos: only rows whose storage_path is already null (object removed
--     by the app or by step A), so no file is ever orphaned.
--   * outings: only when it has NO live child row (children cascade on delete, a
--     purge must never delete live records through the cascade).
--
-- Properties:
--   * Idempotent: running it twice removes nothing more the second time.
--   * Restricted: only rows with deleted_at older than p_days; never live rows.
--   * In batches: at most p_batch rows per table per run; repeat until 0.
--   * Dry run by default (p_apply = false): only counts.
--   * Backup first: with p_apply = true the rows are copied to
--     purge_backup.<table>_<yyyymmdd> inside the SAME transaction, then deleted.
--   * Order: children before parents, like the delete-account function.
--
-- Photos: deleting outing_photos rows does NOT delete the files. Files in
-- Supabase Storage must be removed through the Storage API (deleting rows of
-- storage.objects in SQL leaves the bytes behind). Do step A (below) BEFORE
-- the SQL purge, otherwise the paths are lost.
--
-- Step A (prepared description, not run): list the paths
--     select storage_path from public.outing_photos
--     where deleted_at < now() - interval '180 days' and storage_path is not null;
--   then remove them with the Storage API, e.g. with the service role in a one-off script:
--     await admin.storage.from('outing-photos').remove(paths /* up to 1000 per call */);
--   and only then run this file with p_apply = true.
--
-- Rollback plan: before p_apply = true, take a Supabase backup/point-in-time
-- marker (or export the tables). After an apply, rows can be restored from
-- purge_backup.<table>_<yyyymmdd> with INSERT ... SELECT. Storage files removed in
-- step A cannot be restored: keep that step for last and run it only on a list that
-- the owner reviewed.
--
-- Risk to weigh before choosing the period: a device that stayed offline longer than
-- the period still holds the deleted row locally with no tombstone on the server and
-- can upload it again (the record would reappear). 90 days is a balance; the
-- longer the period, the smaller that risk.
--
-- Usage (SQL Editor), after authorization:
--   select * from public.purge_deleted_rows(180, 500, false);  -- dry run: counts
--   select * from public.purge_deleted_rows(180, 500, true);   -- apply one batch

create schema if not exists purge_backup;

create or replace function public.purge_deleted_rows(
  p_days  integer default 180,
  p_batch integer default 500,
  p_apply boolean default false
) returns table (tbl text, candidates bigint, purged bigint)
language plpgsql
security invoker
as $$
declare
  -- Children first.
  t text;
  tables text[] := array['outing_photos','outing_drinks','outing_tabs','drink_entries',
                         'outings','custom_drinks','places'];
  cutoff timestamptz := now() - make_interval(days => greatest(p_days, 90));
  extra text;
  suffix text := to_char(now(), 'YYYYMMDD');
  n_cand bigint;
  n_del  bigint;
begin
  if p_batch < 1 or p_batch > 5000 then
    raise exception 'p_batch must be between 1 and 5000';
  end if;

  foreach t in array tables loop
    extra := case t
      when 'outing_photos' then ' and storage_path is null'
      when 'outings' then
        ' and not exists (select 1 from public.drink_entries c where c.outing_id = r.id and c.deleted_at is null)'
        || ' and not exists (select 1 from public.outing_drinks c where c.outing_id = r.id and c.deleted_at is null)'
        || ' and not exists (select 1 from public.outing_photos c where c.outing_id = r.id and c.deleted_at is null)'
        || ' and not exists (select 1 from public.outing_tabs c where c.outing_id = r.id and c.deleted_at is null)'
      else '' end;
    execute format('select count(*) from public.%I r where deleted_at is not null and deleted_at < $1%s', t, extra)
      into n_cand using cutoff;
    n_del := 0;

    if p_apply and n_cand > 0 then
      execute format('create table if not exists purge_backup.%I (like public.%I including all)',
                     t || '_' || suffix, t);
      execute format($q$
        with batch as (
          select id from public.%1$I r
          where deleted_at is not null and deleted_at < $1%3$s
          order by deleted_at
          limit $2
        ), saved as (
          insert into purge_backup.%2$I
          select r.* from public.%1$I r join batch b on b.id = r.id
          on conflict do nothing
          returning id
        ), gone as (
          delete from public.%1$I r using batch b where r.id = b.id
          returning r.id
        )
        select count(*) from gone
      $q$, t, t || '_' || suffix, extra) into n_del using cutoff, p_batch;
    end if;

    tbl := t; candidates := n_cand; purged := n_del;
    return next;
  end loop;
end;
$$;

-- Not granted to anon/authenticated: only the owner running it in the SQL Editor.
revoke all on function public.purge_deleted_rows(integer, integer, boolean) from public, anon, authenticated;
