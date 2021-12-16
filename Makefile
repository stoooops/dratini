CERT_DIR=certs
DOCKER_IMAGE=$(notdir $(CURDIR))
DOCKERFILE_BASE=docker/Dockerfile
DOCKER_COMPOSE_DEV=docker/docker-compose.yaml
DOCKER_COMPOSE_PROD=docker/docker-compose.production.yaml

all: build

#
# Host OS NPM setup
#
uninstall:
	rm -rf node_modules/*

install: clean uninstall
	npm install

#
# Lint on host OS
#
lint:
	npm run pretty
	npm run lint

#
# Build
#
clean:
	rm -rf dist/*

build_dev:
	docker-compose -p $(DOCKER_IMAGE) -f $(DOCKER_COMPOSE_DEV) build

build_prod:
	docker build -f $(DOCKERFILE_BASE) -t $(DOCKER_IMAGE) .
	docker-compose -p $(DOCKER_IMAGE) -f $(DOCKER_COMPOSE_PROD) build

build: build_dev build_prod

#
# Dev
#
dev: build_dev
	docker-compose -f $(DOCKER_COMPOSE_DEV) up --force-recreate --remove-orphans

#
# Prod
#
prod: stop_prod build_prod
	docker-compose -f $(DOCKER_COMPOSE_PROD) up --force-recreate --remove-orphans -d
	docker-compose -f $(DOCKER_COMPOSE_PROD) logs --tail="all" -f

stop_prod:
	docker stop $(DOCKER_IMAGE)_prod 2>/dev/null || true

#
# Cleanup / debugging
#
nuke_docker:
	docker image rm -f $(DOCKER_IMAGE)_dev 2>/dev/null
	docker image rm -f $(DOCKER_IMAGE)_prod 2>/dev/null
	docker image rm -f $(DOCKER_IMAGE) 2>/dev/null
	docker system prune -f

#
# Certificates
#
cert:
	certs/generate.sh
