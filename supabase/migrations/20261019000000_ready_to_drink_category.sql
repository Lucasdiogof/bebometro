-- Adds the drink category 'ready_to_drink' (bottled/canned mixed drinks, ice,
-- hard seltzers) to the two tables that restrict the category. Existing codes
-- are unchanged. Idempotent: the old check is found by its definition (its
-- name is generated) and replaced by a named one. outing_drinks has no check.
-- Until this runs, the app keeps rows with the new category pending (the
-- server answers 23514) and shows "waiting for a server update".

do $$
declare
  t text;
  c record;
begin
  foreach t in array array['custom_drinks', 'drink_entries'] loop
    for c in
      select con.conname
      from pg_constraint con
      join pg_class rel on rel.oid = con.conrelid
      join pg_namespace nsp on nsp.oid = rel.relnamespace
      where nsp.nspname = 'public'
        and rel.relname = t
        and con.contype = 'c'
        and pg_get_constraintdef(con.oid) like '%category%'
    loop
      execute format('alter table public.%I drop constraint %I', t, c.conname);
    end loop;
    execute format(
      'alter table public.%I add constraint %I check (category in '
      '(''beer'',''draft'',''cocktail'',''spirit'',''wine'',''non_alcoholic'',''water'',''ready_to_drink''))',
      t, t || '_category_check');
  end loop;
end $$;
