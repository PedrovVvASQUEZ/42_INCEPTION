COMPOSE_FILE=./srcs/docker-compose.yml
DATA_DIR=/home/pgrellie/data

build:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build --pull=false

up: build
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down
	sudo rm -rf $(DATA_DIR)/mariadb/*
	sudo rm -rf $(DATA_DIR)/wordpress/*

.PHONY: build up down logs clean