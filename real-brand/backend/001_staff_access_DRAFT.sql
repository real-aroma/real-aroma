-- REAL AROMA staff access foundation (DRAFT; NOT APPLIED)
-- Run in a NEW dedicated Supabase project, not the live challenge project.
-- Review with a database/security engineer before production deployment.
begin;
create extension if not exists pgcrypto;

create table if not exists public.staff_accounts (
  user_id uuid primary key references auth.users(id) on delete restrict,
  staff_code text not null unique check (staff_code ~ '^RA-T[0-9]{3,}$'),
  display_name text not null,
  role text not null default 'instructor' check (role in ('admin','instructor')),
  status text not null default 'active' check (status in ('active','paused','inactive')),
  created_at timestamptz not null default now(),
  deactivated_at timestamptz
);
create table if not exists public.instructor_profiles (
  user_id uuid primary key references public.staff_accounts(user_id) on delete restrict,
  public_bio text,
  specialties text[] not null default '{}',
  company_name text,
  registration_number text,
  company_address text,
  updated_at timestamptz not null default now()
);
create table if not exists public.teaching_events (
  id uuid primary key default gen_random_uuid(),
  instructor_id uuid not null references public.staff_accounts(user_id) on delete restrict,
  institution text not null,
  course_title text not null,
  taught_on date not null,
  duration_minutes integer not null check(duration_minutes>0 and duration_minutes<=1440),
  event_scope text not null default 'team' check(event_scope in ('team','external')),
  approval_status text not null default 'private' check(approval_status in ('private','submitted','published')),
  created_at timestamptz not null default now()
);
create table if not exists public.education_documents (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.staff_accounts(user_id) on delete restrict,
  kind text not null check (kind in ('plan','quote','resume')),
  title text not null,
  -- content is draft text/JSON only. No identity, account images or seals here.
  draft jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists teaching_events_instructor_date_idx on public.teaching_events(instructor_id,taught_on desc);
create index if not exists education_documents_owner_idx on public.education_documents(owner_id,updated_at desc);

create or replace function public.is_real_admin()
returns boolean language sql stable security definer
set search_path = '' as $$
  select exists (select 1 from public.staff_accounts
    where user_id = (select auth.uid()) and role='admin' and status='active');
$$;
create or replace function public.is_active_instructor(subject uuid)
returns boolean language sql stable security definer
set search_path = '' as $$
  select exists (select 1 from public.staff_accounts
    where user_id = subject and user_id = (select auth.uid()) and status='active');
$$;
revoke all on function public.is_real_admin() from public;
revoke all on function public.is_active_instructor(uuid) from public;
grant execute on function public.is_real_admin() to authenticated;
grant execute on function public.is_active_instructor(uuid) to authenticated;

alter table public.staff_accounts enable row level security;
alter table public.instructor_profiles enable row level security;
alter table public.teaching_events enable row level security;
alter table public.education_documents enable row level security;

-- CRITICAL: account creation, role assignment, status changes are server-admin only.
revoke all on public.staff_accounts from anon,authenticated;
grant select on public.staff_accounts to authenticated;
create policy "accounts: admin or self read" on public.staff_accounts for select to authenticated
using (public.is_real_admin() or user_id=(select auth.uid()));

revoke all on public.instructor_profiles from anon,authenticated;
grant select,insert,update on public.instructor_profiles to authenticated;
create policy "profiles: admin or self read" on public.instructor_profiles for select to authenticated
using (public.is_real_admin() or user_id=(select auth.uid()));
create policy "profiles: admin or active self insert" on public.instructor_profiles for insert to authenticated
with check (public.is_real_admin() or public.is_active_instructor(user_id));
create policy "profiles: admin or active self edit" on public.instructor_profiles for update to authenticated
using (public.is_real_admin() or public.is_active_instructor(user_id))
with check (public.is_real_admin() or public.is_active_instructor(user_id));

revoke all on public.teaching_events from anon,authenticated;
grant select,insert,update on public.teaching_events to authenticated;
create policy "events: admin or self read" on public.teaching_events for select to authenticated
using (public.is_real_admin() or instructor_id=(select auth.uid()));
create policy "events: active self insert" on public.teaching_events for insert to authenticated
with check (public.is_real_admin() or public.is_active_instructor(instructor_id));
-- Instructor may edit private records only. Published/submitted events editable by admin.
create policy "events: limited edit" on public.teaching_events for update to authenticated
using (public.is_real_admin() or (public.is_active_instructor(instructor_id) and approval_status='private'))
with check (public.is_real_admin() or (public.is_active_instructor(instructor_id) and approval_status='private'));

revoke all on public.education_documents from anon,authenticated;
grant select,insert,update on public.education_documents to authenticated;
create policy "documents: admin or self read" on public.education_documents for select to authenticated
using (public.is_real_admin() or owner_id=(select auth.uid()));
create policy "documents: active owner insert" on public.education_documents for insert to authenticated
with check (public.is_real_admin() or public.is_active_instructor(owner_id));
create policy "documents: active owner edit" on public.education_documents for update to authenticated
using (public.is_real_admin() or public.is_active_instructor(owner_id))
with check (public.is_real_admin() or public.is_active_instructor(owner_id));

-- No DELETE grants: retain legitimate operational records until retention workflow.
-- Sensitive attachments/seals must use separate private storage and signed access.
commit;
