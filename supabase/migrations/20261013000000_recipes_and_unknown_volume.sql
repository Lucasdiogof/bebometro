-- Bebometro: mixed drinks (recipes) and unknown volumes.
--
-- * drink_entries.container_ml / personal_ml become nullable: a mixed drink may
--   have no known final volume, and "unknown" must never be stored as 0.
--   The existing checks (> 0, personal + leftover <= container) keep applying
--   whenever a value is present (NULL passes a CHECK).
-- * drink_entries.composition (jsonb): snapshot of what was registered (recipe
--   reference, components, amounts, ABV). History never changes when the
--   catalog or the user's own recipes change.
-- * custom_drinks.components (jsonb) + volume_ml nullable: reusable personal
--   recipes.
--
-- Idempotent; safe to run more than once. Apply in the Supabase SQL Editor.

alter table public.drink_entries alter column container_ml drop not null;
alter table public.drink_entries alter column personal_ml drop not null;
alter table public.drink_entries add column if not exists composition jsonb;

alter table public.custom_drinks alter column volume_ml drop not null;
alter table public.custom_drinks add column if not exists components jsonb;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'drink_entries_composition_is_object'
      and conrelid = 'public.drink_entries'::regclass
  ) then
    alter table public.drink_entries
      add constraint drink_entries_composition_is_object
      check (composition is null or jsonb_typeof(composition) = 'object');
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'custom_drinks_components_is_array'
      and conrelid = 'public.custom_drinks'::regclass
  ) then
    alter table public.custom_drinks
      add constraint custom_drinks_components_is_array
      check (components is null or jsonb_typeof(components) = 'array');
  end if;
end $$;

-- Let the API pick up the new columns right away.
notify pgrst, 'reload schema';
