COMPOSE_FILE=./srcs/docker-compose.yml
DATA_DIR=/home/pgrellie/data

all: up


build:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build --pull=false

up: build
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

re: down up

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

clean: down
    docker compose -f $(COMPOSE_FILE) down -v --remove-orphans
	sudo rm -rf $(DATA_DIR)/mariadb/*
	sudo rm -rf $(DATA_DIR)/wordpress/*

fclean: clean
    docker compose -f $(COMPOSE_FILE) down --rmi all

.PHONY: all build up down re logs clean