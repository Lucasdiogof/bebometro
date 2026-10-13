-- Bebometro: places with search/map data.
--
-- * places: name given by the map data (provider_name), confirmed coordinates,
--   how they were obtained (location_source) and the provider id used only to
--   avoid duplicates. All optional: old rows stay valid.
-- * places_name_present now also accepts provider_name (a place chosen from a
--   search may have no nickname). A bare point still needs a nickname or an
--   address to be saved.
-- * outings: the outing's own copy of the provider name and coordinates.
--   Editing a saved place never rewrites these copies.
--
-- No coordinates = NULL in both columns (never 0,0); both or none.
-- Search data comes from Geoapify/OpenStreetMap (ODbL), whose terms allow
-- keeping it with attribution.
--
-- Requires 20261014000000. Idempotent; safe to run more than once. The app
-- keeps working until this is applied: the newer columns are optional and the
-- compatible part of each row is still sent.

alter table public.places add column if not exists provider_name text;
alter table public.places add column if not exists latitude double precision;
alter table public.places add column if not exists longitude double precision;
alter table public.places add column if not exists location_source text;
alter table public.places add column if not exists provider text;
alter table public.places add column if not exists provider_place_id text;

alter table public.outings add column if not exists place_name text;
alter table public.outings add column if not exists latitude double precision;
alter table public.outings add column if not exists longitude double precision;

do $$
begin
  -- places: coordinates in range, both or none.
  if not exists (select 1 from pg_constraint
      where conname = 'places_point_valid' and conrelid = 'public.places'::regclass) then
    alter table public.places add constraint places_point_valid check (
      (latitude is null and longitude is null) or
      (latitude between -90 and 90 and longitude between -180 and 180)
    );
  end if;
  if not exists (select 1 from pg_constraint
      where conname = 'places_location_source_values' and conrelid = 'public.places'::regclass) then
    alter table public.places add constraint places_location_source_values check (
      location_source is null or location_source in ('search','current_location','adjusted')
    );
  end if;
  -- A provider id only makes sense with its provider.
  if not exists (select 1 from pg_constraint
      where conname = 'places_provider_pair' and conrelid = 'public.places'::regclass) then
    alter table public.places add constraint places_provider_pair check (
      provider_place_id is null or provider is not null
    );
  end if;

  -- A name from the map data is enough to identify a saved place.
  if exists (select 1 from pg_constraint
      where conname = 'places_name_present' and conrelid = 'public.places'::regclass)
     and not exists (select 1 from pg_constraint
      where conname = 'places_name_present'
        and conrelid = 'public.places'::regclass
        and pg_get_constraintdef(oid) like '%provider_name%') then
    alter table public.places drop constraint places_name_present;
  end if;
  if not exists (select 1 from pg_constraint
      where conname = 'places_name_present' and conrelid = 'public.places'::regclass) then
    alter table public.places add constraint places_name_present check (
      coalesce(btrim(nickname), '') <> '' or
      coalesce(btrim(address), '') <> '' or
      coalesce(btrim(provider_name), '') <> ''
    );
  end if;

  -- outings: same rule for the outing's own copy of the point.
  if not exists (select 1 from pg_constraint
      where conname = 'outings_point_valid' and conrelid = 'public.outings'::regclass) then
    alter table public.outings add constraint outings_point_valid check (
      (latitude is null and longitude is null) or
      (latitude between -90 and 90 and longitude between -180 and 180)
    );
  end if;
end $$;

-- Lookup of "already saved" by provider id. Not unique on purpose: the app
-- offers to reuse a match, it does not forbid a second place.
create index if not exists places_owner_provider_idx
  on public.places (owner_id, provider, provider_place_id)
  where provider_place_id is not null;
