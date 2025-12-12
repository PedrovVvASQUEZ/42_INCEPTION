COMPOSE_FILE=./srcs/docker-compose.yml

build:
	docker compose -f $(COMPOSE_FILE) build --pull=false

up: build
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down
	sudo rm -rf $(shell grep device -n srcs/docker-compose.yml | awk -F":" '{print $$1}') || true

.PHONY: build up down logs clean