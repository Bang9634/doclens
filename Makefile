.DEFAULT_GOAL := help

DEV_COMPOSE := docker compose -f compose.dev.yaml
PROD_COMPOSE := docker compose -f compose.yaml

.PHONY: help dev down logs status backend-restart prod prod-down prod-logs prod-status config

help:
	@printf '%s\n' 'make dev              개발 환경 전체 실행 (빌드·상태 확인 포함)' 'make down             개발 환경 전체 종료 (캐시 보존)' 'make logs             개발 환경 통합 로그' 'make status           개발 서비스 상태' 'make backend-restart  Java 변경 후 백엔드 재시작' 'make prod             배포 구성 전체 실행' 'make prod-down        배포 구성 전체 종료' 'make prod-logs        배포 구성 통합 로그' 'make prod-status      배포 서비스 상태' 'make config           개발·배포 설정 검증'

dev:
	$(DEV_COMPOSE) up --build -d --wait --wait-timeout 600
	@printf '%s\n' 'DocLens 개발 환경 준비 완료' '화면: http://localhost:5173' 'API 확인: http://localhost:5173/api/health'

down:
	$(DEV_COMPOSE) down

logs:
	$(DEV_COMPOSE) logs -f

status:
	$(DEV_COMPOSE) ps

backend-restart:
	$(DEV_COMPOSE) restart backend
	$(DEV_COMPOSE) up -d --wait --wait-timeout 600

prod:
	$(PROD_COMPOSE) up --build -d --wait --wait-timeout 600
	@printf '%s\n' 'DocLens 배포 구성 준비 완료 (기본 포트 8080, 변경 시 HTTP_PORT 확인)'

prod-down:
	$(PROD_COMPOSE) down

prod-logs:
	$(PROD_COMPOSE) logs -f

prod-status:
	$(PROD_COMPOSE) ps

config:
	$(DEV_COMPOSE) config --quiet
	$(PROD_COMPOSE) config --quiet
