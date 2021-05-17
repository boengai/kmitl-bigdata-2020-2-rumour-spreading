include .env

RESOURCES_PATH := ./resources
DOCKER_PATH := ${RESOURCES_PATH}/docker
DOCKER_COMPOSE_FILE := -f ${DOCKER_PATH}/docker-compose.yaml --env-file ./.env
MONGO_PATH := ${DOCKER_PATH}/mongo
MONGO_ATLAS_URI := mongodb+srv://${MONGO_ATLAS_USERNAME}:${MONGO_ATLAS_PASSWORD}@${MONGO_ATLAS_CLUSTER}.mongodb.net
MONGO_DUMP_TEMP := /data/db/dump_tmp

up: down
	docker-compose ${DOCKER_COMPOSE_FILE} up

up/rebuild: down reset
	docker-compose ${DOCKER_COMPOSE_FILE} up --build

down:
	docker-compose ${DOCKER_COMPOSE_FILE} down --remove-orphans

logs:
	docker-compose ${DOCKER_COMPOSE_FILE} logs -f

exec/mongo:
	docker exec -it rumour_spreading_mongo bash  -c "\
		mongo -u ${MONGO_ROOT_USERNAME} -p ${MONGO_ROOT_PASSWORD} -- ${MONGO_DATABASE} \
	"

reset: down cleanup/persistence
	
cleanup/persistence:
	sudo rm -rf ${MONGO_PATH}/data/

restore/mongodbatlas:
	docker exec -it rumour_spreading_mongo bash -c "\
		mongodump -u ${MONGO_ROOT_USERNAME} -p ${MONGO_ROOT_PASSWORD} -d ${MONGO_DATABASE} --out ${MONGO_DUMP_TEMP} && \
		mongorestore --drop --uri ${MONGO_ATLAS_URI} ${MONGO_DUMP_TEMP} && \
		rm -rf ${MONGO_DUMP_TEMP} \
	"