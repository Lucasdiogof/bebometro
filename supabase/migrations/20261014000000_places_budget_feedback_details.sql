-- Bebometro: saved places, drinks budget and optional feedback details.
--
-- * places: the user's private, reusable places. Outings keep their own copy of
--   the place name/address/city/state (columns that already exist or are added
--   here), so editing a place never rewrites past outings.
-- * outings.place_id: optional link to a saved place (ON DELETE SET NULL; the
--   outing's own snapshot stays).
-- * outings.budget_cents: optional drinks budget.
-- * outings.feedback_wake / feedback_hangover / feedback_note: optional details
--   of the personal account after an outing.
--
-- Idempotent; safe to run more than once. Apply in the Supabase SQL Editor.
-- The app keeps working (and keeps its data on the device) until this is
-- applied; the compatible part of each outing is still sent.

create table if not exists public.places (
  id uuid primary key,
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  type text not null default 'other'
    check (type in ('bar','club','barbecue','home','restaurant','beach','other')),
  nickname text,
  address text,
  city text,
  state text check (state is null or state ~ '^[A-Z]{2}$'),
  favorite boolean not null default false,
  archived_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint places_name_present check (
    coalesce(btrim(nickname), '') <> '' or coalesce(btrim(address), '') <> ''
  )
);

create index if not exists places_owner_idx on public.places (owner_id);

alter table public.outings add column if not exists place_id uuid
  references public.places (id) on delete set null;
alter table public.outings add column if not exists city text;
alter table public.outings add column if not exists state text;
alter table public.outings add column if not exists budget_cents integer;
alter table public.outings add column if not exists feedback_wake text;
alter table public.outings add column if not exists feedback_hangover text;
alter table public.outings add column if not exists feedback_note text;

do $$
begin
  if not exists (select 1 from pg_constraint
      where conname = 'outings_state_format' and conrelid = 'public.outings'::regclass) then
    alter table public.outings add constraint outings_state_format
      check (state is null or state ~ '^[A-Z]{2}$');
  end if;
  if not exists (select 1 from pg_constraint
      where conname = 'outings_budget_positive' and conrelid = 'public.outings'::regclass) then
    alter table public.outings add constraint outings_budget_positive
      check (budget_cents is null or budget_cents > 0);
  end if;
  if not exists (select 1 from pg_constraint
      where conname = 'outings_feedback_wake_values' and conrelid = 'public.outings'::regclass) then
    alter table public.outings add constraint outings_feedback_wake_values
      check (feedback_wake is null or feedback_wake in ('great','ok','tired','bad'));
  end if;
  if not exists (select 1 from pg_constraint
      where conname = 'outings_feedback_hangover_values' and conrelid = 'public.outings'::regclass) then
    alter table public.outings add constraint outings_feedback_hangover_values
      check (feedback_hangover is null or feedback_hangover in ('none','mild','moderate','strong'));
  end if;
end $$;

create index if not exists outings_place_idx on public.outings (place_id);

-- Row level security: each user only touches their own places.
alter table public.places enable row level security;

drop policy if exists places_select_own on public.places;
drop policy if exists places_insert_own on public.places;
drop policy if exists places_update_own on public.places;
drop policy if exists places_delete_own on public.places;
create policy places_select_own on public.places for select to authenticated
  using (owner_id = (select auth.uid()));
create policy places_insert_own on public.places for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy places_update_own on public.places for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy places_delete_own on public.places for delete to authenticated
  using (owner_id = (select auth.uid()));

grant select, insert, update, delete on public.places to authenticated;

-- An outing may only point to a place of the same owner.
create or replace function public.outings_place_same_owner()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.place_id is not null and not exists (
    select 1 from public.places p
    where p.id = new.place_id and p.owner_id = new.owner_id
  ) then
    raise exception 'place does not belong to the same owner';
  end if;
  return new;
end;
$$;

drop trigger if exists outings_place_same_owner_trg on public.outings;
create trigger outings_place_same_owner_trg
  before insert or update of place_id, owner_id on public.outings
  for each row execute function public.outings_place_same_owner();

notify pgrst, 'reload schema';
