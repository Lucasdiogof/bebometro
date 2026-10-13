-- Bebometro: the tab (comanda) of an outing.
--
-- One row per outing (id = outing id) holding the whole tab as a single jsonb
-- document: participants (nicknames only), extra items, links to drink
-- records (ids only), service/discount settings, the split and the payments
-- people reported. Saving it as one document keeps participants, shares and
-- payments from ever being half-saved. It is NOT linked to outing_drinks, the
-- catalog or any price history.
--
-- Idempotent; safe to run more than once. Apply in the Supabase SQL Editor.
-- Requires 20261015000000 (it reuses public.outing_child_same_owner()). The app
-- keeps working, and keeps the tab on the device, until this is applied.

create table if not exists public.outing_tabs (
  id uuid primary key,
  owner_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  outing_id uuid not null references public.outings (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  schema_version integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint outing_tabs_one_per_outing unique (outing_id)
);

create index if not exists outing_tabs_owner_idx on public.outing_tabs (owner_id);

alter table public.outing_tabs enable row level security;

drop policy if exists outing_tabs_select_own on public.outing_tabs;
drop policy if exists outing_tabs_insert_own on public.outing_tabs;
drop policy if exists outing_tabs_update_own on public.outing_tabs;
drop policy if exists outing_tabs_delete_own on public.outing_tabs;
create policy outing_tabs_select_own on public.outing_tabs for select to authenticated
  using (owner_id = (select auth.uid()));
create policy outing_tabs_insert_own on public.outing_tabs for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy outing_tabs_update_own on public.outing_tabs for update to authenticated
  using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy outing_tabs_delete_own on public.outing_tabs for delete to authenticated
  using (owner_id = (select auth.uid()));

grant select, insert, update, delete on public.outing_tabs to authenticated;

-- The tab may only point to an outing of the same owner.
drop trigger if exists outing_tabs_same_owner_trg on public.outing_tabs;
create trigger outing_tabs_same_owner_trg
  before insert or update of outing_id, owner_id on public.outing_tabs
  for each row execute function public.outing_child_same_owner();

notify pgrst, 'reload schema';
