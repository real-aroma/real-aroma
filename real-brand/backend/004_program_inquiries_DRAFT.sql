-- Draft migration 004: public program catalog and institution inquiry intake
-- DO NOT run on the operational neurotouch challenge database.
begin;
create table if not exists public.education_programs (
 id uuid primary key default gen_random_uuid(),
 author_id uuid not null references public.staff_accounts(user_id),
 title text not null check(length(title) between 2 and 160),
 category text not null,
 audience text not null default '',
 summary text not null default '',
 duration_minutes integer check(duration_minutes between 15 and 1440),
 status text not null default 'draft' check(status in ('draft','submitted','approved','archived')),
 approved_by uuid references public.staff_accounts(user_id),
 approved_at timestamptz,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.institution_inquiries (
 id uuid primary key default gen_random_uuid(),
 program_id uuid references public.education_programs(id) on delete set null,
 institution_name text not null,
 contact_name text not null,
 contact_email text not null,
 phone text,
 target_audience text,
 participant_count integer check(participant_count between 1 and 100000),
 requested_date date,
 location_note text,
 message text,
 consent_version text not null,
 consented_at timestamptz not null default now(),
 status text not null default 'new' check(status in ('new','reviewing','quoted','confirmed','closed')),
 created_at timestamptz not null default now()
);
create index if not exists institution_inquiries_status_idx on public.institution_inquiries(status,created_at desc);
alter table public.education_programs enable row level security;
alter table public.institution_inquiries enable row level security;
revoke all on public.education_programs, public.institution_inquiries from anon,authenticated;
grant select,insert on public.education_programs to authenticated;
create policy "own or admin program drafts" on public.education_programs for select to authenticated
using (public.is_real_admin() or author_id=(select auth.uid()));
create policy "active instructor inserts draft only" on public.education_programs for insert to authenticated
with check (public.is_active_instructor(author_id) and status='draft' and approved_by is null and approved_at is null);
-- No browser UPDATE on status; server validates revisions and owner approval.
-- Anonymous institution inquiries only through dedicated rate-limited server endpoint
-- with consent, spam controls, validation and protected storage. No anon table grants.
-- Published program content should be served by reviewed immutable snapshots,
-- not by opening RLS access to private drafts.
commit;
