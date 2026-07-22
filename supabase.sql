-- ============================================================
--  wdyt.live — database setup for Supabase
--  Paste this WHOLE file into: Supabase -> SQL Editor -> Run
--  Safe to run once on a fresh project.
-- ============================================================

-- 1) The votes table: one row per (poll, voter).
create table public.votes (
  poll_id    text        not null check (char_length(poll_id)  between 1 and 64),
  voter_id   uuid        not null,
  choice     text        not null check (char_length(choice)   between 1 and 16),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (poll_id, voter_id)
);

-- 2) Row Level Security: the database itself enforces what visitors may do.
alter table public.votes enable row level security;

-- Anyone may cast a vote...
create policy "anyone_can_vote"
  on public.votes for insert
  to anon, authenticated
  with check (true);

-- ...read votes (rows contain only random ids and yes/no — no personal data)...
create policy "anyone_can_read"
  on public.votes for select
  to anon, authenticated
  using (true);

-- ...and update a vote (the trigger below enforces the 15-second lock).
create policy "vote_can_be_changed"
  on public.votes for update
  to anon, authenticated
  using (true)
  with check (true);

-- NO delete policy on purpose: votes can never be deleted by visitors.

-- 3) Server-side 15-second lock — cannot be bypassed from the browser.
create or replace function public.enforce_vote_lock()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.poll_id <> old.poll_id or new.voter_id <> old.voter_id then
    raise exception 'immutable_keys';
  end if;
  if new.choice is distinct from old.choice
     and (now() - old.updated_at) < interval '15 seconds' then
    raise exception 'vote_locked';
  end if;
  new.created_at := old.created_at;   -- creation time can never be rewritten
  new.updated_at := now();
  return new;
end;
$$;

create trigger trg_vote_lock
  before update on public.votes
  for each row execute function public.enforce_vote_lock();

-- 4) Aggregated results the page reads (tiny payload, no raw rows needed).
create view public.poll_results
  with (security_invoker = on) as
  select poll_id, choice, count(*)::int as votes
  from public.votes
  group by poll_id, choice;

grant select on public.poll_results to anon, authenticated;

-- 5) Live updates: broadcast vote changes so open pages refresh instantly.
alter publication supabase_realtime add table public.votes;
