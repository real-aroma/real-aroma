# REAL 홈페이지 인수인계 대조 결과 — 2026-10-18
상태: 개발 브랜치에서 확인한 사항과 미검증 사항 구분. 운영 배포 불변.

## 원본
- 2026-10-14 Claude 인수인계: main의 챌린지 앱과 real-brand/ 브랜드 홈페이지의 소스 분리
- 2026-10-18 닷 인수인계: Vercel 프로젝트 real-aroma, 운영 주소 real-aroma.vercel.app, 새 Supabase 프로젝트 생성 화면, 중요 확정 결정

## GitHub 직접 확인
- 저장소: real-aroma/real-aroma
- 브랜치 검색: main, claude/real-brand-portfolio, feature/real-academy-foundation-20261015, claude/challenge-site-fix-1wonan, claude/bold-bell-ut68og
- feature 브랜치에서 backend/004_program_inquiries_DRAFT.sql 존재 확인
- 열려 있는 PR 검색 결과: 0건 (조회 조건 기준; 병합 이력까지 의미하지 않음)

## Vercel·Supabase
- Vercel 연결 브라우저 탭의 사용자 프로젝트 목록 화면 읽기 성공
- 실제 프로젝트별 활성 배포 브랜치·SHA·정상 표시 여부: 미확인
- 실주소: https://real-aroma.vercel.app/ (인수인계서에 기재), 현재 직접 웹 열람 불가로 정상 작동 미검증
- Supabase: 대시보드 생성 URL만 확인, 새 프로젝트 생성 여부는 검증되지 않음. 이전 챌린지 프로젝트 사용 금지

## 운영 정책 (사용자 확정)
- 유일한 대표 최고관리자 1인, 로그인 이메일 gidal99@naver.com
- 강사 본인 신청 후 대표 승인 및 강사코드 발급
- 교육 안내는 대표 승인 후 공개
- 공식 연결 목표 real.aroma1004.com, 실배포/DNS 상태 미확인
- 기존 티스토리와 shop.aroma1004.com, 챌린지 앱 유지
- 신분증/통장/전자직인 원본은 보안 저장 환경 구축 전 수집 금지

## 상태 표
- 기존 정적 홈페이지: 코드 있음 / 실배포 내용 확인 필요
- 강사 등록·승인: UI 시제품 + SQL 초안 / 실제 인증 미구현
- 교육계획서·견적서: 브라우저 편집·인쇄 시제품 / 서버 저장 미구현
- 교육 공개/기관 신청: 기존 정적 페이지와 이메일 문의 시제품 / 실제 접수 DB 미구현
- 출강 완료→이력: SQL 초안 / 운영 DB 미적용
- 대표 MY OFFICE/레시피/SNS: 기획·일부 화면 시제품 / 실서비스 미구현
- 챌린지 앱: 과거 인수인계 상 별도 운영 / 현재 운영 상태 재검증 필요

## 다음 순서
1. Vercel real-aroma 프로젝트 Settings Git/Build 및 Deployments에서 production source SHA, root directory 확인.
2. 새 Supabase 프로젝트 실제 존재 확인. 없으면 사용자 계정에서 안전하게 생성; 인증/환경변수 별도.
3. 001~004 SQL은 초안이므로 보안 검토 및 테스트 DB에서 마이그레이션 검증(직접 운영 반영 금지).
4. 대표 고유 관리자 1인 인증·MFA, 강사 신청·심사·코드 발급 서버 트랜잭션.
5. 교육 승인 공개, 출강 이력 누적, 문서 생성·저장, 기관 신청 실제 접수 순차 구현.
6. 별도 미리보기 배포 테스트 → 대표 검토 → 운영 배포·DNS·검색 등록.

## 작업 규칙
- 사용자 재확인 없이 main에 병합하거나 운영 배포, DNS 변경, 실제 이메일 발송, 유료 리소스 생성 금지.
- 개발 브랜치 문서/시제품 작업은 계속 가능.
- 작업의 실제 완료 상태만 보고한다.
