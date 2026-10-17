-- Read-only. One result table; run it whole in the SQL Editor.
-- Checks what the Edge Function `delete-account` needs from the database:
-- the storage bucket, the privileges of the service role and the progress log.
select 'bucket_outing_photos_exists' as check_name,
       (select count(*)::text from storage.buckets where id = 'outing-photos') as value
union all
select 'service_role_grants_' || t.table_name,
       coalesce((select string_agg(g.privilege_type, ',' order by g.privilege_type)
                 from information_schema.role_table_grants g
                 where g.table_schema = 'public' and g.table_name = t.table_name
                   and g.grantee = 'service_role'), 'none')
from (values ('outings'), ('custom_drinks'), ('drink_entries'), ('places'),
             ('outing_drinks'), ('outing_photos'), ('outing_tabs'),
             ('account_deletions')) as t(table_name)
union all
select 'rls_on_account_deletions',
       (select relrowsecurity::text from pg_class
        where oid = 'public.account_deletions'::regclass)
union all
select 'account_deletions_by_status',
       coalesce((select string_agg(status || '=' || n, ', ' order by status)
                 from (select status, count(*) as n
                       from public.account_deletions group by status) s), 'empty');
