-- Bebometro: initial schema.
-- Every row belongs to the (anonymous) user that created it. Rows are written
-- by the app with client-generated UUIDs, so retrying an upsert never
-- duplicates data. Money is stored in cents; timestamps are timestamptz (UTC).
--
-- Requires: Authentication > Providers > "Allow anonymous sign-ins" enabled.

create table if not exists public.outings (
  id uuid primary key,
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  type text not null check (type in ('bar','club','barbecue','home','restaurant','beach','other')),
  nickname text,
  address text,
  started_at timestamptz not null,
  ended_at timestamptz,
  status text not null check (status in ('active','ended')),
  feedback_mood text check (feedback_mood in ('smooth','cheerful','drunk','wasted')),
  feedback_status text not null default 'pending'
    check (feedback_status in ('pending','answered','snoozed','dismissed')),
  feedback_snoozed_until timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint outings_place_present check (
    coalesce(btrim(nickname), '') <> '' or coalesce(btrim(address), '') <> ''
  ),
  constraint outings_end_after_start check (ended_at is null or ended_at >= started_at),
  constraint outings_status_matches_end check (
    (status = 'active' and ended_at is null) or (status = 'ended' and ended_at is not null)
  )
);

-- Only one running outing per user.
create unique index if not exists outings_one_active_per_owner
  on public.outings (owner_id) where status = 'active';
create index if not exists outings_owner_started_idx
  on public.outings (owner_id, started_at desc);

create table if not exists public.custom_drinks (
  id uuid primary key,
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null check (btrim(name) <> ''),
  category text not null check (category in
    ('beer','draft','cocktail','spirit','wine','non_alcoholic','water')),
  brand text,
  style text,
  volume_ml integer not null check (volume_ml > 0),
  -- null = unknown, which is not the same as 0.
  abv_percent numeric(5,2) check (abv_percent is null or (abv_percent >= 0 and abv_percent <= 100)),
  ingredients text[],
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists custom_drinks_owner_idx on public.custom_drinks (owner_id);

-- A serving the user declares to have consumed. Drink data is copied into the
-- row so later catalog edits never change history.
create table if not exists public.drink_entries (
  id uuid primary key,
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  outing_id uuid not null references public.outings (id) on delete cascade,
  consumed_at timestamptz not null,

  -- Snapshot of the drink.
  name text not null,
  category text not null check (category in
    ('beer','draft','cocktail','spirit','wine','non_alcoholic','water')),
  brand text,
  style text,
  presentation text,
  catalog_item_id text,
  abv_percent numeric(5,2) check (abv_percent is null or (abv_percent >= 0 and abv_percent <= 100)),
  ingredients text[],

  -- Volumes (ml). personal_ml is what the user drank, container_ml the whole
  -- serving (e.g. a shared bottle).
  container_ml integer not null check (container_ml > 0),
  is_shared boolean not null default false,
  people_count integer not null default 1 check (people_count >= 1),
  personal_ml integer not null check (personal_ml >= 0),
  leftover_ml integer not null default 0 check (leftover_ml >= 0),

  -- Payment is separate from consumption. paid_cents is what the user paid;
  -- bill_total_cents is the whole bill when shared (optional).
  price_kind text not null default 'unknown'
    check (price_kind in ('informed','complimentary','unknown')),
  paid_cents integer check (paid_cents is null or paid_cents >= 0),
  bill_total_cents integer check (bill_total_cents is null or bill_total_cents >= 0),
  -- Where the price came from; only 'user' for now (room for future estimates).
  price_source text check (price_source is null or price_source in ('user','estimate')),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,

  constraint drink_entries_split_fits check (personal_ml + leftover_ml <= container_ml),
  constraint drink_entries_price_consistent check (
    (price_kind = 'informed' and paid_cents is not null)
    or (price_kind = 'complimentary' and coalesce(paid_cents, 0) = 0)
    or (price_kind = 'unknown' and paid_cents is null)
  )
);

create index if not exists drink_entries_outing_idx
  on public.drink_entries (outing_id, consumed_at);
create index if not exists drink_entries_owner_idx on public.drink_entries (owner_id);

-- Row level security: each user only touches their own rows.
alter table public.outings enable row level security;
alter table public.custom_drinks enable row level security;
alter table public.drink_entries enable row level security;

do $$
declare
  t text;
begin
  foreach t in array array['outings', 'custom_drinks', 'drink_entries'] loop
    execute format('drop policy if exists %I on public.%I', t || '_select_own', t);
    execute format('drop policy if exists %I on public.%I', t || '_insert_own', t);
    execute format('drop policy if exists %I on public.%I', t || '_update_own', t);
    execute format('drop policy if exists %I on public.%I', t || '_delete_own', t);
    execute format(
      'create policy %I on public.%I for select to authenticated using (owner_id = (select auth.uid()))',
      t || '_select_own', t);
    execute format(
      'create policy %I on public.%I for insert to authenticated with check (owner_id = (select auth.uid()))',
      t || '_insert_own', t);
    execute format(
      'create policy %I on public.%I for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()))',
      t || '_update_own', t);
    execute format(
      'create policy %I on public.%I for delete to authenticated using (owner_id = (select auth.uid()))',
      t || '_delete_own', t);
  end loop;
end $$;

-- Keep drink entries attached to an outing of the same owner.
create or replace function public.drink_entries_same_owner()
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

drop trigger if exists drink_entries_same_owner_trg on public.drink_entries;
create trigger drink_entries_same_owner_trg
  before insert or update of outing_id, owner_id on public.drink_entries
  for each row execute function public.drink_entries_same_owner();

grant select, insert, update, delete on public.outings to authenticated;
grant select, insert, update, delete on public.custom_drinks to authenticated;
grant select, insert, update, delete on public.drink_entries to authenticated;
