# REAL · 성향미 브랜드 홈페이지 (1차 구현)

이 디렉터리는 저장소 루트의 `index.html`(REAL 뉴로터치 챌린지 앱, `seong-brand-site.vercel.app`에서
서비스 중)과는 **완전히 분리된 별도 정적 사이트**입니다. 이 폴더를 수정해도 기존 챌린지 앱과
그 배포에는 아무 영향이 없습니다.

## 구성

순수 정적 HTML/CSS (프레임워크·빌드 도구 없음, 기존 저장소의 구성 방식과 동일):

```
real-brand/
├── index.html         메인
├── about.html          ABOUT (경력·교육 철학)
├── portfolio.html      기관용 포트폴리오 (인쇄/PDF 지원)
├── programs.html       교육 프로그램 · REAL ACADEMY
├── team.html           REAL 강사진 · REAL PEOPLE
├── publications.html   저서·강연
├── contact.html        출강 문의 (mailto 기반)
├── assets/style.css    공통 스타일(아이보리·세이지그린 팔레트)
├── vercel.json         이 폴더 전용 Vercel 설정
├── robots.txt / sitemap.xml
└── README.md           (이 파일)
```

## 로컬에서 확인하는 방법

```bash
cd real-brand
python3 -m http.server 8000
# 브라우저에서 http://localhost:8000 접속
```

## 배포 방법 (실제 배포는 사용자 승인 후 진행)

이 폴더는 기존 Vercel 프로젝트(`real-8touch-challenge`, 저장소 루트 기준)와는 **별개의 새
Vercel 프로젝트**로 배포하는 것을 전제로 설계했습니다.

1. Vercel 대시보드에서 **새 프로젝트**를 만들고, 같은 GitHub 저장소(`real-aroma/real-aroma`)를 연결합니다.
2. 프로젝트 설정의 **Root Directory**를 `real-brand`로 지정합니다.
   (이렇게 하면 이 프로젝트는 `real-brand/vercel.json`만 읽고, 저장소 루트의 `index.html`/`vercel.json`과는
   완전히 분리되어 동작합니다. 기존 챌린지 앱 프로젝트는 그대로 둡니다.)
3. 배포가 성공하면 Vercel이 자동 발급하는 `*.vercel.app` 주소로 먼저 확인합니다.
4. 확인 후, Vercel 프로젝트의 **Domains** 설정에서 `real.aroma1004.com`을 추가합니다.
   - `aroma1004.com`의 DNS(네임서버 또는 레코드 관리 화면)에서 `real` 서브도메인에 대한
     CNAME 레코드를 Vercel이 안내하는 값으로 추가해야 합니다.
   - **주의**: 이 작업은 기존 `aroma1004.com` 블로그나 `shop.aroma1004.com` 레코드를 건드리지
     않고, `real` 서브도메인만 새로 추가하는 것입니다. 기존 DNS 레코드를 삭제·수정하지 마세요.

## 이번 1차 구현에서 의도적으로 비워둔 것 (사실 미확인 항목)

인수인계 문서(`REAL_Claude_...md`)의 지시에 따라, 아래 항목은 **사실이 확인되지 않아 추측하지
않고 "확인 필요/준비 중"으로 남겨두었습니다.**

- `contact.html`의 이메일 주소(`contact@aroma1004.com`)는 예시입니다. 실제 문의받을 이메일로
  반드시 교체해 주세요 (파일 내 3곳의 `mailto:` 링크 + 화면에 보이는 텍스트 1곳).
- 연락처(전화번호) — 입력 필요.
- 출강 사례(기관명·날짜·사진) — 기관·대표자 동의가 확인된 사례만 추가하도록 비워두었습니다.
- 저서 출간 여부/제목/ISBN — 출간 확정 전까지 "집필 준비 중"으로만 표기했습니다.
- 강연 이력 — 동의된 사례 확인 후 추가.
- REAL 강사진 — 본인(성향미) 카드만 채웠고, 나머지는 "프로필 추가 예정" 자리로 비워두었습니다.
- 현장 사진 — 실제 AI 이미지를 생성하지 않았습니다. 대신 점선 테두리의 "사진 영역" 플레이스홀더를
  넣어두었으니, 실제 강의·교육 현장 사진으로 교체해 주세요 (`index.html`, `about.html` 내
  `.photo-frame` 블록 2곳).
- 교통사고·투병의 구체적 서사와 doTERRA 다이아몬드 달성 시점 등은, 민감 정보·수입 암시 리스크
  때문에 이번 1차 공개 페이지에는 넣지 않았습니다. 포함 여부와 표현 수위는 별도로 검토가
  필요합니다.

## doTERRA 관계 고지

`about.html` 하단에 doTERRA 사업자 관계를 투명하게 밝히는 안내 문구를 한 곳에 배치했습니다.
교육 활동과 제품 사업을 구분하고, 기관이 doTERRA를 공식 후원한다는 인상을 주지 않도록
작성했습니다. 문구 수위는 실제 사업 운영 방침에 맞춰 조정이 필요할 수 있습니다.
