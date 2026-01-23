COMPOSE_FILE=./srcs/docker-compose.yml
ENV_FILE=./srcs/.env
#DATA_DIR=/home/pgrellie/data
CERTS_DIR=./secrets/certs

all: up

up: build
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d

certs:
	@mkdir -p $(CERTS_DIR)
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
# 	mkdir -p $(DATA_DIR)/mariadb
# 	mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) build --pull=false

down:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down

re: down up

logs:
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) logs -f

clean: down
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down -v
# 	sudo rm -rf $(DATA_DIR)/mariadb/*
# 	sudo rm -rf $(DATA_DIR)/wordpress/*

fclean: clean
	docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) down --rmi all
	rm -rf $(CERTS_DIR)

.PHONY: all build up down re logs clean fclean certs



#certs generation explanation
#-x509 : Crée un certificat auto-signé
#-newkey rsa:4096 : Génère une clé RSA de 4096 bits
#-keyout : Fichier de la clé privée
#-out : Fichier du certificat
#-days 365 : Valide 1 an
#-nodes : Pas de chiffrement de la clé privée
#-subj : Informations du certificat (domaine, organisation, pays)