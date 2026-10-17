-- Read-only. Shows where each delete-account attempt stopped (run in the SQL Editor).
select user_id, status, attempts, last_error, updated_at
from public.account_deletions
order by updated_at desc
limit 20;
