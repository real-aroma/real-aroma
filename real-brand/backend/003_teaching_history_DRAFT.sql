-- REAL EDU OFFICE / 003: 출강 완료 및 이력서 연동 — 검토용, 실행하지 않음
-- 전제: 새 전용 Supabase 프로젝트에 001, 002가 적용되어야 함.
-- 챌린지 운영 DB에는 적용 금지.
begin;

alter table public.teaching_events
  add column if not exists lifecycle_status text not null default 'planned'
  check (lifecycle_status in ('planned','completed','cancelled'));
alter table public.teaching_events
  add column if not exists completed_at timestamptz;
alter table public.teaching_events
  add column if not exists evidence_status text not null default 'self_reported'
  check (evidence_status in ('self_reported','verified'));

-- 일관성 유지: 완료 이력에는 완료 시각이 필요하며,
-- 최초 출강 등록은 예정 상태로 들어간다.
alter table public.teaching_events
  add constraint teaching_events_completion_consistency
  check ((lifecycle_status='completed' and completed_at is not null)
      or (lifecycle_status<>'completed' and completed_at is null));

-- RLS 정책의 UPDATE는 컬럼 변경을 제한하지 못한다.
-- 강사의 직접 UPDATE 통로를 잠가 변경을 검증된 서버 API로 집중한다.
drop policy if exists "events: limited edit" on public.teaching_events;
revoke update on public.teaching_events from authenticated;

-- 제출용 이력의 기준이 되는 완료 기록만 제공.
-- security_invoker=true: 조회자에게 원본 테이블의 RLS가 적용됨.
create or replace view public.completed_teaching_history
with (security_invoker=true) as
select id, instructor_id, institution, course_title, taught_on,
       duration_minutes, event_scope, evidence_status, completed_at
from public.teaching_events
where lifecycle_status = 'completed';
revoke all on public.completed_teaching_history from anon,authenticated;
grant select on public.completed_teaching_history to authenticated;

create index if not exists completed_teaching_history_idx
  on public.teaching_events(instructor_id,taught_on desc)
  where lifecycle_status='completed';

-- 운영 서버 역할(Service Role)은 외부 브라우저에 노출하지 말 것.
-- 계획 -> 완료 전환, 취소, 수정, 검증 여부 변경은 인증된 서버 API에서:
-- 1) 본인 여부 또는 sole-admin 검증
-- 2) 기존 상태 검증, 중복 요청 방지
-- 3) 원자적 갱신 + 감사 로그
-- 4) 외부 공개 별도 승인
commit;
