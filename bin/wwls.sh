#!/bin/bash

source /app/ww_service/bin/env.sh

CONTAINERS=("houdini" "clarisse" "foundry" "yeti_pixar")

CMD_LOG_FLAG=0

if [[ $CMD_LOG_FLAG -eq 1 ]];then
        CMD_LOG=">> $LOG_FILE 2>&1"
else
        CMD_LOG="> /dev/null 2>> $LOG_FILE"
fi

start_containers() {
	local SERVICE="$1"

	if [ -z "$SERVICE" ]; then
		log "No specific service specified. Starting all services."
		SERVICE="all"
	fi

	if [[ $SERVICE == "all" ]]; then
		log "Starting all services using Docker Compose."
		CMD="$REZ_DOCKER_COMPOSE up -d $CMD_LOG"
		log "CMD=[$CMD]"
		eval $CMD
	else
		log "Starting service [$SERVICE] using Docker Compose."
		CMD="$REZ_DOCKER_COMPOSE up -d "$SERVICE" $CMD_LOG"
		log "CMD=[$CMD]"
		eval $CMD
	fi
	log "Docker Compose command executed for [$SERVICE]."
}

stop_containers() {
	log "Stopping and removing all containers using Docker Compose."
	$REZ_DOCKER_COMPOSE down $CMD_LOG
	log "All containers stopped and removed."
}

check_container() {
	for container_name in "${CONTAINERS[@]}"; do
		CHK_CMD="$REZ_DOCKER ps --filter name=$container_name |grep $container_name|wc -l"
		CHK_RESULT=`eval "$CHK_CMD"`
		if [ $CHK_RESULT -eq 0 ]; then
			log "$container_name is not running. Attempting to restart"
			start_containers "$container_name"
		else
			log "$container_name is running"
		fi
	done
	return 0
}

check_docker_daemon() {
	if ! $REZ_DOCKER info > /dev/null 2>&1; then
		log "Starting Docker deamon."
		CMD="$REZ_DOCKERD --insecure-registry $DOCKER_SERVER $CMD_LOG &"
		log "CMD=[$CMD]"
		eval $CMD

		while ! $REZ_DOCKER info > /dev/null 2>&1; do
			echo "Waiting for Docker daemon to start..."
			sleep 1
		done
	else
		log "Docker daemon is already running"
	fi
}
cd $DOCKER_COMPOSE_DIR
check_docker_daemon

check_container
