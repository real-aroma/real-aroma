# REAL EDU OFFICE — 출강 이력 자동 반영 설계
작성일: 2026-10-15
상태: 구현 명세 / 운영 DB 미적용

## 핵심 업무 흐름
1. 강사가 교육 프로그램 선택 또는 직접 작성.
2. 기관 출강 요청이 확정되면 teaching_event에 일정·기관·교육제목·시간·담당자를 등록.
3. 수업 이후 '출강 완료'를 선택하면 완료일·실제 시간 등을 기록한다.
4. **완료된 출강**만 강사 이력서와 강사카드의 경력 조회 결과에 자동 포함한다. 교육 신청/예정만으로 실적을 주장하지 않는다.
5. 외부 공개 후기와 사진은 별도 승인·초상권 검토를 거친 뒤 표시한다.
6. 강사코드를 비활성화해도 적법하게 보존할 업무 기록과 출강 통계는 유지한다.

## teaching_events 확장 마이그레이션 (별도 프로젝트에서 검토 후 적용)
- status: planned / completed / cancelled
- completed_at: 완료 확인 시각
- instructor_id, institution, course_title, taught_on, duration_minutes 기존 열 활용
- event_scope: team / external
- evidence_status: self_reported / verified
- 공개용 published 승인과 실적 인정은 별개.
- 중복 방지: 같은 수업에 대한 외부기관 의뢰번호/고유 event_id 보존; 날짜·강사·기관이 같아도 별개의 수업일 수 있으므로 단순 UNIQUE 금지.

## 자동 이력서 뷰
교사별 이력서는 완료 상태 출강을 날짜순으로 조회:
SELECT institution, course_title, taught_on, duration_minutes, event_scope
FROM teaching_events
WHERE instructor_id = :authenticated_teacher_id
  AND status = 'completed'
ORDER BY taught_on DESC;

실제 API는 브라우저가 전달한 instructor_id를 신뢰하지 않고 auth.uid() 또는 관리자의 권한을 서버에서 검증한다.
반영된 데이터는 이력서 PDF 생성 시점에 고정하여 해당 시점의 제출본을 재현 가능하도록 한다.

## 보존과 비공개
- 강사 본인: 자기 출강 등록 및 확인
- 대표: 모든 강사의 업무·실적 조회
- 외부: 공개 승인을 받은 교육후기·강사 소개만 표시
- 소속 해제: 로그인 차단, 업무 기록은 업무 목적/보유기간에 따라 아카이브
- 민감 증빙·직인·신분증은 실적 테이블과 분리

## 후속 구현 점검
- 새 전용 Supabase 프로젝트 개설 후 마이그레이션
- 실제 인증 연결, 관리자 역할 초기 수동 부여, RLS 이중 계정 테스트
- 출강 완료 버튼과 등록/취소 정책
- 이력서 PDF 출력 템플릿 및 기관 제출본 버전 관리
- 강사 탈퇴·정보 정정·기록 보존 관리
