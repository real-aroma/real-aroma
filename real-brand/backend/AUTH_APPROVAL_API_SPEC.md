# REAL OFFICE 인증 및 승인 서비스 구현 계약 (v1)
작성일: 2026-10-15
상태: 서비스 API 인터페이스 명세 / 구현·배포 전

## 고정 설정
- 최초 최고관리자 계정: gidal99@naver.com
- 이메일은 화면 표시·초대용. 권한 판단은 검증된 auth.uid() + singleton 관리자 가드.
- 대표 1명만 전체 관리자 권한.
- 강사 본인 회원가입 신청 → pending → 대표 승인 또는 반려.
- 공개 교육안내는 초안 → 제출 → 대표 승인 → 승인된 고정 버전만 공개.
- 새로운 Supabase 프로젝트 필수. 기존 뉴로터치 챌린지 인프라 변경 금지.

## 인증 프런트엔드
1. 강사 '신청'은 이메일 인증 이후에만 가능.
2. 미승인 신청자는 대기 상태 조회만 가능하고 관리자·강사 자료 접근 불가.
3. 승인되면 발급된 고유 staff_code 및 instructor 프로필로 전환.
4. 대표는 MFA 로그인 후만 관리자 진입 가능, API에서도 재검증.
5. 탈퇴 강사: 세션 토큰 만료 전이라도 모든 보호 API가 status 확인 후 즉시 차단.

## 서버 API (권장 경로; 구현 후 변경 가능)
POST /api/instructor/apply
- authenticated 신청자만
- 본인 신청은 1건만, 필수 문자열 길이 검사, 민감서류 첨부 금지
- response: {id,status:'pending'}
GET /api/instructor/application
- 본인 신청 상태만 반환
GET /api/admin/applications
- 유일 최고관리자만 조회, 개인정보 최소화
POST /api/admin/applications/:id/decision
- 유일 최고관리자 + MFA 요구
- body: {decision:'approve'|'reject',reviewNote?:string}
- 승인 거래(transaction): 중복 처리 방지, 고유코드 비재사용 발급, staff_accounts 생성, 승인 상태 변경, 감사 로그 저장
- 결과는 비밀 없이 승인 여부·고유코드만 반환
POST /api/programs/:id/submit
- 소유 강사: 현재 초안의 변경 불가 revision 제출
POST /api/admin/programs/:id/decision
- 관리자: revision 단위 승인/반려
- 공개 웹사이트 API는 승인된 revision만 조회
- 승인 후 초안 수정 시 기존 공개 버전을 덮어쓰지 않고 새로운 revision을 별도 생성

## 필수 보안
- 브라우저에서 service_role 키 사용 금지
- 이메일 문자열 동등성만으로 admin 판단 금지
- 관리자 역할 및 상태는 서버 전용 트랜잭션
- 가입 승인 및 강사코드 발급은 동시에 처리/실패 시 롤백
- rate limit, CSRF/세션 보호, 감사로그, 접근기록, 비정상 로그인 차단
- 신청 단계에서 주민번호·통장사본·사업자번호 제출받지 않음
- 실제 메일 발송은 등록된 수신자 검토 후 사용자 명시적 클릭

## 통합 테스트 기준
1. 무로그인 신청 API → 401
2. 강사 A 신청 정보를 강사 B가 요청 → 403/404
3. 대기 강사가 관리자 호출 → 403
4. 대기 강사가 강사 페이지 직접 주소 접근 → 서버 데이터 접근 403
5. 한 신청을 두 번 승인 시 강사코드 중복 발급 금지
6. 강사 A 문서를 강사 B가 조회/수정 → 403
7. 강사 본인이 스스로 admin 역할 지정 시도 → 403
8. 대표 승인 전 교육 프로그램 → 외부 공개 목록 미포함
9. 승인된 revision은 추후 편집해도 이전 공개본 유지
10. 소속 해제 계정의 기존 세션 API 요청 → 403
11. 챌린지 앱 DB·배포 상태 변화 없음
12. 관리자 MFA 누락 시 민감 승인 API → 거부

## 미연결 의존성
- 전용 Supabase Auth/Database 실제 프로젝트
- Vercel 서버리스 런타임/환경변수 및 백엔드 배포
- 개인정보 처리방침과 강사 이용약관
