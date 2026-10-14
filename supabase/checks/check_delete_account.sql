-- Bebometro: read-only checks around account deletion. Nothing here changes data.
-- Run in the Supabase SQL Editor of project jiisoqkryhmtopaojyyu (one block at a time).

-- ---------------------------------------------------------------------------
-- BEFORE deleting the test account: find its id and what it owns.
-- Replace the e-mail, run, and COPY the user_id (after the deletion the e-mail
-- no longer maps to anything).
-- ---------------------------------------------------------------------------
select id as user_id, email, is_anonymous, created_at, last_sign_in_at
from auth.users
where email = 'COLOQUE-O-EMAIL-DA-CONTA-DE-TESTE@exemplo.com';

-- ---------------------------------------------------------------------------
-- Counts by owner, BEFORE and AFTER. Replace the uuid below in the CTE.
-- Expected AFTER the deletion: every number 0, user_exists = false.
-- ---------------------------------------------------------------------------
with p as (select 'COLE-O-USER-ID-AQUI'::uuid as uid)
select
  (select count(*) from auth.users u, p where u.id = p.uid)               as user_exists,
  (select count(*) from public.outings o, p where o.owner_id = p.uid)       as outings,
  (select count(*) from public.drink_entries d, p where d.owner_id = p.uid) as drink_entries,
  (select count(*) from public.custom_drinks c, p where c.owner_id = p.uid) as custom_drinks,
  (select count(*) from public.outing_drinks od, p where od.owner_id = p.uid) as outing_drinks,
  (select count(*) from public.outing_photos op, p where op.owner_id = p.uid) as outing_photos,
  (select count(*) from public.outing_tabs t, p where t.owner_id = p.uid)   as outing_tabs,
  (select count(*) from public.places pl, p where pl.owner_id = p.uid)      as places,
  (select count(*) from storage.objects so, p
     where so.bucket_id = 'outing-photos'
       and (storage.foldername(so.name))[1] = p.uid::text)                  as photo_files;

-- ---------------------------------------------------------------------------
-- Progress recorded by the Edge Function (only the service role writes it).
-- status: started -> files_removed -> rows_removed -> done (or failed + last_error).
-- A 'failed' or half-way row means "call delete again"; it continues where it stopped.
-- ---------------------------------------------------------------------------
select user_id, status, attempts, last_error, started_at, updated_at
from public.account_deletions
where user_id = 'COLE-O-USER-ID-AQUI'::uuid;
