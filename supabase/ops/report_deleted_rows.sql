-- READ-ONLY. Counts the soft-deleted rows (deleted_at) per table and by age.
-- Run in the Supabase SQL Editor. Changes nothing.
-- Companion of supabase/ops/purge_deleted_rows.DO_NOT_APPLY.sql and docs/app-store/privacy-audit.md (secao Retencao).

with t as (
  select 'outings' as tbl, deleted_at from public.outings where deleted_at is not null
  union all select 'places', deleted_at from public.places where deleted_at is not null
  union all select 'custom_drinks', deleted_at from public.custom_drinks where deleted_at is not null
  union all select 'drink_entries', deleted_at from public.drink_entries where deleted_at is not null
  union all select 'outing_drinks', deleted_at from public.outing_drinks where deleted_at is not null
  union all select 'outing_photos', deleted_at from public.outing_photos where deleted_at is not null
  union all select 'outing_tabs', deleted_at from public.outing_tabs where deleted_at is not null
)
select tbl,
       count(*)                                                   as deleted_total,
       count(*) filter (where deleted_at < now() - interval '30 days')  as older_than_30d,
       count(*) filter (where deleted_at < now() - interval '90 days')  as older_than_90d,
       count(*) filter (where deleted_at < now() - interval '180 days') as older_than_180d,
       min(deleted_at)                                            as oldest
from t
group by tbl
order by tbl;

-- Photos already marked as deleted whose file may still be in the bucket
-- (storage_path is cleared by the app only after the object was removed).
select count(*) as deleted_photos_with_object_still_referenced
from public.outing_photos
where deleted_at is not null and storage_path is not null;
