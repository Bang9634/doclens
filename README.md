# DocLens

**AI 기반 공고 조건 분석 및 제출 서류 사전 검증 시스템**

DocLens는 조건이 있는 공고에 서류를 제출할 때, 공고의 요구사항과 제출 예정 자료를 비교하여 조건 불일치·누락 사항·위반 가능성을 사전에 확인하도록 돕는 학부 캡스톤디자인 프로젝트입니다.

연구실 모집, 채용 등 다양한 공고를 대상으로 하며, 공고별 제출 조건과 예외를 기준으로 자료를 검토하는 것을 목표로 합니다.

## 주요 기능 목표

- 공고의 지원·신청 조건, 제출 규정, 적용 대상과 예외 추출 및 사용자 확인
- 제출 예정 서류의 구성·분량·파일 형식·기한 등 명시적 조건 검사
- 필요한 사용자 정보와 제출 자료의 교차 검증
- 공고 원문 근거와 문제 위치, 추가 확인이 필요한 항목 제공
- 자료 수정 후 재검사 및 이전 결과 비교

## 현재 진행 단계

백엔드·프론트엔드를 함께 관리하는 모노레포입니다. Java 17·Maven·Spring Boot 3.5 기반의 서버 실행 환경과 상태 확인 API, React·TypeScript·Vite·ESLint 프론트엔드 및 Docker 개발·배포 구성을 추가했습니다. 공고 분석과 서류 검증 기능은 아직 구현하지 않았습니다.

```text
doclens/
├── backend/           # Spring Boot API, Maven, Dockerfile
├── frontend/          # React, Vite, Nginx, Dockerfile
├── Makefile           # 통합 실행·종료·로그 명령
├── compose.yaml       # 배포용: 빌드 산출물 실행
├── compose.dev.yaml   # 개발용: 소스 연결
└── docs/docker.md     # 실행 및 배포 안내
```

## Docker로 실행

루트에서 다음 명령 하나로 백엔드와 프론트엔드를 함께 빌드·실행하고 정상 상태까지 기다립니다. Docker와 Make가 필요합니다.

```bash
make dev
```

종료는 `make down`, 통합 로그는 `make logs`, 서비스 상태는 `make status`로 확인합니다. Java 코드를 수정한 뒤에는 `make backend-restart`를 실행합니다. React 수정은 자동 반영됩니다.

화면은 `http://localhost:5173`, API 연결 확인은 `http://localhost:5173/api/health`입니다.

배포 구성:

```bash
make prod
```

배포 구성 종료는 `make prod-down`입니다. 화면과 API는 `http://localhost:8080`으로 접근합니다. 개발 환경과 동시에 실행할 때는 배포 포트를 변경해야 합니다. 준비 사항, 재시작, 로그, 종료 및 서버 배포 시 고려 사항은 [Docker 실행 안내](docs/docker.md)를 참고하세요.

## 검증 범위

등록된 자료와 검사 가능한 조건을 기준으로 결과를 제공합니다. 문제를 발견하지 못했다는 사실이 모든 조건 충족이나 선정·합격을 보장하지 않습니다. 검사한 항목과 검사하지 못한 항목, 정보 부족을 구분해 안내하는 것을 원칙으로 합니다.
