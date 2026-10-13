-- Bebometro: drinks and photos that belong to a single outing.
--
-- * outing_drinks: drinks registered by hand, read from a label photo or taken
--   from a menu photo. They live only inside their outing (outing_id); they
--   are not part of any catalog and are never read across outings.
-- * outing_photos: metadata of the photos. The files live in the PRIVATE
--   storage bucket 'outing-photos' under <owner>/<outing>/<photo>.jpg. There
--   are no public URLs.
-- * drink_entries.abv_source: where the ABV of a record came from when it is
--   not the own ABV of the catalog (label, menu, typed by the user).
--
-- Idempotent; safe to run more than once. Apply in the Supabase SQL Editor.
-- The app keeps working (and keeps its data on the device) until this is
-- applied; old, compatible rows are still synced meanwhile.

alter table public.drink_entries add column if not exists abv_source text;

do $$
begin
  if not exists (select 1 from pg_constraint
      where conname = 'drink_entries_abv_source_values'
        and conrelid = 'public.drink_entries'::regclass) then
    alter table public.drink_entries add constraint drink_entries_abv_source_values
      check (abv_source is null or abv_source in ('label','menu','typed','catalog'));
  end if;
end $$;

create table if not exists public.outing_drinks (
  id uuid primary key,
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  outing_id uuid not null references public.outings (id) on delete cascade,
  name text not null check (btrim(name) <> ''),
  category text not null,
  origin text not null default 'manual'
    check (origin in ('manual','label','menu')),
  brand text,
  style text,
  description text,
  volume_ml integer check (volume_ml is null or volume_ml > 0),
  abv_percent numeric check (abv_percent is null or (abv_percent >= 0 and abv_percent <= 100)),
  abv_source text check (abv_source is null or abv_source in ('label','menu','typed','catalog')),
  ingredients text[],
  components jsonb,
  reference_item_id text,
  advertised_cents integer check (advertised_cents is null or advertised_cents >= 0),
  photo_ids text[] not null default '{}',
  source_text text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists outing_drinks_outing_idx on public.outing_drinks (outing_id);
create index if not exists outing_drinks_owner_idx on public.outing_drinks (owner_id);

create table if not exists public.outing_photos (
  id uuid primary key,
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  outing_id uuid not null references public.outings (id) on delete cascade,
  kind text not null check (kind in ('label','menu')),
  storage_path text,
  uploaded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists outing_photos_outing_idx on public.outing_photos (outing_id);
create index if not exists outing_photos_owner_idx on public.outing_photos (owner_id);

-- Row level security: each user only touches their own rows.
alter table public.outing_drinks enable row level security;
alter table public.outing_photos enable row level security;

drop policy if exists outing_drinks_select_own on public.outing_drinks;
drop policy if exists outing_drinks_insert_own on public.outing_drinks;
drop policy if exists outing_drinks_update_own on public.outing_drinks;
drop policy if exists outing_drinks_delete_own on public.outing_drinks;
create policy outing_drinks_select_own on public.outing_drinks for select to authenticated
  using (owner_id = (select auth.uid()));
create policy outing_drinks_insert_own on public.outing_drinks for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy outing_drinks_update_own on public.outing_drinks for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy outing_drinks_delete_own on public.outing_drinks for delete to authenticated
  using (owner_id = (select auth.uid()));

drop policy if exists outing_photos_select_own on public.outing_photos;
drop policy if exists outing_photos_insert_own on public.outing_photos;
drop policy if exists outing_photos_update_own on public.outing_photos;
drop policy if exists outing_photos_delete_own on public.outing_photos;
create policy outing_photos_select_own on public.outing_photos for select to authenticated
  using (owner_id = (select auth.uid()));
create policy outing_photos_insert_own on public.outing_photos for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy outing_photos_update_own on public.outing_photos for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy outing_photos_delete_own on public.outing_photos for delete to authenticated
  using (owner_id = (select auth.uid()));

grant select, insert, update, delete on public.outing_drinks to authenticated;
grant select, insert, update, delete on public.outing_photos to authenticated;

-- An outing child may only point to an outing of the same owner.
create or replace function public.outing_child_same_owner()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.outings o
    where o.id = new.outing_id and o.owner_id = new.owner_id
  ) then
    raise exception 'outing does not belong to the same owner';
  end if;
  return new;
end;
$$;

drop trigger if exists outing_drinks_same_owner_trg on public.outing_drinks;
create trigger outing_drinks_same_owner_trg
  before insert or update of outing_id, owner_id on public.outing_drinks
  for each row execute function public.outing_child_same_owner();

drop trigger if exists outing_photos_same_owner_trg on public.outing_photos;
create trigger outing_photos_same_owner_trg
  before insert or update of outing_id, owner_id on public.outing_photos
  for each row execute function public.outing_child_same_owner();

-- Private bucket for the photo files: no public access, JPEG only, 8 MB each.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('outing-photos', 'outing-photos', false, 8388608, array['image/jpeg'])
on conflict (id) do update
  set public = false,
      file_size_limit = 8388608,
      allowed_mime_types = array['image/jpeg'];

-- Each user reaches only the objects under their own folder: <uid>/...
drop policy if exists outing_photos_objects_select on storage.objects;
drop policy if exists outing_photos_objects_insert on storage.objects;
drop policy if exists outing_photos_objects_update on storage.objects;
drop policy if exists outing_photos_objects_delete on storage.objects;
create policy outing_photos_objects_select on storage.objects for select to authenticated
  using (bucket_id = 'outing-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy outing_photos_objects_insert on storage.objects for insert to authenticated
  with check (bucket_id = 'outing-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy outing_photos_objects_update on storage.objects for update to authenticated
  using (bucket_id = 'outing-photos' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'outing-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy outing_photos_objects_delete on storage.objects for delete to authenticated
  using (bucket_id = 'outing-photos' and (storage.foldername(name))[1] = (select auth.uid())::text);

notify pgrst, 'reload schema';
