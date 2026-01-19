COMPOSE_FILE=./srcs/docker-compose.yml
DATA_DIR=/home/pgrellie/data
CERTS_DIR=./srcs/secrets/certs
SECRETS_DIR=./srcs/secrets

all: up

up: build
	docker compose -f $(COMPOSE_FILE) up -d

certs:
	@mkdir -p $(CERTS_DIR)
	@mkdir -p $(SECRETS_DIR)/conf
	@if [ ! -f $(CERTS_DIR)/privkey.pem ] || [ ! -f $(CERTS_DIR)/fullchain.pem ]; then \
		echo "Generating SSL certificates..."; \
		openssl req -x509 -newkey rsa:4096 -keyout $(CERTS_DIR)/privkey.pem \
			-out $(CERTS_DIR)/fullchain.pem -days 365 -nodes \
			-subj "/CN=pgrellie.42.fr/O=42/C=FR"; \
		echo "✓ SSL certificates generated"; \
	else \
		echo "✓ SSL certificates already exist"; \
	fi

build: certs
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build --pull=false

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