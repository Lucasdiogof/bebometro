-- Bebometro: who pays for a drink record, apart from who drank it.
--
-- Additive and idempotent; safe to run more than once. Apply in the Supabase SQL
-- Editor. The app keeps working before this is applied: a record that names its
-- payers is NOT sent without them (another device would read it as paid by the
-- people who drank it); it waits on the phone with the "server not updated"
-- notice until the column exists. Records without payers (every record made
-- before this, and the water shortcut) are sent as before.
--
-- payers : jsonb object, { "<participant id or 'me'>": <weight> }. The weight is
--          the share of the cost split (all 1 = equal; a typed split keeps the
--          typed amounts in cents as weights, so they stay proportional if the
--          price is corrected). NULL = the old reading: the cost follows who
--          drank it. Participants live inside the outing's tab document, so
--          there is no foreign key; an unknown id is treated as "not on the tab",
--          never as the owner.
--
-- Nothing is rewritten: no existing row is changed by this migration.

alter table public.drink_entries add column if not exists payers jsonb;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'drink_entries_payers_object_chk'
  ) then
    alter table public.drink_entries
      add constraint drink_entries_payers_object_chk
      check (payers is null or jsonb_typeof(payers) = 'object');
  end if;
end $$;

notify pgrst, 'reload schema';
