-- Origin of a drink record created by a lock-screen "Mais uma" (iOS 17+).
-- Additive and idempotent: existing rows keep NULL (manual and older records
-- never get an invented origin). origin_tapped_at is the original tap time and
-- is never changed by the app; consumed_at stays the (correctable) time of the
-- drink. Until this runs, the app uploads these rows without the three columns,
-- keeps them pending locally and retries with them later (nothing is lost).

alter table public.drink_entries
  add column if not exists entry_origin text,
  add column if not exists origin_command_id text,
  add column if not exists origin_tapped_at timestamptz;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'drink_entries_entry_origin_check'
      and conrelid = 'public.drink_entries'::regclass
  ) then
    alter table public.drink_entries
      add constraint drink_entries_entry_origin_check
      check (
        entry_origin is null
        or (entry_origin = 'lock_screen'
            and origin_command_id is not null
            and origin_tapped_at is not null)
      );
  end if;
end $$;
