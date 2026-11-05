# Docker 개발 및 배포

## 준비 사항

Docker Engine 또는 Docker Desktop과 Docker Compose v2 이상을 준비한다. 아래 명령은 모두 저장소 루트에서 실행한다. 호스트에 Java·Maven·Node.js를 설치할 필요는 없다. 최초 실행에는 이미지·의존성 다운로드를 위한 인터넷 연결이 필요하다.

## 통합 실행 명령

Make가 설치되어 있으면 루트의 `Makefile`로 두 서비스를 한 번에 관리한다. Make가 없는 환경에서는 아래 Docker Compose 명령을 직접 사용한다.

```bash
make dev              # 두 서비스 빌드·실행, 정상 상태까지 대기
make status           # 두 서비스 상태
make logs             # 두 서비스 로그 함께 보기 (Ctrl+C는 로그 보기만 종료)
make backend-restart  # Java 변경 반영 후 서비스 준비 상태 대기
make down             # 개발 서비스 전체 종료, 캐시 보존
```

배포 구성은 `make prod`, 종료는 `make prod-down`, 로그는 `make prod-logs`, 상태는 `make prod-status`를 사용한다. 배포 포트 변경은 `HTTP_PORT=8090 make prod`로 지정할 수 있다. `make` 또는 `make help`로 명령 목록을 확인한다.

명령 하나가 백엔드와 프론트엔드 컨테이너를 함께 관리한다. 실행 명령을 통합하되 빌드·실행 단위는 기존처럼 분리한다. 개발용과 배포용은 목적과 포트가 다르므로 선택해서 실행한다.

## 개발 환경

```bash
docker compose -f compose.dev.yaml up --build -d --wait --wait-timeout 600
```

- 화면: http://localhost:5173
- 프론트엔드 경유 API: http://localhost:5173/api/health
- 백엔드 직접 확인: http://localhost:8080/api/health

API 응답 예시:

```json
{"status":"UP","service":"doclens-backend"}
```

React 소스 변경은 Vite HMR로 반영된다. Java 소스·POM 변경은 다음 명령으로 백엔드를 재시작하면 Maven이 다시 컴파일한다. Java 자동 재컴파일·자동 재시작은 아직 구성하지 않았다.

```bash
docker compose -f compose.dev.yaml restart backend
```

프론트엔드 의존성을 변경한 뒤에는 컨테이너를 재시작한다. 시작 시 `npm ci`를 실행하므로 `package.json`과 `package-lock.json`을 함께 갱신해야 한다.

```bash
docker compose -f compose.dev.yaml restart frontend
```

호스트의 `node_modules`·`target`과 Linux 컨테이너 결과물이 충돌하지 않도록 Docker 볼륨으로 분리했다. 개발 포트는 로컬 컴퓨터에서만 접근할 수 있게 바인딩했다.

```bash
docker compose -f compose.dev.yaml logs -f
docker compose -f compose.dev.yaml down
```

`down`은 의존성 캐시 볼륨을 보존한다. `down -v`는 볼륨까지 삭제하므로 초기화할 때만 사용한다.

## 서버 배포 구성

```bash
docker compose up --build -d --wait --wait-timeout 600
```

- 화면: http://localhost:8080 (서버에서는 해당 서버 주소)
- 프록시 연결 확인: http://localhost:8080/api/health
- 브라우저 → Nginx → `/api/*` → Spring Boot
- 백엔드 포트는 Docker 내부 네트워크에만 노출한다.
- React는 빌드된 정적 파일을 Nginx로 제공한다. Vite 개발 서버를 배포에 사용하지 않는다.
- 소스 바인드 마운트 없이 이미지에 포함한 산출물을 실행한다.
- Maven 테스트와 프론트엔드 lint·빌드는 이미지 빌드 과정에서 실행한다.

포트는 `.env.example`을 `.env`로 복사하여 변경하거나 실행 시 지정할 수 있다.

```bash
HTTP_PORT=8090 docker compose up --build -d --wait --wait-timeout 600
docker compose ps
docker compose logs -f
docker compose down
```

개발과 기본 배포 설정은 모두 호스트 8080 포트를 사용하므로 동시에 실행하려면 배포 포트를 8090 등으로 바꾼다. 두 Compose 파일은 각각 독립된 전체 설정이다. `-f compose.yaml -f compose.dev.yaml`처럼 합쳐 사용하지 않는다.

이미지는 실행 서버의 CPU 아키텍처에 맞게 빌드한다. 서버에서 직접 빌드하거나 대상 플랫폼을 지정해 빌드한 이미지를 사용한다.

현재 설정은 HTTP 배포 기반이다. 외부 공개 시 HTTPS·도메인·인증·개인정보 처리는 배포 환경과 서비스 요구사항에 맞춰 구성한다.

## 호스트에서 직접 실행하는 경우

```bash
# 터미널 1: backend 디렉토리
mvn spring-boot:run

# 터미널 2: frontend 디렉토리
npm ci
npm run dev
```

프론트엔드 API 요청은 항상 `/api/...` 상대 경로를 사용한다. Docker 개발 환경에서는 Vite가 `backend:8080`으로, 호스트 실행에서는 `127.0.0.1:8080`으로 전달한다. 배포에서는 Nginx가 전달하므로 브라우저가 Docker 내부 호스트명을 알아야 할 필요가 없다.

## 현재 구현 범위

백엔드는 Spring Boot 실행 기반과 `/api/health`만 제공한다. 프론트엔드는 기존 React 기본 화면이다. 공고 등록·조건 추출·서류 검사 기능은 아직 구현하지 않았다. DB와 외부 AI API도 연결하지 않았다. 이미지 레지스트리와 CI/CD 연동은 구성에 포함하지 않는다.

## 참고 자료

- [Docker Compose 시작 순서와 상태 확인](https://docs.docker.com/compose/how-tos/startup-order/)
- [Spring Boot 3.5 실행 요구사항](https://docs.spring.io/spring-boot/3.5/system-requirements.html)
- [Node.js 릴리스](https://nodejs.org/en/about/previous-releases)
