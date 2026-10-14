-- REAL AROMA membership & publication review — DRAFT, NOT DEPLOYED
-- Intended for a NEW dedicated Supabase project, separate from the production challenge app.
-- Depends on 001_staff_access_DRAFT.sql. Security review required before use.
begin;
create table public.platform_admin_guard (
  singleton boolean primary key default true check(singleton),
  admin_user_id uuid not null unique references auth.users(id) on delete restrict,
  appointed_at timestamptz not null default now()
);
-- Bootstrap strictly from a privileged server/session; never expose write privileges.
revoke all on public.platform_admin_guard from anon,authenticated;
alter table public.platform_admin_guard enable row level security;
-- No authenticated user SELECT access; server-side only.

-- Tighten the original staff policy helper to recognize only the designated sole admin.
create or replace function public.is_real_admin()
returns boolean language sql stable security definer set search_path='' as $$
  select exists (
    select 1 from public.platform_admin_guard g
    join public.staff_accounts s on s.user_id=g.admin_user_id
    where g.admin_user_id=(select auth.uid())
      and s.role='admin' and s.status='active'
  );
$$;
-- Existing RLS uses this helper. Any additional 'admin' role rows do not become admins.
-- Provision bootstrap admin and guard row atomically through privileged migration.

create table public.instructor_applications (
  id uuid primary key default gen_random_uuid(),
  applicant_id uuid not null unique references auth.users(id) on delete restrict,
  display_name text not null,
  email_for_contact text not null,
  specialty_summary text not null default '',
  status text not null default 'pending' check(status in ('pending','approved','rejected')),
  review_note text,
  reviewed_at timestamptz,
  reviewed_by uuid references public.staff_accounts(user_id),
  created_at timestamptz not null default now()
);
create table public.publication_requests (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.staff_accounts(user_id) on delete restrict,
  title text not null,
  body text not null,
  status text not null default 'draft' check(status in ('draft','submitted','approved','rejected')),
  approved_revision text,
  reviewed_by uuid references public.staff_accounts(user_id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.instructor_applications enable row level security;
alter table public.publication_requests enable row level security;
revoke all on public.instructor_applications,public.publication_requests from anon,authenticated;
grant select,insert on public.instructor_applications to authenticated;
grant select,insert on public.publication_requests to authenticated;
create policy "applicant can read own application" on public.instructor_applications for select to authenticated
using (applicant_id=(select auth.uid()) or public.is_real_admin());
create policy "applicant can submit own pending request" on public.instructor_applications for insert to authenticated
with check (applicant_id=(select auth.uid()) and status='pending' and reviewed_at is null and reviewed_by is null and review_note is null);
create policy "author and admin may read drafts" on public.publication_requests for select to authenticated
using (public.is_real_admin() or author_id=(select auth.uid()));
create policy "active instructor creates private draft" on public.publication_requests for insert to authenticated
with check (public.is_active_instructor(author_id) and status='draft' and approved_revision is null and reviewed_by is null and reviewed_at is null);
-- UPDATE privileges intentionally withheld:
-- Submit/approve/reject/revise must be server-mediated transitions with audit logging.
-- Application approval and unique code issuance must be one privileged transaction.
-- Public website must read ONLY approved immutable revisions from a separate publication endpoint.
commit;
