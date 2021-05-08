RESOURCES_PATH := ./resources
DOCKER_PATH := ${RESOURCES_PATH}/docker
DOCKER_COMPOSE_FILE := -f ${DOCKER_PATH}/docker-compose.yaml
MONGO_PATH := ${DOCKER_PATH}/mongo

up: down
	docker-compose ${DOCKER_COMPOSE_FILE} up

up/rebuild: down reset
	docker-compose ${DOCKER_COMPOSE_FILE} up --build

down:
	docker-compose ${DOCKER_COMPOSE_FILE} down --remove-orphans

logs:
	docker-compose ${DOCKER_COMPOSE_FILE} logs -f

exec/mongo:
	docker exec -it rumour_spreading_mongo bash

reset: down cleanup/persistence
	
cleanup/persistence:
	sudo rm -rf ${MONGO_PATH}/data/
