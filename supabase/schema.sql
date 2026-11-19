-- Tasks Notebook: one row per person holding their whole task list.
-- Run this once in Supabase → SQL Editor → New query → Run.

create table if not exists public.notebooks (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb       not null,
  updated_at timestamptz not null default now()
);

-- Row Level Security: each person can only ever see and change their own row.
alter table public.notebooks enable row level security;

-- Signed-in users may use the table through the API (RLS below still limits them to their own row).
-- Guests (anon) get nothing.
revoke all on public.notebooks from anon;
grant select, insert, update on public.notebooks to authenticated;

drop policy if exists "Read own notebook"   on public.notebooks;
drop policy if exists "Create own notebook" on public.notebooks;
drop policy if exists "Update own notebook" on public.notebooks;

create policy "Read own notebook" on public.notebooks
  for select using (auth.uid() = user_id);

create policy "Create own notebook" on public.notebooks
  for insert with check (auth.uid() = user_id);

create policy "Update own notebook" on public.notebooks
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
