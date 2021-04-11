DOCKER_PATH := resources/docker
DOCKER_COMPOSE_FILE := -f ${DOCKER_PATH}/docker-compose.yaml

up: down
	docker-compose ${DOCKER_COMPOSE_FILE} up 
	
up/db: down
	docker-compose ${DOCKER_COMPOSE_FILE} up rumour_spreading_mongo

down:
	docker-compose ${DOCKER_COMPOSE_FILE} down --remove-orphans

logs:
	docker-compose ${DOCKER_COMPOSE_FILE} logs -f

exec/mongo:
	docker exec -it rumour_spreading_mongo bash

reset: down cleanup/persistence
	
cleanup/persistence:
	sudo rm -rf ./${DOCKER_PATH}/mongo/data/